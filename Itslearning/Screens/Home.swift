//
//  Home.swift
//  Itslearning
//
//  Created by Mathias Gredal on 15/09/2021.
//

import SwiftUI
import Alamofire

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let welcome = try? newJSONDecoder().decode(Welcome.self, from: jsonData)

import Foundation


struct Home: View {
    @EnvironmentObject var fileProviderComm: FileProviderComm
    @EnvironmentObject var authHandler: AuthHandler
    
    var body: some View {
        VStack {
            Button(action: {
                fileProviderComm.unregister()
            }, label: {
                Text("Unregister FP")
            })
            Button(action: {
                fileProviderComm.register()
            }, label: {
                Text("Register FP")
            })
            Button(action: {
                fileProviderComm.manager.signalEnumerator(for: .rootContainer) { error in
                    if error != nil {
                        print("Error: \(String(describing: error))")
                    }
                }
            }, label: {
                Text("Reload")
            })
            Button(action: {
                authHandler.LogOut()
            }, label: {
                Text("Logout")
            })
            Button( action: {
                authHandler.GetResources(course: 12507, folder: 0) { resource in
                    print(resource)
                }
            }, label: {
                Text("Test API")
            })
            
        }
    }
}


