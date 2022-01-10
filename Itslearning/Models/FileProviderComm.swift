//  SPDX-License-Identifier: CC-BY-NC-SA-4.0
//  Copyright (C) 2022 Mathias Gredal
//
//  FileProviderComm.swift
//  Itslearning

import Foundation
import FileProvider
import Combine

public class FileProviderComm : NSObject, ObservableObject {
    let identifier = NSFileProviderDomainIdentifier("gredal.itslearning.itslearningfileprovider")
    let domain: NSFileProviderDomain
    let manager: NSFileProviderManager
    
    override init() {
        self.domain = NSFileProviderDomain(identifier: identifier, displayName:"Itslearning")
        self.manager = NSFileProviderManager.init(for: domain)!
        super.init()
        
        UserDefaults.sharedContainerDefaults.set("test 1" as AnyObject, forKey: "key1")
        UserDefaults.sharedContainerDefaults.synchronize()
    }
    
    func register() {
        NSFileProviderManager.add(domain) { error in
            print("Add file provider domain: \(error as NSError?)")
        }
    }
    
    func unregister() {
        NSFileProviderManager.remove(domain) { error in
            print("Add file provider domain: \(error as NSError?)")
        }
    }
}
