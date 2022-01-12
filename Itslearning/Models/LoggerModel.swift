//
//  LoggerModel.swift
//  Itslearning
//
//  Created by Mathias Gredal on 2022-01-12.
//

import Foundation

class LoggerModel: ObservableObject {
    @Published var data: String = ""
    init() {
        load()
        // TODO: This will lead to bad performance on large files, we should check if the file was changed since last update
        // Alternativle we could use file watchers for this task
        Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.load), userInfo: nil, repeats: true)
    }
    
    @objc func load() {
        if let filepath = Logging.logfile?.path {
            do {
                let contents = try String(contentsOfFile: filepath)
                DispatchQueue.main.async {
                    self.data = contents
                }
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        } else {
            print("File not found")
        }
    }
}
