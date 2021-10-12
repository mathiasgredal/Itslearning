//
//  Login.swift
//  Itslearning
//
//  Created by Mathias Gredal on 16/09/2021.
//

import SwiftUI
import Combine

struct Login: View {
    @EnvironmentObject var authHandler: AuthHandler
    @EnvironmentObject var fileProviderComm: FileProviderComm

    var body: some View {
        VStack {
            Text("Please login")
            Button("Load FP") {
                do {
                    try fileProviderComm.register()
                } catch {
                    print("Error signing in") // TODO: Show this in the ui through alert perhaps
                }
                
            }
            Button("Unload FP") {
                do {
                    try fileProviderComm.unregister()
                } catch {
                    print("Error signing in") // TODO: Show this in the ui through alert perhaps
                }
                
            }
            Button("Login") {
                do {
                    try authHandler.SignIn()
                } catch {
                    print("Error signing in") // TODO: Show this in the ui through alert perhaps
                }
                
            }
        }
        
    }
}

