//
//  ContentView.swift
//  Blackhole2020
//
//  Created by Jonathan Buehler on 12/24/20.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            ZStack {
                LottieView(filename: "StarField", autoplay: true)
                LottieView(filename: "BlackholeUpdate_Rotation", autoplay: true)
                
                LottieView(filename: "File_Disintegration_TopLeft", width: 200)
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
