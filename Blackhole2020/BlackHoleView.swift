//
//  ContentView.swift
//  Blackhole2020
//
//  Created by Jonathan Buehler on 12/24/20.
//

import SwiftUI

// The main black hole view for now
struct BlackHoleView: View {
    
    let file_width: CGFloat = 150
    let file_height: CGFloat = 200
    
    var isErasing = false
    
    var body: some View {
        VStack {
            ZStack(alignment: .top) {
                LottieView(filename: "StarField", autoplay: true)
                //LottieView(filename: "BlackholeUpdate_Rotation", autoplay: true)
                
//                VStack {
//                    LottieView(filename: "File_Disintegration_TopLeft", width: file_width, height: file_height)
//                    LottieView(filename: "File_Disintegration_TopLeft", width: file_width, height: file_height)
//                    LottieView(filename: "File_Disintegration_TopLeft", width: file_width, height: file_height)
//                    LottieView(filename: "File_Disintegration_TopLeft", width: file_width, height: file_height)
//                    LottieView(filename: "File_Disintegration_TopLeft", width: file_width, height: file_height)
//                    LottieView(filename: "File_Disintegration_TopLeft", width: file_width, height: file_height)
//                }
                
            }
            
        }
        .frame(width: 1000, height: 700)
        .background(Color.black)
        .onDrop(of: ["public.url","public.file-url"], isTargeted: nil) { (items) -> Bool in
                    
            handle_drop(items: items)
            return true
        }
    }
    
    func handle_drop(items: [NSItemProvider]) -> Bool
    {
        if let item = items.first {
            if let identifier = item.registeredTypeIdentifiers.first {
                
                print("onDrop with identifier = \(identifier)")
                
                if identifier == "public.url" || identifier == "public.file-url" {
                    item.loadItem(forTypeIdentifier: identifier, options: nil) { (urlData, error) in
                        
                        if let urlData = urlData as? Data {
                            let urll = NSURL(absoluteURLWithDataRepresentation: urlData, relativeTo: nil) as URL
                            
                            eraser_gun(url: urll)
                        }
                        
//                        DispatchQueue.main.async {
//                            if let urlData = urlData as? Data {
//                                let urll = NSURL(absoluteURLWithDataRepresentation: urlData, relativeTo: nil) as URL
//                                if let img = NSImage(contentsOf: urll) {
//                                    //self.image = img
//                                    print("got \(urll)")
//                                }
//                            }
//                        }
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
        let fm = FileManager.default
        
        do {
            
            
            print("Try to read -- \(url.path)")
            //let files = try fm.contentsOfDirectory(atPath: url.path)
            
//            for file in files {
//                print("found file -- \(file)")
//            }
            let resourceKeys : [URLResourceKey] = [.creationDateKey, .isDirectoryKey, .fileSizeKey]
            let enumerator = fm.enumerator(at: url, includingPropertiesForKeys: resourceKeys)!
            
            for case let fileURL as URL in enumerator {
                let resourceValues = try fileURL.resourceValues(forKeys: Set(resourceKeys))
                print(fileURL.path, resourceValues.fileSize, resourceValues.creationDate!, resourceValues.isDirectory!)
            
                // secure erase
                
                if let file_size = resourceValues.fileSize {
                    secure_eraser(file: fileURL, size:  file_size)
                    try fm.removeItem(at: fileURL)
                }
                
            }
            
            // remove the dropped folder too
            try fm.removeItem(at: url)
        }
        catch
        {
            print("ERROR getting contents of folder! \(error)")
        }
    }
    
    // Implement secure file erasing methods
    func secure_eraser(file: URL, size: Int)
    {
        // Swift 4.2 implemented SE-0202: Random Unification so this is a cryptographically secure randomizer that’s baked right into the core of the language! Cool huh!
        if let fileHandle = FileHandle(forWritingAtPath: file.path) {
            
            fileHandle.seek(toFileOffset: 0)
            
            // it's like we'll base the randomness on the size of the file
            var result = Array(repeating: 0, count: size / 4)
            let shuffledNumbers = result.map { _ in Int.random(in: 0...size) }
            
            print("writing this randomized array of size=\(shuffledNumbers.count) to the file --")
            for var num in shuffledNumbers {
                //print(num)
                let data = Data(bytes: &num, count: 4)
                fileHandle.write(data)
            }
            
            //let array = shuffledNumbers as! NSArray
            fileHandle.closeFile()
        }
    }
    
    // allow the animation loop to run
    func run_erasing_animation()
    {
        if (isErasing)
        {
            // spin up
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        BlackHoleView()
    }
}
