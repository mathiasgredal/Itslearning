//
//  FullScreenModel.swift
//  Itslearning
//
//  Created by Mathias Gredal on 20/10/2021.
//

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
