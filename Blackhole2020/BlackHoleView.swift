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

let DEBUG_ERASE = false  // enable to fake erasing (and save your real files)
var SECURE_ERASE = false // enable to use crypto-secure erasing

let MainViewHeight = CGFloat(700)

struct AnimatedFileState : Identifiable
{
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

// The main black hole view for now
struct BlackHoleView: View {
    
    let file_width: CGFloat = 200
    let file_height: CGFloat = 150
    
    @State var isFileAnimationThreadRunning = false
    var blackhole_url = Bundle.main.url(forResource: "black-hole", withExtension: "mp4")!
    
    @State var animationTime = 5.0
    let timer = Timer.publish(every: 2, on: .main, in: .common).autoconnect()
    
    // the elegant initializer to create an array
    @State var files = [AnimatedFileState](repeating: AnimatedFileState.init(), count: 10)
    
    @State var eraseFiles = false
    @State var popIn = false
    @State var gracefulPauseFiles = false
    @State var blackholeAnimating = false
    @State var num_of_files = 0
    @State var bytes_written = 0
    @State var hex_text_overlay = ""
    @State var current_filename = ""
    
    // use this to pause / stop the file erasing
    @State var shouldPause = false
    
    // hex text
    @State var hex_text_opacity = 1.0
    @State var hex_text_x: CGFloat = 850
    @State var hex_text_y: CGFloat = 85
    @State var hex_scale: CGFloat = 1.0
    
    // pre-allocate all the JSONs
    var file_animations = [Lottie.Animation]()
    
    @ObservedObject var videoItem: VideoItem = VideoItem()
    
    init()
    {
        //print("blackhole init running")
        
        file_animations.append(Animation.named("File_Disintegration_TopLeft")!)
        file_animations.append(Animation.named("File_Disintegration_BottomLeft")!)
        file_animations.append(Animation.named("File_Disintegration_MidLeft")!)
        file_animations.append(Animation.named("File_Disintegration_TopRight")!)
        file_animations.append(Animation.named("File_Disintegration_BottomRight")!)
        file_animations.append(Animation.named("File_Disintegration_MidRight")!)
        //print("file_animations=\(file_animations.count)")
        
        // disable auto music playing on open (the App Store people dont like it booooo)
        //JonsMusicPlayer.sharedInstance.change_category(cat: .space_synth)
    }
    
