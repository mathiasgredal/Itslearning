//  SPDX-License-Identifier: CC-BY-NC-SA-4.0
//  Copyright (C) 2022 Mathias Gredal
//
//  ContentView.swift
//  Itslearning

import Cocoa
import SwiftUI
import FileProvider
import Combine
import OAuth2

struct ContentView: View {
    @ObservedObject var authHandler: AuthHandler;
    @ObservedObject var fileProviderComm: FileProviderComm;
    
    init() {
        authHandler = AuthHandler();
        fileProviderComm = FileProviderComm();
    }
    
    @ViewBuilder
    var body: some View {
        VStack {
            if authHandler.loading {
                ProgressView()
            } else {
                if authHandler.isLoggedIn {
                    Main().environmentObject(authHandler).environmentObject(fileProviderComm)
                } else {
                    Login().environmentObject(authHandler).environmentObject(fileProviderComm)
                }
            }
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
