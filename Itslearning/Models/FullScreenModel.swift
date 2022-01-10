//  SPDX-License-Identifier: CC-BY-NC-SA-4.0
//  Copyright (C) 2022 Mathias Gredal
//
//  FullScreenModel.swift
//  Itslearning

import Foundation
import SwiftUI
import Combine

public class FullScreenModel: ObservableObject {
    @Published var isFullScreen = false;

    // TODO: Make a wrapper around this behaviour
    var enterFullScreenCancellabel : AnyCancellable?
    var exitFullScreenCancellabel : AnyCancellable?
    
    init() {        
        enterFullScreenCancellabel = NotificationCenter.default.publisher(for: NSWindow.willEnterFullScreenNotification).sink(receiveValue: { _ in
            self.isFullScreen = true
        })
        
        exitFullScreenCancellabel = NotificationCenter.default.publisher(for: NSWindow.willExitFullScreenNotification).sink(receiveValue: { _ in
            self.isFullScreen = false
        })
    }
}