    var body: some View {
        VStack {
            ZStack(alignment: .center) {
                // can't use Lottie to generate these its too CPU intensive
                //LottieView(filename: "StarField", autoplay: true)
                
                // crap have to update to MacOS 11 finally... this VideoPlayer replaces the 3rd party github code below but requires OS 11
                //VideoPlayer(player: AVPlayer(url:  Bundle.main.url(forResource: "video", withExtension: "mp4")!))
                Video(url: blackhole_url)
                    .loop(true)
                    .isPlaying($blackholeAnimating)
                    .frame(width: 1000, height: 700)
                
                // TODO -- requires MacOS 11 :(
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
                //.keyboardShortcut("m")
                
                // TODO -- figure out how to draw the purple "file counters" in swiftui
                
                // TODO -- do we display the files current being deleted? It would be more fun... but it doesnt fit anywhere....maybe draw it out a bit

                ZStack {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .frame(width: 200, height: 50, alignment: .center)
                        .foregroundColor(Color.init(hex: 0x721FAE))
                        .position(x: 150, y: 50)
                    RoundedRectangle(cornerRadius: 25.0, style: .continuous)
                        .frame(width: 195, height: 45, alignment: .center)
                        .foregroundColor(.black)
                        .position(x: 150, y: 50)
                    
                    Text("\(num_of_files) files destroyed")
                        .font(.custom("VT323-Regular", size: 16))
                        .fontWeight(.medium)
                        .foregroundColor(Color.white)
                        .multilineTextAlignment(.center)
                        .frame(width: 100, height: 50, alignment: .center)
                        //.background(Color.init(hex: 0x721FAE))
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
                    
                    Text("\(bytes_written)")
                        .font(.custom("VT323-Regular", size: 16))
                        .fontWeight(.medium)
                        .foregroundColor(Color.white)
                        //.multilineTextAlignment(.center)
                        //.lineLimit(1)
                        .frame(width: 200, height: 50, alignment: .center)
                        //.background(Color.blue)
                        .shadow(radius: 5 )
                        .position(x: 850, y: 40)
                        .transition(.opacity)
                    
                    Text(hex_text_overlay)
                    //Text("0x4ff4")
                        .font(.custom("VT323-Regular", size: 16))
                        .fontWeight(.medium)
                        .foregroundColor(Color.white)
                        //.multilineTextAlignment(.center)
                        .lineLimit(2)
                        .frame(width: 200, height: 50, alignment: .center)
                        //.background(Color.blue)
                        //.shadow(radius: 5 )
                        //.scaleEffect(hex_scale)
                        //.animation(.easeIn)
                        .position(x: hex_text_x, y: hex_text_y)
                        //.animation(nil)
                        .opacity(Double(2 - hex_text_opacity))
//                        .animation(
//                            Animation.easeInOut(duration: 0.5)
//                                .delay(1)
//                                .repeatForever()
//                        )
                        //.rotation3DEffect(Angle.degrees(30), axis: (x: 1, y: 0, z: 0))
                        //.animation(.easeInOut)
                    // TODO -- I have no idea what to do with this yet, need to figure out a good animation
//                        .onAppear(perform: {
//                            withAnimation(Animation.easeInOut(duration: 1.5).repeatForever(), {
//                                self.hex_text_opacity = 2
//                                hex_scale = 1.3
//                            })
//                            withAnimation(Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: false), {
//                                //self.hex_text_x = 870
//                                //hex_text_y = 125
//                            })
//                        })
                        //.transition(.opacity)
                        //.id("text-overwrite-" + hex_text_overlay)
                        
                    
                    Text("bytes destroyed")
                        .font(.custom("VT323-Regular", size: 16))
                        .fontWeight(.medium)
                        .foregroundColor(Color.white)
                        //.multilineTextAlignment(.center)
                        //.lineLimit(1)
                        .frame(width: 200, height: 50, alignment: .center)
                        //.background(Color.blue)
                        .shadow(radius: 5 )
                        .position(x: 850, y: 60)
                }
                
                 // TODO -- more reason need OS 11, to use this guy
//                        .onChange(of: text_overwrite, perform: { value in
//
//                        })
                
                Text(current_filename)
                    .font(.custom("VT323-Regular", size: 16))
                    .fontWeight(.medium)
                    .foregroundColor(Color.white)
                    .multilineTextAlignment(.center)
                    //.background(Color.yellow)
                    .frame(width: 500, height: 100, alignment: .center)
                    .position(x: 500, y: 660)
                
                
                // ~-~-~-~-~~-~-~-~-~~-~-~-~-~~-~-~-~-~~-~-~-~-~~-~-~-~-~
                // Manually setup the file animation area
                // ~-~-~-~-~~-~-~-~-~~-~-~-~-~~-~-~-~-~~-~-~-~-~~-~-~-~-~
                
                //.opacity(shouldPlay.wrappedValue ? 1.0 : 0.0)
                //.animation(.spring())
                
                // TODO -- the real elegant way to do this here is use the ForEach loops and run the radius / offset calculation here
                
                ZStack {
                    
                    // funny looking but this is the SwiftUI syntax to iterately declare arrays of views
                    ForEach(0..<files.count, id: \.self) { i in
                        FileView(x: files[i].x, y: files[i].y, popInAnimation: $files[i].popIn, eraseAnimation: $files[i].erase, gracefulPause: $files[i].pause, reset: $files[i].reset, file_jsons: file_animations)
                    }
//                    FileView(x: -200, y: -200, animating: $areFilesAnimating, gracefulPause: $gracefulPauseFiles)
//                    FileView(x: -100, y: -200, animating: $areFilesAnimating, gracefulPause: $gracefulPauseFiles)
//                    FileView(x: -100, y: -100, animating: $areFilesAnimating, gracefulPause: $gracefulPauseFiles)
                    //FileView(x: files[0].x, y: files[0].y, popInAnimation: $files[0].popIn, eraseAnimation: $eraseFiles, gracefulPause: $gracefulPauseFiles)
                        //.position(x: file1_x, y: file1_y)
//                    FileView(x: 50, y: 50, animating: $areFilesAnimating, gracefulPause: $gracefulPauseFiles)
//                    FileView(x: 100, y: 100, animating: $areFilesAnimating, gracefulPause: $gracefulPauseFiles)
//                    FileView(x: 100, y: 200, animating: $areFilesAnimating, gracefulPause: $gracefulPauseFiles)
//                    FileView(x: 200, y: 200, animating: $areFilesAnimating, gracefulPause: $gracefulPauseFiles)
//                    FileView(x: 150, y: 220, animating: $areFilesAnimating, gracefulPause: $gracefulPauseFiles)
                }
                
                // for now...can't get these SwiftUI extensions to work. They don't appear for unknown reasons
//                 AnimatedImage(name: "File_Disintegration_TopLeft.json", isAnimating: $areFilesAnimating)
//                    .customLoopCount(1)
//
//                    .resizable()
//                    .scaledToFit()
//                    .frame(width: file_width, height: file_height, alignment: .center)
//                    .offset(x: -200, y: -150)
                
//                LottieView(filename: "File_Disintegration_TopLeft", width: file_width, height: file_height)
//                    .frame(width: file_width, height: file_height, alignment: .center)
//                    .offset(x: 500, y: -300)
            }
            .onDrop(of: ["public.url","public.file-url"], isTargeted: nil) { (items) -> Bool in
                        
                handle_drop(items: items)
                return true
            }
            .onReceive(NotificationCenter.default.publisher(for: Notification.Name("pause_toggle"))) { notification in
//                if let tabTag = notification.object as? Int {
//                    self.selection = tabTag
//                }
                shouldPause = true
            }
        }
        .frame(width: 1000, height: 700)
        .background(Color.black)
    }
    
