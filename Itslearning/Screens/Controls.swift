//  SPDX-License-Identifier: CC-BY-NC-SA-4.0
//  Copyright (C) 2022 Mathias Gredal
//
//  Controls.swift
//  Itslearning

import SwiftUI

struct Controls: View {
    @EnvironmentObject var authHandler: AuthHandler
    
    // TODO: Perhaps make each groupbox it's own component
    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                GroupBox(label:Label("OAuth2 info", systemImage: "lock.shield")) {
                    HStack() {
                        VStack(alignment: .leading) {
                            Text("Access token").padding(2)
                            Text("Refresh token").padding(2)
                            Text("Last token update").padding(2)
                        }
                        VStack(alignment: .leading) {
                            Text("\(authHandler.GetAuthToken()?.accessToken ?? "Unknown")").padding(2)
                                .border(.black)
                                .background(Color(NSColor.textBackgroundColor))
                                .truncationMode(.tail)
                                .lineLimit(1)
                            Text("\(authHandler.GetAuthToken()?.refreshToken ?? "Unknown")").padding(2)
                                .border(.black)
                                .background(Color(NSColor.textBackgroundColor))
                                .truncationMode(.tail)
                                .lineLimit(1)
                            Text("\(authHandler.GetAuthToken()?.accessTokenDate.getFormattedDate() ?? "Unknown")").padding(2)
                                .border(.black)
                                .background(Color(NSColor.textBackgroundColor))
                                .truncationMode(.tail)
                                .lineLimit(1)
                        }
                        Spacer()
                    }
                }
                GroupBox(label:Label("Statistics", systemImage: "building.columns")) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Num. of HTTP requests: NaN")
                            Text("Files downloaded: NaN")
                            Text("Amount of downloaded data: NaN GB")
                        }
                        Spacer()
                    }
                }
                Spacer()
            }.padding()
        }
    }
}

struct Controls_Previews: PreviewProvider {
    static var previews: some View {
        Controls()
    }
}
