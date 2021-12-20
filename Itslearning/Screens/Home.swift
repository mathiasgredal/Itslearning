//
//  Home.swift
//  Itslearning
//
//  Created by Mathias Gredal on 15/09/2021.
//

import SwiftUI
import Alamofire
import Foundation
import FileProvider


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
                
                do {
                    ItslearningAPI.getDownloadURL(authHandler, resourceId: try ItemID(idString: "12507_331920_455844_455860")) { response in
                        print(response)
                    }
                } catch {
                    print("Error2")
                }
                
                
                /*do {
                    let url = try fileProviderComm.manager.temporaryDirectoryURL().appendingPathComponent("\("yeet")-\(UUID().uuidString)")
                    print(url)
                    
                    try "Hello".write(to: url, atomically: false, encoding: .utf8)
                    
                    
                    ItslearningAPI.GetResource(authHandler, resourceId: try ItemID(idString: "12507_331920_391030_391032")) { response in
                        guard let data = response.data else {
                            print("Error")
                            return
                        }
                        print(data)
                    }
                } catch {
                    print("Error2")
                }*/
                
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
                //
                
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


