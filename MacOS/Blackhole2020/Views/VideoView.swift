//
//  VideoView.swift
//  Blackhole2020
//
//  Modified by Jonathan Buehler on 1/26/21.
// Original Source from https://github.com/SergioEstevao/SVEVideoUI
//

// swiftlint:disable missing_docs

import SwiftUI
import AVFoundation
import AVKit

/// A view that displays an environment-dependent video.
///
/// The video element on iOS is a wrapper of the AVPlayerViewController, while on macOS is a wrapper
/// around AVPlayerView
/// It can be configured to display controls, auto-loop or mute sound depending of the developer needs.
///
/// - SeeAlso: `AVPlayerViewController`
public struct Video {

    /// The URL of the video you want to display
    var videoURL: URL

    /// If true the playback controler will be visible on the view
    var showsPlaybackControls: Bool = false

    /// If true the option to show the video in PIP mode will be available in the controls
    var allowsPictureInPicturePlayback: Bool = false

    /// If true the video sound will be muted
    var isMuted: Binding<Bool> = .constant(true)

    /// How the video will resized to fit the view
    var videoGravity: AVLayerVideoGravity = .resizeAspect

    /// If true the video will loop itself when reaching the end of the video
    var loop: Binding<Bool> = .constant(true)

    /// if true the video will play itself automattically
    var isPlaying: Binding<Bool>

    public init(url: URL, playing: Binding<Bool> = .constant(true), muted: Binding<Bool> = .constant(false)) {
        videoURL = url
        isPlaying = playing
        isMuted = muted
    }
}

#if os(iOS)
extension Video: UIViewControllerRepresentable {

    public func makeUIViewController(context: Context) -> AVPlayerViewController {
        let videoViewController = AVPlayerViewController()
        videoViewController.player = AVPlayer(url: videoURL)

        let videoCoordinator = context.coordinator
        videoCoordinator.player = videoViewController.player
        videoCoordinator.url = videoURL

        return videoViewController
    }

    public func updateUIViewController(_ videoViewController: AVPlayerViewController, context: Context) {
        if videoURL != context.coordinator.url {
            videoViewController.player = AVPlayer(url: videoURL)
            context.coordinator.player = videoViewController.player
            context.coordinator.url = videoURL
        }
        videoViewController.showsPlaybackControls = showsPlaybackControls
        videoViewController.allowsPictureInPicturePlayback = allowsPictureInPicturePlayback
        videoViewController.player?.isMuted = isMuted.wrappedValue
        videoViewController.videoGravity = videoGravity
        context.coordinator.togglePlay(isPlaying: isPlaying.wrappedValue)
    }

    public func makeCoordinator() -> VideoCoordinator {
        return VideoCoordinator(video: self)
    }
}
#elseif os(macOS)
extension Video: NSViewRepresentable {

    public func makeNSView(context: Context) -> AVPlayerView {
        let videoView = AVPlayerView()
        videoView.player = AVPlayer(url: videoURL)
        // let item = AVPlayerItem(url: videoURL)
        // let item2 = AVPlayerItem(url: videoURL)
        // videoView.player = AVQueuePlayer(playerItem: item)

        // todo -- unsure if this does anything or is useful at all
        videoView.window?.isOpaque = false

        // maybe need to replace the PlayerView with a PlayerLayer ?? to get transparency to work

        let videoCoordinator = context.coordinator
        videoCoordinator.player = videoView.player
        videoCoordinator.url = videoURL

        return videoView
    }

    public func updateNSView(_ videoView: AVPlayerView, context: Context) {
        if videoURL != context.coordinator.url {
            videoView.player = AVPlayer(url: videoURL)
            // let item = AVPlayerItem(url: videoURL)
            // let item2 = AVPlayerItem(url: videoURL)
            // videoView.player = AVQueuePlayer(playerItem: item)
            context.coordinator.player = videoView.player
            context.coordinator.url = videoURL

            // context.coordinator.playerLooper = AVPlayerLooper(player: videoView.player! as! AVQueuePlayer, templateItem: item)
        }
        if showsPlaybackControls {
            videoView.controlsStyle = .inline
        } else {
            videoView.controlsStyle = .none
        }
        if #available(OSX 10.15, *) {
            videoView.allowsPictureInPicturePlayback = allowsPictureInPicturePlayback
        } else {
            // Fallback on earlier versions
        }
        videoView.player?.isMuted = isMuted.wrappedValue
        videoView.player?.volume = isMuted.wrappedValue ? 0 : 1
        videoView.videoGravity = videoGravity
        context.coordinator.togglePlay(isPlaying: isPlaying.wrappedValue)
    }

    public func makeCoordinator() -> VideoCoordinator {
        return VideoCoordinator(video: self)
    }
}
#endif

