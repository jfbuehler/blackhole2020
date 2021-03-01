//
//  JonsMusicPlayer.swift
//  Blackhole2020
//
//  Created by Jonathan Buehler on 2/27/21.
//

import Foundation
import AVFoundation

enum MusicCategories: Int
{
    case space_synth
    
    case off
}

struct Song
{
    var title: String
    var url:  URL
    var mp:   AVAudioPlayer
    var cat:  MusicCategories
}


class JonsMusicPlayer : NSObject
{
    // ensure this is a Singleton so we don't make multiple copies of the music playing across the app
    static let sharedInstance = JonsMusicPlayer()
    
    var active_cat = MusicCategories.off
    var songs = [Song]()
    
    var space_synth_mps = [AVAudioPlayer]()
    var active_mps = [AVAudioPlayer]()
    var active_mp: AVAudioPlayer?
    var next_queued_song: DispatchWorkItem?
    var isPlaying = false
    
    let default_cross_fade_in = 2.0
    let default_cross_fade_out = 2.0
    
    var cross_fade_seconds_in = 2.0
    var cross_fade_seconds_out = 2.0
    let ext = "m4a"  // only support music in m4a formats
    
    override init()
    {
        super.init()
        
        // Category playback allows audio to play even with the Silent button enabled (per the API)
        // there are other categories and options available, pretty cool, check em out!
//        do {
//        try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode(rawValue: convertFromAVAudioSessionMode(AVAudioSession.Mode.default)), options: .mixWithOthers)
//        try AVAudioSession.sharedInstance().setActive(true)
//        }
//        catch let error {
//            print(" *** Failure in " + #function + error.localizedDescription)
//        }
        
        generate_file_lists()
        
        // set default active music lib
        active_mps = space_synth_mps
    }
    
    // helper function to make lists of music files that grows / shrinks as we need it to
    func generate_file_lists()
    {
        load_urls_audio_players(subdir: "space_synth", mps: &space_synth_mps)
    }
    
    func load_urls_audio_players(subdir: String, mps: inout [AVAudioPlayer])
    {
        guard var urls = Bundle.main.urls(forResourcesWithExtension: "m4a", subdirectory: subdir)
            else { return }
        
        urls.sort { $0.absoluteString.compare(
            $1.absoluteString, options: .numeric) == .orderedAscending
        }
        
        // preload the available songs
        for url in urls {
            
            do {
                let mp = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.m4a.rawValue)
                mps.append(mp)
                print("Adding song [\(url.relativeString)]")
            }
            catch let error {
                print(" *** Failure in " + #function + error.localizedDescription)
            }
        }
    }
    
    func playSong(mp: AVAudioPlayer)
    {
        mp.volume = 0
        //mp.numberOfLoops = -1  // infinite
        mp.numberOfLoops = 0
        mp.play()
        mp.setVolume(1, fadeDuration: self.cross_fade_seconds_in)
        active_mp = mp
        
        isPlaying = true
    }
    
    func playInfiniteSong(mp: AVAudioPlayer, vol: Bool = true, offset: TimeInterval = 0)
    {
        mp.currentTime = offset
        mp.volume = 0
        mp.numberOfLoops = -1  // infinite
        mp.play()
        if vol {
            mp.setVolume(1, fadeDuration: self.cross_fade_seconds_in)
        }
        active_mp = mp
        
        isPlaying = true
        
        print("playing mp=\(mp.url?.relativeString) @ \(mp.currentTime)")
    }
    
    func stopPlaying()
    {
        isPlaying = false
        active_mp?.setVolume(0, fadeDuration: cross_fade_seconds_out)
        if next_queued_song != nil {
            next_queued_song!.cancel()
            print("Stop Playing! ")
        
        }
    }
    
    // start playing a randomized "playlist" we keep locally here in class
    func playCrossFadedSongs()
    {
        if isPlaying == false {
            
            // start a new sequence
            active_mps.shuffle()
            
            // need to work around what to do with single play lists, can't cross fade the same song to itself it wont play nice
            // so we will use an infinite loop option instead
            if active_mps.count > 1 {
                shuffle_play(index: 0)
            }
            else {
                playInfiniteSong(mp: active_mps[0])
            }
        }
    }
    
    func shuffle_play(index: Int)
    {
        let curr_song = active_mps[index]
        playSong(mp: curr_song)
        print("Playing \(curr_song.url?.relativeString) for \(curr_song.duration) seconds ")
        
        next_queued_song = DispatchWorkItem(block: {
            
            let index = index + 1
            
            if index < self.active_mps.count {
                curr_song.setVolume(0, fadeDuration: self.cross_fade_seconds_out)
                self.shuffle_play(index: index)
                print("queuing up index[\(index)] for \(self.active_mps[index].duration) next")
            }
            else {
                // restart
                self.active_mp?.setVolume(0, fadeDuration: self.cross_fade_seconds_out)
                self.active_mps.shuffle()
                self.shuffle_play(index: 0)
                print("playlist reset!")
            }
            
        })
        
        // I'm unsure if we need to do these things on main thread, but it seems mellow enough for now...
        let cross_faded_duration = curr_song.duration - 5.0  // subtract to create "cross-fade"
        let silence_added_duration = curr_song.duration + 0.0 // play with the amount of silence time
        
        DispatchQueue.main.asyncAfter(deadline: .now() + silence_added_duration, execute: next_queued_song!)
    }
    
    func change_category(cat: MusicCategories)
    {
        // reset state
        cross_fade_seconds_in = default_cross_fade_in
        cross_fade_seconds_out = default_cross_fade_out
        
        switch cat
        {
        case .space_synth:
            active_mps = space_synth_mps
            
            
        case .off: break
            active_mps.removeAll()
        }
        
        active_cat = cat
        
        stopPlaying()
        playCrossFadedSongs()
    }
}
