//
//  HelpView.swift
//  Blackhole2020
//
//  Created by Jonathan Buehler on 3/7/21.
//

import SwiftUI

struct HelpView: View {
    
    var name: String = ""

    var body: some View {
        
        VStack {
            Text("""
                    Welcome to the Secure File Eraser BlackHole 2020! \n
                    Please drag and drop files/folders on to the app to erase! \n
                    Press Space Bar to stop. \n
                    Please contact blackhole2020app@gmail.com for any questions! \n
                    Happy erasure of your files =]
                    """)
                .font(.custom("VT323-Regular", size: 16))
                .fontWeight(.medium)
                .foregroundColor(Color.white)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
        .background(Color.black)
    }
}

struct HelpView_Previews: PreviewProvider {
    static var previews: some View {
        HelpView()
    }
}
