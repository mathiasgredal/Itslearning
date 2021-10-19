//
//  Home.swift
//  Itslearning
//
//  Created by Mathias Gredal on 15/09/2021.
//

import SwiftUI
import Alamofire
import Foundation


struct Home: View {
    @EnvironmentObject var fileProviderComm: FileProviderComm
    @EnvironmentObject var authHandler: AuthHandler
    
    var body: some View {
        VStack {
            Button(action: {
                fileProviderComm.unregister()
            }, label: {
                Text("Unregister FP")
            })
            Button(action: {
                fileProviderComm.register()
            }, label: {
                Text("Register FP")
            })
            Button(action: {
                fileProviderComm.manager.signalEnumerator(for: .rootContainer) { error in
                    if error != nil {
                        print("Error: \(String(describing: error))")
                    }
                }
            }, label: {
                Text("Reload")
            })
            Button( action: {
                let id = "R12502_299400"
                switch ConvertIdToType(id: id) {
                case .Course(let courseId):
                    print("Course Id: " + String(courseId))
                    break;
                case .Resource(let courseId, let resourceId):
                    print("Resource id: " + String(courseId) + ", " + String(resourceId))
                    break;
                default:
                    print("Error")
                }
//                authHandler.GetRequest(url: "https://sdu.itslearning.com/Folder/processfolder.aspx?FolderID=331920") { response in
//                    guard let data = response.data else {
//                        print("Error: \(String(describing: response.error))")
//                        return
//                    }
//
//                    print(data)
//                }
//
//                authHandler.GetResources(course: 12507, folder: 0) { resource in
//                    print(resource)
//                }
                
            }, label: {
                Text("Test API")
            })
            
            Button( action: {
                print(authHandler.GetAuthToken() ?? "No auth token")
            }, label: {
                Text("Print token")
            })
            
        }
    }
}


