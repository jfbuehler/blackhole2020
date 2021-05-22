//
//  HelpView.swift
//  Blackhole2020
//
//  Created by Jonathan Buehler on 3/7/21.
//

import SwiftUI

struct HelpView: View {
    
    let contact_email = "help@blackhole2020.app"
    var name: String = ""

    var body: some View {
        
        VStack {
            Text("""
                    * Welcome to the BlackHole 2020 Secure File Eraser *\n
                 """)
                .font(.custom("VT323-Regular", size: 34))
                .fontWeight(.medium)
                .foregroundColor(Color.white)
                .multilineTextAlignment(.center)
            Text("""
                    - Please drag and drop files/folders on to the app to destroy them forever
                    - Press Space Bar to stop the destruction
                    - Press ⌘+m to toggle music on/off
                    - Press ⌘+s to display some stats

                    Please contact \(contact_email) or tap the button below with love / shade / complaints / joy \n
                    Happy obliteration of your files
                    """)
                .font(.custom("VT323-Regular", size: 26))
                .fontWeight(.medium)
                .foregroundColor(Color.white)
                .multilineTextAlignment(.leading)
                .padding(.leading, 55.0)
            Text("""

                 From Code With Love
                 ❤️ v\(NSApplication.appVersion!) [\(NSApplication.buildVersion!)] ❤️
                 """)
                .font(.custom("VT323-Regular", size: 30))
                .fontWeight(.medium)
                .foregroundColor(Color.white)
                .multilineTextAlignment(.center)
            Button(action: {
                let prefix = "url://"
                let formattedString = prefix
                guard let url = URL(string: formattedString) else { return }
                                    
                let service = NSSharingService(named: NSSharingService.Name.composeEmail)!
                        service.recipients = [contact_email]
                        service.subject = "BlackHole Fan Mail!"

                        service.perform(withItems: [""])
               }) {
               Text("Email, Email")
                    .font(.custom("VT323-Regular", size: 20))
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
            .frame(width: 800.0, height: 600.0)
    }
}
