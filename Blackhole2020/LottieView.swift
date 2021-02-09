//
//  LottieView.swift
//  Blackhole2020
//
//  Created by Jonathan Buehler on 12/26/20.
//

import SwiftUI
import Lottie
import SDWebImageLottieCoder

struct FileView: View {
    
    let file_width: CGFloat = 150
    let file_height: CGFloat = 100
    
    var x: CGFloat = 0
    var y: CGFloat = 0
    
    var filename = "File_Disintegration_TopLeft"
    
    @Binding var shouldPlay: Bool
    @Binding var shouldGracefulPause: Bool
    
    init(x: CGFloat, y: CGFloat, animating: Binding<Bool>, gracefulPause: Binding<Bool>) {
        
        self.x = x
        self.y = y
        self._shouldPlay = animating
        self._shouldGracefulPause = gracefulPause
        
        let MainViewHeight = CGFloat(700)
        let y_offset = CGFloat(MainViewHeight / 4)
        
        // left side of the screen
        if x < 0 {
            if y < -y_offset {
                filename = "File_Disintegration_TopLeft"
            }
            else if y > y_offset {
                filename = "File_Disintegration_BottomLeft"
            }
            else {
                filename = "File_Disintegration_MidLeft"
            }
        }
        else // x >= 0
        {
            if y < -y_offset {
                filename = "File_Disintegration_TopRight"
            }
            else if y > y_offset {
                filename = "File_Disintegration_BottomRight"
            }
            else {
                filename = "File_Disintegration_MidRight"
            }
        }
    }
    
    var body: some View {
        
        // translate the filenames based on x/y axis
        // swiftUI frame coordinate space is 0,0 centered in the window so its a bit funky (not topleft or bottom right)
        
        LottieView(filename: filename, width: file_width, height: file_height, shouldPlay: $shouldPlay, shouldGracefulPause: $shouldGracefulPause)
            .frame(width: file_width, height: file_height, alignment: .center)
            .offset(x: x, y: y)
//            .onReceive([self.$shouldPlay].publisher, perform: { _ in
//                print("does this actually fire on changes?? x=\(x) y=\(y) shouldPlay=\(shouldPlay)")
//
//                shouldGracefulPause = true
//            })
    }
}

struct LottieView: NSViewRepresentable {
    
    var filename: String
    var autoplay: Bool = false
    var width: CGFloat = 0.0
    var height: CGFloat = 0.0
    var useRLottie: Bool = false
    
    // Lottie json loading
    let rlottie = SDAnimatedImageView()
    var loopmode = LottieLoopMode.playOnce
    
    let animation_time = 5.0
    @State var nowtime = DispatchTime.now()
    @Binding var shouldPlay: Bool
    @Binding var shouldGracefulPause: Bool   // set to true when we want to stop the animation at the end of itself
    
    func makeNSView(context: NSViewRepresentableContext<LottieView>) -> NSView {
        let view = NSView(frame: .zero)
        let lottieURL: URL = Bundle.main.url(forResource: filename, withExtension: "json")!
        
        if (useRLottie) {
                        
            rlottie.sd_setImage(with: lottieURL)
            rlottie.autoPlayAnimatedImage = false
            rlottie.resetFrameIndexWhenStopped = true  // bleh, seems broken
            
            //isPlaying = rlottie.player?.isPlaying
            rlottie.player?.animationLoopHandler = { (loop) in
                print("file has looped \(loop) times")
            }
            
            // each File animation will spawn a thread to monitor itself
//            DispatchQueue.global(qos: .background).async {
//
//                while(true) {
//
//                    if let player = rlottie.player {
//                        if shouldPlay {
//                            //print("file monitor thread shouldPlay = true")
//                            player.startPlaying()
//                        }
//                        else {
//
//                            //
//                            let curr_idx = player.currentFrameIndex
//                            let total_idx = player.totalFrameCount
//
//                            if curr_idx >= total_idx - 10 {
//                                player.stopPlaying()
//                            }
//                            //print("file monitor thread shouldPlay = false, frame=\(curr_idx!)")
//                        }
//                    }
//
//                    let sleep_time = UInt32(0.25 * 1e6)
//                    usleep(sleep_time)
//                }
//            }
            
            rlottie.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(rlottie)
            
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
            
            
            print("setting rlottie url -- \(lottieURL) w/ frame_cnt=\(rlottie.player?.totalFrameCount)")
            return view
        }
        else {
            
            let animationView = AnimationView()
            let animation = Animation.named(filename)
            animationView.animation = animation
            animationView.contentMode = .scaleAspectFit
            animationView.translatesAutoresizingMaskIntoConstraints = false
            // this breaks the loop mode since self is immutable here
//            if autoplay == false {
//                loopmode = .playOnce
//            }
            
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
            
            print("makeNSView() setting lottie_ios url -- \(lottieURL)")
            
            // Setup a monitor thread to turn the animations on/off
//            DispatchQueue.main.async {
//
//                while(true) {
//
//                    if shouldPlay {
//
//                        animationView.play()
//                    }
//                    else {
//                        animationView.stop()
//                    }
//
//                    let sleep_time = UInt32(0.25 * 1e6)
//                    usleep(sleep_time)
//                }
//            }
            return view
        }
    }

