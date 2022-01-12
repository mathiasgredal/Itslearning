//  SPDX-License-Identifier: CC-BY-NC-SA-4.0
//  Copyright (C) 2022 Mathias Gredal
//
//  Console.swift
//  Itslearning

import SwiftUI


struct Console: View {
    @ObservedObject var model = LoggerModel()
    
    var body: some View {
        VStack(alignment: .leading) {
            ScrollView {
                Text(model.data).font(.system(.body, design: .monospaced)).frame(maxWidth: .infinity, alignment: .leading)
            }.padding(5).background(Color(NSColor.alternatingContentBackgroundColors[1])).cornerRadius(5)
            HStack {
                Button("Clear Log") {
                    Logging.Log(message: "Clear log not implemented", source: .MainApp)
                }
                Button("Open in Finder") {
                    Logging.Log(message: "Open in finder not implemented", source: .MainApp)
                }
            }.frame(alignment: .leading)
        }.padding()
    }
}

struct Console_Previews: PreviewProvider {
    static var previews: some View {
        Console()
    }
}
