//
//  PlayerView.swift
//  Blackhole2020
//
//  Created by Jonathan Buehler on 1/25/21.
//

import SwiftUI

import AVKit
import AVFoundation

class VideoItem: ObservableObject {
    @Published var player: AVPlayer = AVPlayer()
    @Published var playerItem: AVPlayerItem?

    func open(_ url: URL) {
        let asset = AVAsset(url: url)
        let playerItem = AVPlayerItem(asset: asset)
        self.playerItem = playerItem
        player.replaceCurrentItem(with: playerItem)
    }
}

struct PlayerView: NSViewRepresentable {
    @Binding var player: AVPlayer

    func updateNSView(_ NSView: NSView, context: NSViewRepresentableContext<PlayerView>) {
        guard let view = NSView as? AVPlayerView else {
            debugPrint("unexpected view")
            return
        }

        view.player = player
    }

    func makeNSView(context: Context) -> NSView {
        return AVPlayerView(frame: .zero)
    }
}