extension Video {
    // MARK: - Coordinator
    public class VideoCoordinator: NSObject {

        var playerContext = "playerContext"

        let video: Video

        var timeObserver: Any?

        var playerLooper: AVPlayerLooper?
        var player: AVPlayer? {
            didSet {
                removeTimeObserver(from: oldValue)
                removeKVOObservers(from: oldValue)

                addTimeObserver(to: player)
                addKVOObservers(to: player)

                NotificationCenter.default.addObserver(self,
                                                       selector: #selector(Video.VideoCoordinator.playerItemDidReachEnd),
                                                       name: .AVPlayerItemDidPlayToEndTime,
                                                       object: player?.currentItem)

            }
        }

        private func addTimeObserver(to player: AVPlayer?) {
            timeObserver = player?.addPeriodicTimeObserver(forInterval: CMTimeMake(value: 1, timescale: 4), queue: nil, using: { [weak self](_) in
                self?.updateStatus()
            })
        }

        private func removeTimeObserver(from player: AVPlayer?) {
            if let timeObserver = timeObserver {
                player?.removeTimeObserver(timeObserver)
            }
        }

        private func removeKVOObservers(from player: AVPlayer?) {
            player?.removeObserver(self, forKeyPath: "muted")
            player?.removeObserver(self, forKeyPath: "volume")
        }

        private func addKVOObservers(to player: AVPlayer?) {
            player?.addObserver(self, forKeyPath: "muted",
                                   options: [.new, .old],
                                   context: &playerContext)

            player?.addObserver(self, forKeyPath: "volume",
            options: [.new, .old],
            context: &playerContext)
        }

        var url: URL?

        init(video: Video) {
            self.video = video
            super.init()
        }

        deinit {
            removeTimeObserver(from: player)
            removeKVOObservers(from: player)
        }

        @objc public func playerItemDidReachEnd(notification: NSNotification) {
            if video.loop.wrappedValue {
                player?.pause()
                player?.seek(to: .zero)
                player?.play()
                print("playerItemDidReachEnd")
            } else {
                video.isPlaying.wrappedValue = false
            }
        }

        @objc public func updateStatus() {
            if let player = player {
                video.isPlaying.wrappedValue = player.rate > 0
            } else {
                video.isPlaying.wrappedValue = false
            }
        }

        func togglePlay(isPlaying: Bool) {
            if isPlaying {
                if player?.currentItem?.duration == player?.currentTime() {
                    player?.seek(to: .zero)
                    player?.play()
                }
                player?.play()
            } else {
                player?.pause()
            }
        }

        // swiftlint:disable block_based_kvo
        override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {

            // Only handle observations for the playerContext
            guard context == &(playerContext), keyPath == "muted" || keyPath == "volume" else {
                super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
                return
            }
            if let player = player {
                #if os(macOS)
                video.isMuted.wrappedValue = player.volume == 0
                #else
                video.isMuted.wrappedValue = player.isMuted
                #endif
            }
        }
    }
}
// MARK: - Modifiers
extension Video {

    public func pictureInPicturePlayback(_ value: Bool) -> Video {
        var new = self
        new.allowsPictureInPicturePlayback = value
        return new
    }

    public func playbackControls(_ value: Bool) -> Video {
        var new = self
        new.showsPlaybackControls = value
        return new
    }

    public func isMuted(_ value: Bool) -> Video {
        return isMuted(.constant(value))
    }

    public func isMuted(_ value: Binding<Bool>) -> Video {
        var new = self
        new.isMuted = value
        return new
    }

    public func isPlaying(_ value: Bool) -> Video {
        let new = self
        new.isPlaying.wrappedValue = value
        return new
    }

    public func isPlaying(_ value: Binding<Bool>) -> Video {
        var new = self
        new.isPlaying = value
        return new
    }

    public func videoGravity(_ value: AVLayerVideoGravity) -> Video {
        var new = self
        new.videoGravity = value
        return new
    }

    public func loop(_ value: Bool) -> Video {
        self.loop.wrappedValue = value
        return self
    }

    public func loop(_ value: Binding<Bool>) -> Video {
        var new = self
        new.loop = value
        return new
    }
}
