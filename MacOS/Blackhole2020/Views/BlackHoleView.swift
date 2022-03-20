//
//  BlackHoleView.swift
//  Blackhole2020
//
//  Created by Jonathan Buehler on 12/24/20.
//

import SwiftUI
import AVKit
import Lottie
import AppCenterAnalytics

// TODO: -- would be good to refactor and remove these
// swiftlint:disable type_body_length
// swiftlint:disable file_length

var SECURE_ERASE = true // enable to use crypto-secure erasing

/// Allows SwiftUI to easily control the JSON File Erase animations
struct AnimatedFileState: Identifiable {
    let id = UUID()
    var popIn = false
    var pause = false
    var erase = false
    var reset = false
    var isErased = false
    var animating = false
    var x: CGFloat = 0
    var y: CGFloat = 0
}

/// The parent view of the app
struct BlackHoleView: View {

    let file_width: CGFloat = 200
    let file_height: CGFloat = 150

    @State private var isFileAnimationThreadRunning = false
    private var blackhole_url = Bundle.main.url(forResource: "black-hole", withExtension: "mp4")!

    @State private var animationTime = 5.0
    let timer = Timer.publish(every: 2, on: .main, in: .common).autoconnect()

    // the elegant initializer to create an array
    @State private var files = [AnimatedFileState](repeating: AnimatedFileState.init(), count: 10)

    @State private var eraseFiles = false
    @State private var popIn = false
    @State private var gracefulPauseFiles = false
    @State private var blackholeAnimating = false

    @State private var total_num_of_files = 0
    @State private var num_of_files = 0

    private var bytes_display_lock = NSLock()
    @State private var total_bytes_to_erase = 0.0
    @State private var bytes_written = 0.0

    @State private var hex_text_overlay = ""        // not sure I want to use this anymore, but leave it in-code (remove from display)
    @State private var current_filename = ""

    // use this to pause / stop the file erasing
    @State private var shouldPause = false

    // hex text
    @State private var hex_text_opacity = 1.0
    @State private var hex_text_x: CGFloat = 850
    @State private var hex_text_y: CGFloat = 85
    @State private var hex_scale: CGFloat = 1.0

    /// Store animations in memory for faster access during runtime
    private var file_animations = [Lottie.Animation]()

    @State private var showingAlert = false
    @State private var last_dropped_items = [NSItemProvider]()

