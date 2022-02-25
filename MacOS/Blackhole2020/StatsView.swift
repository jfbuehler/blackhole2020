//
//  StatsView.swift
//  Blackhole2020
//
//  Created by Jonathan Buehler on 3/29/21.
//

import SwiftUI

struct StatsView: View {
    
    var files_destroyed: Int = 0
    var megabytes_destroyed: Int = 0
    var visits: Int = 0
    
    var body: some View {
        
        VStack {
//            Text("""
//                    Stats:
//                    """)
//                .font(.custom("VT323-Regular", size: 35))
//                .fontWeight(.medium)
//                .foregroundColor(Color.white)
//                .multilineTextAlignment(.center)
//                .position(x: 40, y: 10)
            Text("""
                    ... Stats ...
                    """)
                .font(.custom("VT323-Regular", size: 35))
                .fontWeight(.medium)
                .foregroundColor(Color.white)
                .multilineTextAlignment(.center)
                //.position(x: 0, y: 0)
                //.frame(width: 200, height: 20, alignment: .center)
            
            HStack {
                Text("""
                        Files Destroyed: \(files_destroyed)
                        """)
                    .font(.custom("VT323-Regular", size: 20))
                    .fontWeight(.medium)
                    .foregroundColor(Color.white)
                    .multilineTextAlignment(.leading)
                    //.position(x: 20, y: 20)
                    //.frame(width: 150, height: 20)
                
            }
            
            HStack {
                Text("""
                        Megabytes Destroyed: \(megabytes_destroyed)
                        """)
                    .font(.custom("VT323-Regular", size: 20))
                    .fontWeight(.medium)
                    .foregroundColor(Color.white)
                    .multilineTextAlignment(.leading)
                    //.position(x: 20, y: 20)
                    //.frame(width: 150, height: 20)
            }
            
            Text("""
                    Visits To The Blackhole: \(visits)
                    """)
                .font(.custom("VT323-Regular", size: 20))
                .fontWeight(.medium)
                .foregroundColor(Color.white)
                .multilineTextAlignment(.leading)
            
            Text("""


                    From Code With Love
                    ❤️ v\(NSApplication.appVersion!) [\(NSApplication.buildVersion!)] ❤️
                    """)
                .font(.custom("VT323-Regular", size: 20))
                .fontWeight(.medium)
                .foregroundColor(Color.white)
                .multilineTextAlignment(.center)
//            Button(action: {
//                let prefix = "url://"
//                let formattedString = prefix
//                guard let url = URL(string: formattedString) else { return }
//
//                    // figure out how to pop email here
//                let service = NSSharingService(named: NSSharingService.Name.composeEmail)!
//                        service.recipients = ["blackhole2020app@gmail.com"]
//                        service.subject = "BlackHole Fan Mail!"
//
//                        service.perform(withItems: [""])
//               }) {
//               Text("Email, Email!!")
//            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding()
        .background(Color.init(hex: 0x111111))
        .shadow(radius: 5)
    }
}

struct StatsView_Previews: PreviewProvider {
    static var previews: some View {
        StatsView()
            .frame(width: 480.0, height: 300.0)
    }
}
