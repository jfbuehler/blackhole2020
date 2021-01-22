//
//  ContentView.swift
//  Blackhole2020
//
//  Created by Jonathan Buehler on 12/24/20.
//

import SwiftUI

struct ContentView: View {
    
    let file_width: CGFloat = 150
    let file_height: CGFloat = 200
    
    var body: some View {
        VStack {
            ZStack(alignment: .top) {
                LottieView(filename: "StarField", autoplay: true)
                LottieView(filename: "BlackholeUpdate_Rotation", autoplay: true)
                
                VStack {
                    LottieView(filename: "File_Disintegration_TopLeft", width: file_width, height: file_height)
                    LottieView(filename: "File_Disintegration_TopLeft", width: file_width, height: file_height)
                    LottieView(filename: "File_Disintegration_TopLeft", width: file_width, height: file_height)
                    LottieView(filename: "File_Disintegration_TopLeft", width: file_width, height: file_height)
                    LottieView(filename: "File_Disintegration_TopLeft", width: file_width, height: file_height)
                    LottieView(filename: "File_Disintegration_TopLeft", width: file_width, height: file_height)
                }
            }
            
        }
        .frame(width: 1400, height: 900)
        .background(Color.black)
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