    func handle_drop(items: [NSItemProvider]) -> Bool
    {
        if let item = items.first {
            if let identifier = item.registeredTypeIdentifiers.first {
                if identifier == "public.url" || identifier == "public.file-url" {
                    item.loadItem(forTypeIdentifier: identifier, options: nil) { (urlData, error) in
                        
                        if let urlData = urlData as? Data {
                            let urll = NSURL(absoluteURLWithDataRepresentation: urlData, relativeTo: nil) as URL
                            
                            print("onDrop with files = \(urll.absoluteString)")
                            
                            // set to true while we attempt to erase, disable when complete
                            Analytics.trackEvent("Files Erased", withProperties: ["url_count" : "\(items.count)"])
                            
                            eraser_gun(url: urll)
                            
                            print("ERASURE COMPLETE")
                        }
                    }
                }
            }
            return true
        } else { print("item not here")
            return false }
    }
    
    // Implement the secure erasing function
    func eraser_gun(url: URL)
    {
        num_of_files = 0
        bytes_written = 0
        
        // at this point let's see if we can help the energy impacts by using lower priority threads
        DispatchQueue.global(qos: .utility).async {
            
            let fm = FileManager.default
            let delegate = CustomFileManagerDelegate()
            fm.delegate = delegate
            
            // use this block to unit test
//            popIn = true
//            blackholeAnimating = true
//            toggle_erasing_animation()
//
//            print("about to erase")
//            sleep(5)
//            print("done fake erasing")
//
//            popIn = false
//            gracefulPauseFiles = true
//            blackholeAnimating = false
//            return  // disable the actual erasing for now
            
            do {
                popIn = true
                blackholeAnimating = true
                toggle_erasing_animation()
                
                print("Try to read -- \(url.path)")
                //let files = try fm.contentsOfDirectory(atPath: url.path)
                
    //            for file in files {
    //                print("found file -- \(file)")
    //            }
                let resourceKeys : [URLResourceKey] = [.creationDateKey, .isDirectoryKey, .fileSizeKey]
                let enumerator = fm.enumerator(at: url, includingPropertiesForKeys: resourceKeys)!
                
                for case let fileURL as URL in enumerator {
                    let resourceValues = try fileURL.resourceValues(forKeys: Set(resourceKeys))
                    //print(fileURL.path, resourceValues.fileSize, resourceValues.creationDate!, resourceValues.isDirectory!)
                
                    if shouldPause {
                        break
                    }
                    
                    if let file_size = resourceValues.fileSize {
                        secure_eraser(file: fileURL, size:  file_size)
                        if (!DEBUG_ERASE) {
                            num_of_files += 1
                            try fm.removeItem(at: fileURL)
                        }
                    }
                }
                
                // remove the dropped folder too
                if (!DEBUG_ERASE && !shouldPause) {
                    
                    if url.isFileURL {
                        let resourceValues = try url.resourceValues(forKeys: Set(resourceKeys))
                        if let file_size = resourceValues.fileSize {
                            secure_eraser(file: url, size:  file_size)
                        }
                    }
                    
                    num_of_files += 1
                    try fm.removeItem(at: url)
                }
                print("blackholeAnimating = false, areFilesAnimating = false")
                
            }
            catch
            {
                print("ERROR getting contents of folder! \(error)")
            }
            
            hex_text_overlay = ""
            current_filename = ""
            shouldPause = false
            popIn = false
            gracefulPauseFiles = true
            blackholeAnimating = false
            
            Analytics.trackEvent("Files Erased Completed", withProperties: ["files_erased" : "\(num_of_files)"])
            
            //print("bytes_written = \(bytes_written)")
            UserDefaults.increment(val: num_of_files, key: UserDefaultsConstants.files_destroyed)
            UserDefaults.increment(val: Int(Double(bytes_written) / 1e6), key: UserDefaultsConstants.megabytes_destroyed)
        }
    }
    
