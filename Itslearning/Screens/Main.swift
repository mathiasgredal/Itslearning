//  SPDX-License-Identifier: CC-BY-NC-SA-4.0
//  Copyright (C) 2022 Mathias Gredal
//
//  Main.swift
//  Itslearning

import SwiftUI

struct Main: View {
    @EnvironmentObject var fileProviderComm: FileProviderComm
    @EnvironmentObject var authHandler: AuthHandler
    @ObservedObject var viewModel: FullScreenModel = FullScreenModel();
    @State var selection: Int? = 0;
    
    var body: some View {
        NavigationView {
            VStack {
                // This spacer makes fullscreen look nicer, there might be a better fix though
                if viewModel.isFullScreen { Spacer()  }

                List {
                    NavigationLink(destination: Home().environmentObject(authHandler).environmentObject(fileProviderComm), tag: 0, selection: $selection, label: {Label("Home", systemImage: "house")})
                    NavigationLink(destination: Controls(), tag: 1, selection: $selection, label: {Label("Controls", systemImage: "hammer")})
                    NavigationLink(destination: Console(), tag: 2, selection: $selection, label: {Label("Console", systemImage: "note.text")})
                    NavigationLink(destination: Settings(),tag: 3,  selection: $selection, label: {Label("Settings", systemImage: "gearshape")})
                }
                Divider()
                Button(action: {
                    authHandler.LogOut()
                }, label: {
                    HStack {
                        Image(systemName: "arrowshape.turn.up.left.circle")
                        Text("Logout")
                    }
                }).padding(EdgeInsets(top: 0, leading: 0, bottom: 8, trailing: 0))
            }
        }
    }
}
