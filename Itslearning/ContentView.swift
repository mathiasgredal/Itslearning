//
//  ContentView.swift
//  Itslearning
//
//  Created by Mathias Gredal on 15/09/2021.
//

import Cocoa
import SwiftUI
import ItslearningAPI
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
