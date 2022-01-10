//  SPDX-License-Identifier: CC-BY-NC-SA-4.0
//  Copyright (C) 2022 Mathias Gredal
//
//  Login.swift
//  Itslearning

import SwiftUI
import Combine

struct Login: View {
    @EnvironmentObject var authHandler: AuthHandler
    @EnvironmentObject var fileProviderComm: FileProviderComm

    var body: some View {
        VStack {
            Text("Please login")
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

