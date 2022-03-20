//
//  LottieView.swift
//  Blackhole2020
//
//  Created by Jonathan Buehler on 12/26/20.
//

import SwiftUI
import Lottie

/// Represents an animated file erasure
/// Lottie iOS is used to play After Effects generated JSON animations
/// The SwiftUI implementation of Lottie iOS works best when wrapped in a view like this
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

    /// The file animation varies based on its direction from the center of the blackhole
    /// Currently there are 6 different animations
    /// This should be called before displaying the file animation so the proper direction is chosen
    /// - Returns: A directional animation based on x/y position on the screen
    func determine_json_file() -> String {
        var filename = ""
        // print("determine_json_file x=\(x) y=\(y)")

        let MainViewHeight = CGFloat(700)
        let y_offset = CGFloat(MainViewHeight / 4)

        // left side of the screen
        if x < 0 {
            if y < -y_offset {
                filename = "File_Disintegration_TopLeft"
            } else if y > y_offset {
                filename = "File_Disintegration_BottomLeft"
            } else {
                filename = "File_Disintegration_MidLeft"
            }
        } else // x >= 0
        {
            if y < -y_offset {
                filename = "File_Disintegration_TopRight"
            } else if y > y_offset {
                filename = "File_Disintegration_BottomRight"
            } else {
                filename = "File_Disintegration_MidRight"
            }
        }

        return filename
    }

    var body: some View {

        // translate the filenames based on x/y axis
        // Note: SwiftUI frame coordinate space is 0,0 centered in the window so its a bit funky (not topleft or bottom right)

        // it's important to wrap this
        LottieView(file_ani: file_animations,
                   filename: filename, width: file_width, height: file_height, x: x, y: y,
                   shouldPlay: $shouldPlay, shouldErase: $shouldErase,
                   shouldGracefulPause: $shouldGracefulPause, shouldReset: $shouldReset)
            .frame(width: file_width, height: file_height, alignment: .center)
            .offset(x: x, y: y)
            // .animation(Animation.spring(response: 1, dampingFraction: 1, blendDuration: 1))
            .animation(.linear)
            .onReceive([self.$shouldPlay].publisher, perform: { _ in
                // print("LottieView onReceive x=\(x) y=\(y) shouldPlay=\(shouldPlay)")

                filename = determine_json_file()
            })
    }
}

/// Implement Lottie iOS in SwiftUI
struct LottieView: NSViewRepresentable {

    /// Store the pre-loaded animation objects in memory so they don't lag on display
    var file_ani: [Lottie.Animation]

    // the rest of these are declared var so they can be passed in from the FileView
    var filename: String = ""
    @State var prev_filename: String = ""
    var autoplay: Bool = false
    var width: CGFloat = 0.0
    var height: CGFloat = 0.0
    var x: CGFloat = 0
    var y: CGFloat = 0
    var loopmode = LottieLoopMode.playOnce

    // I tried to use this framework in place of Lottie iOS, but it is problematic
    // while the run-time performance seemed superior, there are lots of playback issue and overall it failed to play animations correctly
    // let rlottie = SDAnimatedImageView()

    let animation_time = 5.0
    @State var nowtime = DispatchTime.now()

    // The main BlackHoleView controls these states
    // The combination of Bools allows fine control over the animation state machine
    @Binding var shouldPlay: Bool
    @Binding var shouldErase: Bool
    @Binding var shouldGracefulPause: Bool
    @Binding var shouldReset: Bool

    /// Convert the current file animation (stored as a member variable string) into the animation object in memory
    /// - Returns: The animation object pre-loaded in memory
    func pick_file_animation() -> Lottie.Animation {
        var index = 0

        switch filename {
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

    /// MacOS specific implementation of Lottie animation views
    /// Customized AutoLayout constraints are used to help support Lottie (it lacks native SwiftUI support)
    /// - Parameter context: Not used, but required since we are implementing a protocol
    /// - Returns: Initial view with the underlying Lottie animation objects
    func makeNSView(context: NSViewRepresentableContext<LottieView>) -> NSView {

        let view = NSView(frame: .zero)

        let lottieURL: URL = Bundle.main.url(forResource: filename, withExtension: "json")!

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
                animationView.widthAnchor.constraint(equalToConstant: width)
                ])
        } else {
            NSLayoutConstraint.activate([
              animationView.widthAnchor.constraint(equalTo: view.widthAnchor)
            ])
        }

        if height > 0.0 {
            NSLayoutConstraint.activate([
                animationView.heightAnchor.constraint(equalToConstant: height)
                ])
        } else {
            NSLayoutConstraint.activate([
                animationView.heightAnchor.constraint(equalTo: view.heightAnchor)
                ])
        }

        NSLayoutConstraint.activate([
          animationView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
          animationView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])

        print("makeNSView() setting lottie_ios url -- \(lottieURL)")

        return view
    }

    /// Handle animation state machine
    ///
    /// Bools allow re-using and dynamic reloading of different JSON animations without re-declaring the
    /// Views entirely -- it seems to be the closest SwiftUI-esque way of dynamically changing view content at run-time
    /// Since we need to change the underlying Lottie animation view itself, this is more complex than normal
    /// Future native SwiftUI support in the Lottie framework might obsolete this workaround
    /// - Parameters:
    ///   - uiView: The currently updating view
    ///   - context: Not used
    func updateNSView(_ uiView: NSView, context: NSViewRepresentableContext<LottieView>) {
        if let animationView = uiView.subviews[0] as? AnimationView {

            // print("updateNSView() shouldPlay=\(shouldPlay), gracefulPause=\(shouldGracefulPause), shouldErase=\(shouldErase) shouldReset=\(shouldReset) isPlay=\(animationView.isAnimationPlaying)")

            // Animation state management
            // Views are re-used due to the nature of SwiftUI's view design
            // There's a constant number of Lottie animation views declared at startup that we re-use during runtime

            if shouldPlay {

                // Don't reload the animation if it is the same as last time
                if filename != prev_filename {
                    animationView.animation = pick_file_animation()
                    // print("shouldPlay == TRUE, rebuild animation to->\(filename)")
                    // prev_filename = filename
                }

                // the toProgress=0.4 here is based on the animation being run, it needs to be customized to the JSON
                animationView.play(fromProgress: 0, toProgress: 0.4, loopMode: .playOnce) { (_) in
                    // print("shouldPlay completion handler complete=\(complete), isPlay=\(animationView.isAnimationPlaying)")
                    self.shouldPlay = false
                    self.prev_filename = filename
                }
            }

            if shouldErase {

                animationView.play { (complete) in
                    // print("shouldErase completion handler complete=\(complete), isPlay=\(animationView.isAnimationPlaying)")
                    if complete {
                        self.shouldErase = false
                        self.shouldReset = true
                    }
                }
            }

            if shouldGracefulPause {

                animationView.play { (_) in
                    self.shouldGracefulPause = false
                }
            }
        }
    }
}
