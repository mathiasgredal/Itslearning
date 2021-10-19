//
//  ContentView.swift
//  Itslearning
//
//  Created by Mathias Gredal on 15/09/2021.
//

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



//        NavigationView {
//            List (selection: $selection){
//                NavigationLink(destination: Home(fileProviderComm: $fileProviderComm, authHandler: $authHandler), tag: 0, selection: $selection, label: {Label("Home", systemImage: "house")})
//                NavigationLink(destination: Controls(), tag: 1, selection: $selection, label: {Label("Controls", systemImage: "hammer")})
//                NavigationLink(destination: Settings(),tag: 2,  selection: $selection, label: {Label("Settings", systemImage: "gearshape")})
//                Spacer()
//                NavigationLink(destination: Text("Should be combined button, with name and system image defined by whether fileprovider is mounted or not"), tag: 3,  selection: $selection, label: {Label("Eject", systemImage: "eject")})
//                NavigationLink(destination: Text("Same as eject"),tag: 4,  selection: $selection,  label: {Label("Mount", systemImage: "mount")})
//                NavigationLink(destination: Text("Obviously, shouldn't not have a navigation screen"),tag: 5,  selection: $selection,  label: {Label("Log off", systemImage: "arrowshape.turn.up.left.circle")})
//            }.onAppear {
//                self.selection = 0
//            }.navigationTitle("Master")
//        }
//        NavigationView {
//            List {
//                Label("Home", systemImage: "house")
//                Label("Controls", systemImage: "hammer")
//                Label("Settings", systemImage: "gearshape")
//                Label("Disconnect", systemImage: "eject")
//                Label("Connect", systemImage: "mount")
//                Label("Log off", systemImage: "arrowshape.turn.up.left.circle")
//                //Label("Log off", systemImage: "rectangle.portrait.and.arrow.right")
//            }
//            .navigationTitle("Learn")
//        }
