//
//  ContentView.swift
//  Blackhole2020
//
//  Created by Jonathan Buehler on 12/24/20.
//

import SwiftUI
import AVKit
//import SDWebImageSwiftUI

let DEBUG_ERASE = true // enable to fake erasing (and save your real files)

let MainViewHeight = CGFloat(700)

// The main black hole view for now
struct BlackHoleView: View {
    
    let file_width: CGFloat = 200
    let file_height: CGFloat = 150
    
    var isErasing = false
    var blackhole_url = Bundle.main.url(forResource: "black-hole", withExtension: "mp4")!
    
    @State var animationTime = 5.0
    let timer = Timer.publish(every: 2, on: .main, in: .common).autoconnect()
    
    // this may not be enough on its own to look nice
    @State private var showFileAnimations = false
    @State var areFilesAnimating = false
    @State var gracefulPauseFiles = false
    @State var blackholeAnimating = false
    @State var num_of_files = 0
    @State var bytes_written = 0
    @State var hex_text_overlay = ""
    @State var current_filename = ""
    
    // hex text
    @State var hex_text_opacity = 1.0
    @State var hex_text_x: CGFloat = 850
    @State var hex_text_y: CGFloat = 85
    @State var hex_scale: CGFloat = 1.0
    
    @ObservedObject var videoItem: VideoItem = VideoItem()
    
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
                    
                    Text("\(num_of_files) files erasered")
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
                        //.animation(/*@START_MENU_TOKEN@*/.easeIn/*@END_MENU_TOKEN@*/)
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
                        
                    
                    Text("bytes erasered")
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
                    FileView(x: -200, y: -200, animating: $areFilesAnimating, gracefulPause: $gracefulPauseFiles)
                    FileView(x: -100, y: -200, animating: $areFilesAnimating, gracefulPause: $gracefulPauseFiles)
                    FileView(x: -100, y: -100, animating: $areFilesAnimating, gracefulPause: $gracefulPauseFiles)
                    FileView(x: 0, y: 0, animating: $areFilesAnimating, gracefulPause: $gracefulPauseFiles)
                    FileView(x: 50, y: 50, animating: $areFilesAnimating, gracefulPause: $gracefulPauseFiles)
                    FileView(x: 100, y: 100, animating: $areFilesAnimating, gracefulPause: $gracefulPauseFiles)
                    FileView(x: 100, y: 200, animating: $areFilesAnimating, gracefulPause: $gracefulPauseFiles)
                    FileView(x: 200, y: 200, animating: $areFilesAnimating, gracefulPause: $gracefulPauseFiles)
                    FileView(x: 150, y: 220, animating: $areFilesAnimating, gracefulPause: $gracefulPauseFiles)
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
    
    // try to erase the files?
    func eraser_gun(url: URL)
    {
//        print("about to erase")
//        sleep(5)
//        print("done fake erasing")
//        return  // disable the actual erasing for now
//
        let fm = FileManager.default
        num_of_files = 0
        
        // at this point let's see if we can help the energy impacts by using lower priority threads
        DispatchQueue.global(qos: .utility).async {
            
            areFilesAnimating = true
            blackholeAnimating = true
            
            do {
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
                
                    // secure erase
                    
                    if let file_size = resourceValues.fileSize {
                        secure_eraser(file: fileURL, size:  file_size)
                        if (!DEBUG_ERASE) {
                            num_of_files += 1
                            try fm.removeItem(at: fileURL)
                        }
                        usleep(UInt32(100))  // its critical to delay this intense CPU loop or even the Debugger can't terminate the process
                    }
                }
                
                // remove the dropped folder too
                if (!DEBUG_ERASE) {
                    
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
            
            areFilesAnimating = false
            gracefulPauseFiles = true
            blackholeAnimating = false
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
            
            print("size=\(size)")
            let write_loops = 400
            let sparse_size = size / write_loops
            
            // we'll base the randomness on the size of the file
            let result = Array(repeating: 0, count: sparse_size)
            
            // this call takes a few seconds even for a 1 megabyte randomized pattern
            let shuffledNumbers = result.map { _ in Int.random(in: 0...size) }
            
            // TODO -- still need to make this run faster...
            
            print("writing sparse_array=\(sparse_size) randomized array of size=\(shuffledNumbers.count) to the file --")
                        
            //let write_loops = size/1024/1024
            let data = Data(bytes: shuffledNumbers, count: shuffledNumbers.count)
            print("Writing \(data) \(write_loops) times")
            
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
                        print("seeking to \(offset)")
                    }
                }
                catch { print("ERROR seeking / writing \(error)") }
            }
//            if (!DEBUG_ERASE) {
//                fileHandle.write(data)
//            }
            
            // this takes too long too, it loops forever across the files
//            for var num in shuffledNumbers {
//                //print(num)
//                let data = Data(bytes: &num, count: 4)
//
//                if (!DEBUG_ERASE) {
//                    fileHandle.write(data)
//                }
//                text_nums = String(format: "0x%02x\n", num)
//                hex_text_overlay = text_nums
//                bytes_written += 4
//            }
            
            // this is even more secure if we can mess up the file descriptors dates
            // As an extra precaution I change the dates of the file so the
            // original dates are hidden if you try to recover the file.
            
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

//            DateTime dt = new DateTime(2037, 1, 1, 0, 0, 0);
//            File.SetCreationTime(filename, dt);
//            File.SetLastAccessTime(filename, dt);
//            File.SetLastWriteTime(filename, dt);
            
            //let array = shuffledNumbers as! NSArray
            fileHandle.closeFile()
        }
    }
    
    // allow the animation loop to run
    func toggle_erasing_animation()
    {
        if (isErasing)
        {
            // spin up the files getting sucked into the blackhole...
            
            // copy from windows
            
            // ideally we do not re-create the animations so we'll need to be crafty about writing this piece
            // the idea is pretty simple but elegant
            // first we setup the views outside of this loop (done here)
            // then we just iterate and play on them with slight delay here
            
            // TODO -- how do we dynamically adjust where the views are? Need to do this anyway so we can move them around using position animations
            
            // lookup for swifty UIs
             
            
            // then we just need to loop them in/out of playing / not playing
            // Maybe just start by rolling with 10 of them
            
            
        }
        else
        {
            
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            BlackHoleView()
        }
    }
}