    func updateNSView(_ uiView: NSView, context: NSViewRepresentableContext<LottieView>)
    {
        //uiView.subviews.forEach({ $0.removeFromSuperview() })
        
        if let animationView = uiView.subviews[0] as? AnimationView {
        
            //print("updateNSView() shouldPlay=\(shouldPlay), gracefulPause=\(shouldGracefulPause) isPlay=\(animationView.isAnimationPlaying) views=\(uiView.subviews.count)")
            
            if shouldPlay {
                
                //print("animationView.play - shouldPlay = \(shouldPlay), isPlay=\(animationView.isAnimationPlaying)")

                if animationView.isAnimationPlaying == false {
                    //animationView.stop()
                    animationView.currentFrame = 0
                    animationView.play(fromProgress: 0, toProgress: 1, loopMode: .loop) { (complete) in
                        //print("lottie looped completion handler firing - shouldPlay = \(shouldPlay), complete=\(complete), isPlay=\(animationView.isAnimationPlaying)")
                        
                        // this occurs when the pause() is set below..
                        // let's run it out to completion
                        shouldGracefulPause = false
                        animationView.play(fromProgress: 0, toProgress: 1, loopMode: .playOnce, completion: {_ in })
                    }
                }
            }
            else {
                
                
                // as a way of stopping the animation, try playing til the end?
                //animationView.pause()
                //animationView.play(toProgress: 1.0)
                
                if animationView.isAnimationPlaying && self.shouldGracefulPause {
                    
                    animationView.pause()
                }
            }
        }
        
//            if animationView.isAnimationPlaying == false {
//
                
//            }

//        let delta_time = DispatchTime.now().uptimeNanoseconds - nowtime.uptimeNanoseconds
//
//        if (delta_time / NSEC_PER_SEC) >= 5 {
//
//            print("it's been over 5 seconds...")
//            nowtime = DispatchTime.now()
//        }
        
//        if DispatchTime.now() - nowtime >= 5.0 {
//
//        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator
    {
        
    }
}

extension LottieView
{
    
}

// the original version
//struct FileView: View {
//
//    let file_width: CGFloat = 150
//    let file_height: CGFloat = 100
//
//    var x: CGFloat = 0
//    var y: CGFloat = 0
//
//    var filename = "File_Disintegration_TopLeft"
//
//    @Binding var shouldPlay: Bool
//
//    init(x: CGFloat, y: CGFloat, animating: Binding<Bool>) {
//
//        self.x = x
//        self.y = y
//        self._shouldPlay = animating
//
//        let MainViewHeight = CGFloat(700)
//        let y_offset = CGFloat(MainViewHeight / 4)
//
//        // left side of the screen
//        if x < 0 {
//            if y < -y_offset {
//                filename = "File_Disintegration_TopLeft"
//            }
//            else if y > y_offset {
//                filename = "File_Disintegration_BottomLeft"
//            }
//            else {
//                filename = "File_Disintegration_MidLeft"
//            }
//        }
//        else // x >= 0
//        {
//            if y < -y_offset {
//                filename = "File_Disintegration_TopRight"
//            }
//            else if y > y_offset {
//                filename = "File_Disintegration_BottomRight"
//            }
//            else {
//                filename = "File_Disintegration_MidRight"
//            }
//        }
//    }
//
//    var body: some View {
//
//        // translate the filenames based on x/y axis
//        // swiftUI frame coordinate space is 0,0 centered in the window so its a bit funky (not topleft or bottom right)
//
//        LottieView(filename: filename, width: file_width, height: file_height, shouldPlay: $shouldPlay)
//            .frame(width: file_width, height: file_height, alignment: .center)
//            .offset(x: x, y: y)
//    }
//}
