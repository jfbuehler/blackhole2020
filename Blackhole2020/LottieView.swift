//
//  LottieView.swift
//  Blackhole2020
//
//  Created by Jonathan Buehler on 12/26/20.
//

import SwiftUI
import Lottie
//import SDWebImageLottieCoder

struct FileView: View {
    
    let file_width: CGFloat = 150
    let file_height: CGFloat = 100
    
    var x: CGFloat = 0
    var y: CGFloat = 0
    
    @State var filename = "File_Disintegration_TopLeft"
    var file_animations = [Lottie.Animation]()
    
    @Binding var shouldErase: Bool
    @Binding var shouldPlay: Bool
    @Binding var shouldGracefulPause: Bool
    @Binding var shouldReset: Bool
    
    init(x: CGFloat, y: CGFloat, popInAnimation: Binding<Bool>, eraseAnimation: Binding<Bool>, gracefulPause: Binding<Bool>, reset: Binding<Bool>, file_jsons: [Lottie.Animation]) {
        
        self.x = x
        self.y = y
        self._shouldPlay = popInAnimation
        self._shouldErase = eraseAnimation
        self._shouldGracefulPause = gracefulPause
        self._shouldReset = reset
        self.file_animations = file_jsons
    }
    
    func determine_json_file() -> String
    {
        var filename = ""
        //print("determine_json_file x=\(x) y=\(y)")
        
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
        
        return filename
    }
    
    var body: some View {
        
        // translate the filenames based on x/y axis
        // swiftUI frame coordinate space is 0,0 centered in the window so its a bit funky (not topleft or bottom right)
        
        LottieView(file_ani: file_animations, filename: filename, width: file_width, height: file_height, x: x, y: y, shouldPlay: $shouldPlay, shouldErase: $shouldErase, shouldGracefulPause: $shouldGracefulPause, shouldReset: $shouldReset)
            .frame(width: file_width, height: file_height, alignment: .center)
            .offset(x: x, y: y)
            //.animation(Animation.spring(response: 1, dampingFraction: 1, blendDuration: 1))
            .animation(.linear)
            .onReceive([self.$shouldPlay].publisher, perform: { _ in
                //print("LottieView onReceive x=\(x) y=\(y) shouldPlay=\(shouldPlay)")

                filename = determine_json_file()
            })
    }
}

struct LottieView: NSViewRepresentable {
    
    var file_ani: [Lottie.Animation]
    var filename: String = ""
    @State var prev_filename: String = ""
    var autoplay: Bool = false
    var width: CGFloat = 0.0
    var height: CGFloat = 0.0
    var x: CGFloat = 0
    var y: CGFloat = 0
    var useRLottie: Bool = false
    
    // Lottie json loading
    //let rlottie = SDAnimatedImageView()
    var loopmode = LottieLoopMode.playOnce
    
    let animation_time = 5.0
    @State var nowtime = DispatchTime.now()
    @Binding var shouldPlay: Bool
    @Binding var shouldErase: Bool
    @Binding var shouldGracefulPause: Bool
    @Binding var shouldReset: Bool
    
    func pick_file_animation() -> Lottie.Animation
    {
//        if filename == "File_Disintegration_TopLeft" {
//            return file_ani[0]
//        }
        var index = 0
        
        switch filename
        {
        case "File_Disintegration_TopLeft": index = 0
        case "File_Disintegration_BottomLeft": index = 1
        case "File_Disintegration_MidLeft": index = 2
        case "File_Disintegration_TopRight": index = 3
        case "File_Disintegration_BottomRight": index = 4
        case "File_Disintegration_MidRight": index = 5
            
        default: index = 0
        }
        
        return file_ani[index]
    }
    
    func makeNSView(context: NSViewRepresentableContext<LottieView>) -> NSView {
        
        let view = NSView(frame: .zero)
        
        let lottieURL: URL = Bundle.main.url(forResource: filename, withExtension: "json")!
        
        if (useRLottie) {
                        
//            rlottie.sd_setImage(with: lottieURL)
//            rlottie.autoPlayAnimatedImage = false
//            rlottie.resetFrameIndexWhenStopped = true  // bleh, seems broken
//
//            //isPlaying = rlottie.player?.isPlaying
//            rlottie.player?.animationLoopHandler = { (loop) in
//                print("file has looped \(loop) times")
//            }
//
//            rlottie.translatesAutoresizingMaskIntoConstraints = false
//            view.addSubview(rlottie)
//
//            // use a fixed width to override natural JSON value
//            if width > 0.0 {
//                NSLayoutConstraint.activate([
//                    rlottie.widthAnchor.constraint(equalToConstant: width),
//                    ])
//            }
//            else {
//                NSLayoutConstraint.activate([
//                    rlottie.widthAnchor.constraint(equalTo: view.widthAnchor),
//                ])
//            }
//
//            if height > 0.0 {
//                NSLayoutConstraint.activate([
//                    rlottie.heightAnchor.constraint(equalToConstant: height),
//                    ])
//            }
//            else {
//                NSLayoutConstraint.activate([
//                    rlottie.heightAnchor.constraint(equalTo: view.heightAnchor),
//                    ])
//            }
//
//            NSLayoutConstraint.activate([
//                rlottie.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//                rlottie.centerYAnchor.constraint(equalTo: view.centerYAnchor)
//            ])
//
//
//            print("setting rlottie url -- \(lottieURL) w/ frame_cnt=\(rlottie.player?.totalFrameCount)")
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
                        
            return view
        }
    }

    func updateNSView(_ uiView: NSView, context: NSViewRepresentableContext<LottieView>)
    {
        //uiView.subviews.forEach({ $0.removeFromSuperview() })
        
        if let animationView = uiView.subviews[0] as? AnimationView {
        
            //print("updateNSView() shouldPlay=\(shouldPlay), gracefulPause=\(shouldGracefulPause), shouldErase=\(shouldErase) shouldReset=\(shouldReset) isPlay=\(animationView.isAnimationPlaying)")
            
            // ---- -- - - - - - New animation state machine goes here -- - - - - - - - - ---- - - - - -
            
            if shouldPlay {
                
                if filename != prev_filename {
                    //let animation = Animation.named(filename)
                    animationView.animation = pick_file_animation()
                    //print("shouldPlay == TRUE, rebuild animation to->\(filename)")
                    //prev_filename = filename
                }
                
                animationView.play(fromProgress: 0, toProgress: 0.4, loopMode: .playOnce) { (complete) in
                    //print("shouldPlay completion handler complete=\(complete), isPlay=\(animationView.isAnimationPlaying)")
                    self.shouldPlay = false
                    self.prev_filename = filename
                }
            }
            
            if shouldErase {
                
                animationView.play { (complete) in
                    //print("shouldErase completion handler complete=\(complete), isPlay=\(animationView.isAnimationPlaying)")
                    if complete {
                        self.shouldErase = false
                        self.shouldReset = true
                    }
                }
                
            }
            
            if shouldGracefulPause {
                
                animationView.play() { (complete) in
                    self.shouldGracefulPause = false
                }
            }
            
            
            // -----
            
            
            // old animation state machine
            #if false
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
            #endif
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