    // Implement secure file erasing methods
    func secure_eraser(file: URL, size: Int)
    {
        // Swift 4.2 implemented SE-0202: Random Unification so this is a cryptographically secure randomizer that’s baked right into the core of the language! Cool huh!
        if let fileHandle = FileHandle(forWritingAtPath: file.path) {
                        
            current_filename = file.lastPathComponent
            
            var text_nums = ""
            fileHandle.seek(toFileOffset: 0)
     
            if SECURE_ERASE {
            
                //print("secure_eraser size=\(size)")
                let write_loops = 400
                let sparse_size = size / write_loops
                var test_bytes_written = 0
                
                // we'll base the randomness on the size of the file
                let result = Array(repeating: 0, count: sparse_size)
                
                // this call takes a few seconds even for a 1 megabyte randomized pattern
                let shuffledNumbers = result.map { _ in Int.random(in: 0...size) }
                
                // TODO -- still need to make this run faster...
                
                //print("secure_eraser writing sparse_array=\(sparse_size) randomized array of size=\(shuffledNumbers.count) to the file --")
                            
                //let write_loops = size/1024/1024
                let data = Data(bytes: shuffledNumbers, count: shuffledNumbers.count)
                
                // try writing size loops to the file
                if (!DEBUG_ERASE) {
                    do {
                        for i in 1...write_loops {
                            
                            let offset = UInt64(i * data.count)
                            fileHandle.write(data)
                            fileHandle.seek(toFileOffset: offset)
                            
                            text_nums = String(format: "0x%02x\n", offset)
                            hex_text_overlay = text_nums
                            bytes_written += Int(data.count)
                            test_bytes_written += Int(data.count)
                            //print("seeking to \(offset)")
                        }
                        
                        // write the leftovers
                        let remainder = size - (write_loops * sparse_size)
                        let ending_data = Data(bytes: shuffledNumbers, count: remainder)
                        fileHandle.write(ending_data)
                        bytes_written += Int(ending_data.count)
                        //print("writing remainder=\(remainder)")
                    }
                    catch { print("ERROR seeking / writing \(error)") }
                }
                
                usleep(UInt32(100))  // its critical to delay this intense CPU loop or even the Debugger can't terminate the process
            }
            else {
                bytes_written += size
            }
            //print("secure_eraser Writing \(data) \(write_loops) times test_bytes_written=\(test_bytes_written)")
            
            // this is even more secure if we can mess up the file descriptors dates
            // As an extra precaution I change the dates of the file so the
            // original dates are hidden if you try to recover the file
            if (!DEBUG_ERASE) {
                do {
                    let date = Date()  // aka todays date
                    let attributes = [FileAttributeKey.creationDate: date, FileAttributeKey.modificationDate: date]
                    try FileManager.default.setAttributes(attributes, ofItemAtPath: file.path)
                    //print("setting \(attributes) to \(date)")
                }
                catch {
                    print("ERROR setting creation of file! \(error)")
                }
            }
            fileHandle.closeFile()
        }
    }
    