    @State private var progress_gradient = LinearGradient(
            gradient: Gradient(colors: [.purple, .purple, .purple]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

    init() {

        // Opening animations early as possible allows them to avoid lagging during runtime
        file_animations.append(Animation.named("File_Disintegration_TopLeft")!)
        file_animations.append(Animation.named("File_Disintegration_BottomLeft")!)
        file_animations.append(Animation.named("File_Disintegration_MidLeft")!)
        file_animations.append(Animation.named("File_Disintegration_TopRight")!)
        file_animations.append(Animation.named("File_Disintegration_BottomRight")!)
        file_animations.append(Animation.named("File_Disintegration_MidRight")!)
        // print("file_animations=\(file_animations.count)")

        // uncomment to enable auto music playing on open, right now we don't want it
        // JonsMusicPlayer.sharedInstance.change_category(cat: .space_synth)
    }

    var body: some View {

        let progressBarStyle = GradientProgressStyle(
                    stroke: progress_gradient,
                    fill: progress_gradient,
                    caption: ""
                )

        VStack {
            ZStack(alignment: .center) {
                // can't use Lottie to generate this JSON animation; its too CPU intensive sadly
                // LottieView(filename: "StarField", autoplay: true)

                // this native VideoPlayer replaces the 3rd party github code below but requires OS 11, so I haven't tested it yet
                // (built this to support 10.x at first)
                // VideoPlayer(player: AVPlayer(url:  Bundle.main.url(forResource: "video", withExtension: "mp4")!))
                Video(url: blackhole_url)
                    .loop(true)
                    .isPlaying(self.$blackholeAnimating)
                    .frame(width: 1000, height: 700)

                // TODO: -- some more features requiring MacOS 11, we can now explore time permitting!!
                // a size zero button to disable/enable music?
//                Button("Help") {
//                    self.showingHelp.toggle()
//                }
//                .alert(isPresented: $showingHelp) {
//                    Alert(title: Text("How To Use"),
//                          message: Text("""
//                                        Welcome to the Secure File Eraser BlackHole 2020! \n
//                                        Please drag and drop files/folders on to the app to erase! \n
//                                        Press Space Bar to stop. \n
//                                        Please contact blackhole2020app@gmail.com for any questions!
//                                        Happy erasure of your files =]
//                                        """),
//                          dismissButton: .default(Text("OK")) {
//                        })
//                }

//                .sheet(isPresented: $showingHelp) {
//                    SecondView(name: "Help help help help")
//                }
//                .position(x: -10, y: -10)
                // .keyboardShortcut("m")

                ZStack {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .frame(width: 200, height: 50, alignment: .center)
                        .foregroundColor(Color.init(hex: 0x721FAE))
                        .position(x: 150, y: 50)
                    RoundedRectangle(cornerRadius: 25.0, style: .continuous)
                        .frame(width: 195, height: 45, alignment: .center)
                        .foregroundColor(.black)
                        .position(x: 150, y: 50)

                    Text("\(total_num_of_files) files destroyed")
                        .font(.custom("VT323-Regular", size: 16))
                        .fontWeight(.medium)
                        .foregroundColor(Color.white)
                        .multilineTextAlignment(.center)
                        .frame(width: 100, height: 50, alignment: .center)
                        // .background(Color.init(hex: 0x721FAE))
                        .position(x: 150, y: 50)
                }

                ZStack {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .frame(width: 200, height: 90, alignment: .center)
                        .foregroundColor(Color.init(hex: 0x721FAE))
                        .position(x: 850, y: 60)
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .frame(width: 195, height: 80, alignment: .center)
                        .foregroundColor(.black)
                        .position(x: 850, y: 60)

                    Text("\(Int(bytes_written))")
                        .font(.custom("VT323-Regular", size: 16))
                        .fontWeight(.medium)
                        .foregroundColor(Color.white)
                        // .multilineTextAlignment(.center)
                        // .lineLimit(1)
                        .frame(width: 200, height: 50, alignment: .center)
                        // .background(Color.blue)
                        .shadow(radius: 5 )
                        .position(x: 850, y: 40)
                        .transition(.opacity)

                    Text("\(Int(total_bytes_to_erase))")
                        .font(.custom("VT323-Regular", size: 16))
                        .fontWeight(.medium)
                        .foregroundColor(Color.white)
                        // .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .frame(width: 200, height: 50, alignment: .center)
                        // .background(Color.blue)
                        // .shadow(radius: 5 )
                        // .scaleEffect(hex_scale)
                        // .animation(.easeIn)
                        .position(x: hex_text_x, y: hex_text_y)
                        // .animation(nil)
                        .opacity(Double(2 - hex_text_opacity))
//                        .animation(
//                            Animation.easeInOut(duration: 0.5)
//                                .delay(1)
//                                .repeatForever()
//                        )
                        // .rotation3DEffect(Angle.degrees(30), axis: (x: 1, y: 0, z: 0))
                        // .animation(.easeInOut)

                    Text("bytes destroyed of")
                        .font(.custom("VT323-Regular", size: 16))
                        .fontWeight(.medium)
                        .foregroundColor(Color.white)
                        // .multilineTextAlignment(.center)
                        // .lineLimit(1)
                        .frame(width: 200, height: 50, alignment: .center)
                        // .background(Color.blue)
                        .shadow(radius: 5 )
                        .position(x: 850, y: 60)
                }

                 // TODO: -- now that OS X 11 is "old" we can upgrade to newer SwiftUI features such as this
//                        .onChange(of: text_overwrite, perform: { value in
//
//                        })

                ZStack {

                    ProgressView(value: bytes_written, total: total_bytes_to_erase)
                        .frame(width: 500, height: 100, alignment: .center)
                        .position(x: 500, y: 660)
                        .progressViewStyle(progressBarStyle)

                    Text(current_filename)
                        .font(.custom("VT323-Regular", size: 16))
                        .fontWeight(.medium)
                        .foregroundColor(Color.white)
                        .multilineTextAlignment(.center)
                        // .background(Color.yellow)
                        .frame(width: 500, height: 100, alignment: .center)
                        .position(x: 500, y: 660)
                }

                // ~-~-~-~-~~-~-~-~-~~-~-~-~-~~-~-~-~-~~-~-~-~-~~-~-~-~-~
                // MARK: File Animation Area
                // ~-~-~-~-~~-~-~-~-~~-~-~-~-~~-~-~-~-~~-~-~-~-~~-~-~-~-~

                ZStack {

                    ForEach(0..<files.count, id: \.self) { i in
                        FileView(x: files[i].x,
                                 y: files[i].y,
                                 popInAnimation: $files[i].popIn,
                                 eraseAnimation: $files[i].erase,
                                 gracefulPause: $files[i].pause,
                                 reset: $files[i].reset,
                                 file_jsons: file_animations)
                    }
                }
            }
            .onDrop(of: ["public.url", "public.file-url"], isTargeted: nil) { (items) -> Bool in

                handle_drop(items: items)
                return true
            }
            .onReceive(NotificationCenter.default.publisher(for: Notification.Name("pause_toggle"))) { _ in
//                if let tabTag = notification.object as? Int {
//                    self.selection = tabTag
//                }
                self.shouldPause = true
            }
            .alert(isPresented: self.$showingAlert) {
                Alert(
                    title: Text("Are you TOTALLY SURE you want to delete these files?"),
                    message: Text("There is *no* undo!"),
                    primaryButton: .destructive(Text("DESTROY")) {
                        print("Deleting...")
                        handle_drop(items: last_dropped_items)
                    },
                    secondaryButton: .cancel()
                )
            }
        }
        .frame(width: 1000, height: 700)
        .background(Color.black)
    }

    /// Handle whatver users drag and drop onto the app
    /// - Parameter items: files and folders, possibly both
    func handle_drop(items: [NSItemProvider]) {

        let groupDeletes = DispatchGroup()
        toggle_erasing_animation()
        total_bytes_to_erase = 0
        bytes_written = 0
        num_of_files = 0

        for item in items {
            if let identifier = item.registeredTypeIdentifiers.first {
                if identifier == "public.url" || identifier == "public.file-url" {

                    groupDeletes.enter()
                    print("groupDeletes.enter()")
                    item.loadItem(forTypeIdentifier: identifier, options: nil) { (urlData, _) in

                        if let urlData = urlData as? Data {
                            let urll = NSURL(absoluteURLWithDataRepresentation: urlData, relativeTo: nil) as URL
                            Analytics.trackEvent("Files Erased", withProperties: ["url_count": "\(items.count)"])

                            eraser_gun(url: urll, groupDeletes: groupDeletes)
                        }
                    }
                }
            }
        }

        groupDeletes.notify(queue: DispatchQueue.global()) {

            print("ERASURE COMPLETE")

            hex_text_overlay = ""
            current_filename = ""
            self.shouldPause = false
            self.popIn = false
            self.gracefulPauseFiles = true
            self.blackholeAnimating = false
        }
    }

    /// Implement the secure erasing ( like the Recoom Boom )
    /// - Parameters:
    ///   - url: Describes a file or folder
    ///   - groupDeletes: DispatchGroup that waits for all deletion threads to finish
    func eraser_gun(url: URL, groupDeletes: DispatchGroup) {

        // let's see if we can help the energy impacts by using lower priority threads
        DispatchQueue.global(qos: .utility).async {

            let fm = FileManager.default
            let delegate = CustomFileManagerDelegate()
            fm.delegate = delegate

            #if UNIT_TEST
                print("about to erase")
                sleep(5)
                print("done fake erasing")

                groupDeletes.leave()
                print("groupDeletes.leave()")
                return  // disable the actual erasing for now
            #endif

            do {

                print("Try to read -- \(url.path)")

                // let files = try fm.contentsOfDirectory(atPath: url.path)
    //            for file in files {
    //                print("found file -- \(file)")
    //            }
                let resourceKeys: [URLResourceKey] = [.creationDateKey, .isDirectoryKey, .fileSizeKey]
                var enumerator = fm.enumerator(at: url, includingPropertiesForKeys: resourceKeys)!
                var total_bytes: UInt64 = 0

                // this is what to do when directories are dropped
                // 1st pass through files to generate total sizes / determine if multiple things are dropped
                for case let fileURL as URL in enumerator {

                    total_bytes += fileURL.fileSize
                    print("total_bytes [\(total_bytes)] += file -- \(fileURL.fileSize)")
                }
                // else its a single file
                if total_bytes == 0 {
                    let resourceValues = try url.resourceValues(forKeys: Set(resourceKeys))

                    if let fileSize = resourceValues.fileSize {
                        total_bytes += UInt64(fileSize)
                        print("total_bytes [\(total_bytes)] += file -- \(fileSize)")
                    }
                }

                total_bytes_to_erase += Double(total_bytes)
                print("total_bytes_to_erase=\(total_bytes_to_erase)")

                enumerator = fm.enumerator(at: url, includingPropertiesForKeys: resourceKeys)!

                for case let fileURL as URL in enumerator {
                    let resourceValues = try fileURL.resourceValues(forKeys: Set(resourceKeys))
                    // print(fileURL.path, resourceValues.fileSize, resourceValues.creationDate!, resourceValues.isDirectory!)

                    if shouldPause {
                        break
                    }

                    if let file_size = resourceValues.fileSize {

                        secure_eraser(file: fileURL, size: file_size)

                        num_of_files += 1
                        try fm.removeItem(at: fileURL)

                    }
                }

                // remove the dropped folder too
                if !shouldPause {

                    if url.isFileURL {
                        let resourceValues = try url.resourceValues(forKeys: Set(resourceKeys))
                        if let file_size = resourceValues.fileSize {
                            secure_eraser(file: url, size: file_size)
                        }
                    }

                    num_of_files += 1
                    try fm.removeItem(at: url)
                }
                print("blackholeAnimating = false, areFilesAnimating = false")

            } catch {
                print("ERROR getting contents of folder! \(error)")
            }

            sleep(1)

            Analytics.trackEvent("Files Erased Completed", withProperties: ["files_erased": "\(num_of_files)"])

            total_num_of_files += num_of_files

            print("bytes_written = \(bytes_written)")
            UserDefaults.increment(val: num_of_files, key: UserDefaultsConstants.files_destroyed)
            UserDefaults.increment(val: Int(Double(bytes_written) / 1e6), key: UserDefaultsConstants.megabytes_destroyed)

            groupDeletes.leave()
        }
    }

    /// Implement secure file erasing methods
    /// - Parameters:
    ///   - file: URL descriptor
    ///   - size: size of file
    func secure_eraser(file: URL, size: Int) {

        if let fileHandle = FileHandle(forWritingAtPath: file.path) {

            current_filename = file.lastPathComponent

            var test_bytes_written = 0
            var text_nums = ""
            fileHandle.seek(toFileOffset: 0)

            let write_loops = 400
            let sparse_size = size / write_loops

            // we'll base the randomness on the size of the file
            let result = Array(repeating: 0, count: sparse_size)

            //
            // Swift 4.2 implemented SE-0202: Random Unification so this is a cryptographically secure randomizer that’s baked right into the core of the language!
            let shuffledNumbers = result.map { _ in Int.random(in: 0...size) }

            print("secure_eraser size=\(size) writing sparse_array=\(sparse_size) write_loops=\(write_loops) randomized array of size=\(shuffledNumbers.count) to the file --")

            let data = Data(bytes: shuffledNumbers, count: shuffledNumbers.count)

            /// A note on older MacOS systems running this erasure algorithm
            /// I noticed the loop can be kind of slow on 2017 and earlier models (what I originally developed this on)
            /// Apple Silicon is brutally fast and so keep that in mind... not everyone has upgraded or will upgrade!
            /// It's hard to tune for everyone, so I hope for now this is OK
            /// Can modify as needed if anyone finds a huge problem

            // Loop over the file "sparse write loop" times (const 400 right now)
            // write the same randomized byte pattern times to the file
            do {
                for i in 1...write_loops {

                    let offset = UInt64(i * data.count)
                    // fileHandle.write(data)
                    try fileHandle.write(contentsOf: data)  // attempt to upgrade deprecated calls
                    fileHandle.seek(toFileOffset: offset)

                    text_nums = String(format: "0x%02x\n", offset)
                    hex_text_overlay = text_nums
                    test_bytes_written += Int(data.count)
                    // print("seeking to \(offset)")

                    // Update inner for loop values so the progress bar updates more often
                    if i % 10 > 0 {
                        bytes_display_lock.lock()
                        bytes_written += Double(test_bytes_written)
                        bytes_display_lock.unlock()
                        test_bytes_written = 0
                    }

                    /// Play around with slowing down the erasure for larger files so the user can enjoy watching the big file erase :)
                    /// Peresonally I like to watch it
                    let special_size_megs = 1024 * 1024 * 5  // this number is arbitrary and can be tuned
                    if size > special_size_megs {
                        usleep(UInt32(10000))
                    }
                }
                // print("bytes_written=\(bytes_written), test_bytes_written=\(test_bytes_written)")

                // write the leftovers
                let remainder = size - (write_loops * sparse_size)
                let ending_data = Data(bytes: shuffledNumbers, count: remainder)
                fileHandle.write(ending_data)
                test_bytes_written += Int(ending_data.count)
                // print("writing remainder=\(remainder)")

                bytes_display_lock.lock()
                bytes_written += Double(test_bytes_written)
                bytes_display_lock.unlock()
            } catch { print("ERROR seeking / writing \(error)") }

            // usleep(UInt32(100))  // delay this intense CPU loop if the Debugger can't terminate the process

            print("secure_eraser Writing \(file.relativePath) size=\(file.fileSize) \(write_loops) times, test_bytes_written=\(test_bytes_written)")

            // this is even more secure if we can mess up the file descriptors dates
            // As an extra precaution I change the dates of the file so the
            // original dates are hidden if you try to recover the file
            do {
                let date = Date()  // aka todays date
                let attributes = [FileAttributeKey.creationDate: date, FileAttributeKey.modificationDate: date]
                try FileManager.default.setAttributes(attributes, ofItemAtPath: file.path)
                // print("setting \(attributes) to \(date)")
            } catch {
                print("ERROR setting creation of file! \(error)")
            }

            fileHandle.closeFile()
        }
    }

    /// Contains the animation logic for the files as they appear, then swirl into the black voidness 
    func toggle_erasing_animation() {

        print("toggle_erasing_animation()")
        let radius_px = 300.0
        let event_horizon_px: CGFloat = 200.0

        blackholeAnimating = true
        popIn = true

        if self.isFileAnimationThreadRunning == false {
            self.isFileAnimationThreadRunning = true
            DispatchQueue.global(qos: .userInteractive).async {

                var speed_factor = CGFloat(0)

                // keep the animation thread alive while actively working
                while self.blackholeAnimating {

                    for i in 0...files.count - 1 {

                        if files[i].animating == false {

                            // generate a randomized angle from the center of the blackhole for each file
                            // keeps the animation more interesting :)
                            // other ideas include randomizing the radius, the speed, etc..
                            let angle = Double.random(in: 0.0...1.0) * Double.pi * 2
                            let x = cos(angle) * radius_px
                            let y = sin(angle) * radius_px
                            // print("\(i) generating random angle = \(angle / Double.pi * 180), \(atan2(y,x)  / Double.pi * 180), \(x),\(y) dist=\(CGPointDistance(from: CGPoint(x: x, y: y),to: CGPoint.zero))")
                            files[i].x = CGFloat(x)
                            files[i].y = CGFloat(y)
                            files[i].animating = true
                            files[i].popIn = true
                            files[i].erase = false
                            files[i].pause = false
                            files[i].isErased = false

                            speed_factor = CGFloat.random(in: 1.0...5)
                        }

                        // print("\(i) dist=\(CGPointDistance(from: CGPoint(x: files[i].x, y: files[i].y), to: CGPoint.zero))")

                        if files[i].isErased == false {
                            if CGPointDistance(from: CGPoint(x: files[i].x, y: files[i].y), to: CGPoint.zero) < event_horizon_px {

                                files[i].erase = true
                                files[i].isErased = true
                            }
                        }

                        if files[i].reset {
                            // print("\(i) detecting reset")
                            files[i].reset = false
                            files[i].animating = false
                        }

                        // try to bring the x/y values to zero (the center of nothingness)
                        // future work -- could make this more complex to draw a more interesting looking path
                        if files[i].x > 0 {
                            files[i].x -= speed_factor
                        } else {
                            files[i].x += speed_factor
                        }
                        if files[i].y > 0 {
                            files[i].y -= speed_factor
                        } else {
                            files[i].y += speed_factor
                        }
                    }

                    usleep(UInt32(1e5)) // animation update throttle
                }

                // Reset animation state when the erasing is done
                for i in 0...files.count - 1 {
                    files[i].animating = false
                    files[i].pause = true
                }

                print("file moving thread exiting")
                self.isFileAnimationThreadRunning = false
            }
        }
    }

    // thank you to the always amazing HackingWithSwift and the 3,000 year old Pythagoras
    func CGPointDistanceSquared(from: CGPoint, to: CGPoint) -> CGFloat {
        return (from.x - to.x) * (from.x - to.x) + (from.y - to.y) * (from.y - to.y)
    }
    // supposedly this square root is very slow, but it seems fine here
    func CGPointDistance(from: CGPoint, to: CGPoint) -> CGFloat {
        return sqrt(CGPointDistanceSquared(from: from, to: to))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            BlackHoleView()
        }
    }
}
