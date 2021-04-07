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
                    Welcome to the BlackHole 2020 Secure File Eraser! \n
                    Please drag and drop files/folders on to the app to destroy them forever!! \n
                    Press Space Bar to stop the destruction. \n
                    Press ⌘+m to toggle music on/off. \n
                    Please contact blackhole2020app@gmail.com or tap the button below with love / shade / complaints / joy \n
                    Happy obliteration of your files =]
                    """)
                .font(.custom("VT323-Regular", size: 16))
                .fontWeight(.medium)
                .foregroundColor(Color.white)
                .multilineTextAlignment(.center)
            Button(action: {
                let prefix = "url://"
                let formattedString = prefix
                guard let url = URL(string: formattedString) else { return }
                
                    // figure out how to pop email here
                let service = NSSharingService(named: NSSharingService.Name.composeEmail)!
                        service.recipients = ["blackhole2020app@gmail.com"]
                        service.subject = "BlackHole Fan Mail!"

                        service.perform(withItems: [""])
               }) {
               Text("Email, Email!!")
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
        .background(Color.init(hex: 0x111111))
        .shadow(radius: 5)
    }
}

struct HelpView_Previews: PreviewProvider {
    static var previews: some View {
        HelpView()
    }
}