    // allow the animation loop to run
    func toggle_erasing_animation()
    {
        let radius_px = 300.0
        let event_horizon_px: CGFloat = 200.0
        
        if (isFileAnimationThreadRunning == false)
        {
            
            DispatchQueue.global(qos: .background).async {
                
                var speed_factor = CGFloat(0)
                isFileAnimationThreadRunning = true
                
                // keep the animation thread alive while actively working
                while blackholeAnimating
                {
                    // eventually we'll iterate the state of each file
                    for var i in 0...files.count - 1 {
                        
                        if files[i].animating == false {
                            let angle = Double.random(in: 0.0...1.0) * Double.pi * 2
                            let x = cos(angle) * radius_px
                            let y = sin(angle) * radius_px
                            //print("\(i) generating random angle = \(angle / Double.pi * 180), \(atan2(y,x)  / Double.pi * 180), \(x),\(y) dist=\(CGPointDistance(from: CGPoint(x: x, y: y), to: CGPoint.zero))")
                            files[i].x = CGFloat(x)
                            files[i].y = CGFloat(y)
                            files[i].animating = true
                            files[i].popIn = true
                            files[i].erase = false
                            files[i].pause = false
                            files[i].isErased = false
                            
                            speed_factor = CGFloat.random(in: 1.0...5)
                        }
                        
                        //print("\(i) dist=\(CGPointDistance(from: CGPoint(x: files[i].x, y: files[i].y), to: CGPoint.zero))")
                        
                        if files[i].isErased == false {
                            if CGPointDistance(from: CGPoint(x: files[i].x, y: files[i].y), to: CGPoint.zero) < event_horizon_px {
                                
                                files[i].erase = true
                                files[i].isErased = true
                            }
                        }
                        
                        if files[i].reset {
                            //print("\(i) detecting reset")
                            files[i].reset = false
                            files[i].animating = false
                        }
                        
                        // try to bring the x/y values to zero (the center of nothingness)
                        // future work -- could make this more complex to draw a more interesting looking path
                        if files[i].x > 0 {
                            files[i].x -= speed_factor
                        }
                        else {
                            files[i].x += speed_factor
                        }
                        if files[i].y > 0 {
                            files[i].y -= speed_factor
                        }
                        else {
                            files[i].y += speed_factor
                        }
                    }
                    
                    
                    usleep(UInt32(1e5)) // animation update throttle
                }
                
                // Reset animation state when the erasing is done
                for var i in 0...files.count - 1 {
                    files[i].animating = false
                    files[i].pause = true
                }
                
                print("file moving thread exiting")
                isFileAnimationThreadRunning = false
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

