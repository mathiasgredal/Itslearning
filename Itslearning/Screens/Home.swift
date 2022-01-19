//  SPDX-License-Identifier: CC-BY-NC-SA-4.0
//  Copyright (C) 2022 Mathias Gredal
//
//  Home.swift
//  Itslearning

import SwiftUI
import Alamofire
import Foundation
import FileProvider


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
            Button( action: {
                authHandler.ReloadAuthToken(completion: { status in
                    Logging.Log(message: "Reloaded token", source: .MainApp)
                })
            }, label: {
                Text("Test API")
            })
            
            Button( action: {
                guard var authToken = authHandler.GetAuthToken() else {
                    return
                }
                
                authToken.accessToken = "hello"
                let encoder = JSONEncoder()
                do {
                    let data = try encoder.encode(authToken)
                    UserDefaults.sharedContainerDefaults.set(data, forKey: "authToken")
                } catch {
                    print("Error")
                }
                
            }, label: {
                Text("Clear access token")
            })
            
        }
    }
}


