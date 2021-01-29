//
//  LottieView.swift
//  Blackhole2020
//
//  Created by Jonathan Buehler on 12/26/20.
//

import SwiftUI
import Lottie
import SDWebImageLottieCoder

struct LottieView: NSViewRepresentable {
    
    var filename: String
    var autoplay: Bool = false
    var width: CGFloat = 0.0
    var height: CGFloat = 0.0
    var useRLottie: Bool = false
    
    func makeNSView(context: NSViewRepresentableContext<LottieView>) -> NSView {
        let view = NSView(frame: .zero)

        // Lottie json loading
        let lottieURL: URL = Bundle.main.url(forResource: filename, withExtension: "json")!

        var rlottie_view: NSView
        
        if (useRLottie) {
            rlottie_view = SDAnimatedImageView()
            let rlottie: SDAnimatedImageView = rlottie_view as! SDAnimatedImageView
            rlottie.sd_setImage(with: lottieURL)
            
            //setConstraints(animationView: &rlottie_view, view: &view)
            rlottie.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(rlottie_view)
            
            // use a fixed width to override natural JSON value
            if width > 0.0 {
                NSLayoutConstraint.activate([
                    rlottie.widthAnchor.constraint(equalToConstant: width),
                    ])
            }
            else {
                NSLayoutConstraint.activate([
                    rlottie.widthAnchor.constraint(equalTo: view.widthAnchor),
                ])
            }
            
            if height > 0.0 {
                NSLayoutConstraint.activate([
                    rlottie.heightAnchor.constraint(equalToConstant: height),
                    ])
            }
            else {
                NSLayoutConstraint.activate([
                    rlottie.heightAnchor.constraint(equalTo: view.heightAnchor),
                    ])
            }
            
            NSLayoutConstraint.activate([
                rlottie.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                rlottie.centerYAnchor.constraint(equalTo: view.centerYAnchor)
            ])
            
            
            print("setting rlottie url -- \(lottieURL)")
            return view
        }
        else {
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
            
            print("setting lottie_ios url -- \(lottieURL)")
            return view
        }
    }

    func updateNSView(_ uiView: NSView, context: NSViewRepresentableContext<LottieView>)
    {
    }
}

