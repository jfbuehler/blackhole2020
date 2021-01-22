//
//  LottieView.swift
//  Blackhole2020
//
//  Created by Jonathan Buehler on 12/26/20.
//

import SwiftUI
import Lottie

struct LottieView: NSViewRepresentable {
    
    var filename: String
    var autoplay: Bool = false
    var width: CGFloat = 0.0
    var height: CGFloat = 0.0
    
    func makeNSView(context: NSViewRepresentableContext<LottieView>) -> NSView {
        let view = NSView(frame: .zero)

        let animationView = AnimationView()
        let animation = Animation.named(filename)
        animationView.animation = animation
        animationView.contentMode = .scaleAspectFit
        
        var loopmode = LottieLoopMode.loop
        if autoplay == false {
            loopmode = .playOnce
        }
        animationView.play(fromProgress: 0, toProgress: 1, loopMode: loopmode, completion: nil)
        animationView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(animationView)

        // use a fixed width to override natural JSON value
        if width > 0.0 {
            NSLayoutConstraint.activate([
                animationView.widthAnchor.constraint(equalToConstant: width),
                ])
        }
        else {
            NSLayoutConstraint.activate([
              animationView.widthAnchor.constraint(equalTo: view.widthAnchor),
            ])
        }
        
        if height > 0.0 {
            NSLayoutConstraint.activate([
                animationView.heightAnchor.constraint(equalToConstant: height),
                ])
        }
        else {
            NSLayoutConstraint.activate([
                animationView.heightAnchor.constraint(equalTo: view.heightAnchor),
                ])
        }
        
        NSLayoutConstraint.activate([
          animationView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
          animationView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])

        return view
    }

    func updateNSView(_ uiView: NSView, context: NSViewRepresentableContext<LottieView>)
    {
    }
}

