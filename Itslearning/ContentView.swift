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

class FileProviderComm : NSObject, ObservableObject {
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

class ViewModel: ObservableObject {
    @Published var isLoading: Bool = true
    @Published var isLoggedIn: Bool = false
    @Published var text: String = "loading"
    
    init() {
        NotificationCenter.default.addObserver(forName: .urlopened, object: nil, queue: nil) { [self] notification in
            text = notification.userInfo!["path"] as! String
        }
    }
    
    let objectWillChange = ObservableObjectPublisher()
    func updateView(){
        objectWillChange.send()
    }
}
extension VerticalAlignment {
   private enum CenteredMiddleView: AlignmentID {
      static func defaultValue(in dimensions: ViewDimensions) -> CGFloat {
         return dimensions[VerticalAlignment.center]
      }
   }

    static let centeredMiddleView = VerticalAlignment(CenteredMiddleView.self)
}

extension Alignment {
    static let centeredView = Alignment(horizontal: HorizontalAlignment.center,
                          vertical: VerticalAlignment.centeredMiddleView)
}

struct ContentView: View {
    @State private var fileProviderComm : FileProviderComm;
    @ObservedObject var viewModel = ViewModel()
    // TODO: Authhandler should be made a singleton
    @State var authHandler: AuthHandler?;
    
    @State var selection: Int?
    
    init() {
        fileProviderComm = FileProviderComm()
        do {
            authHandler = try AuthHandler()
        } catch {
            print("Error occured during sign in")
        }
    }
    
    var body: some View {
        NavigationView {
            List (selection: $selection){
                NavigationLink(destination: Home(), tag: 0, selection: $selection, label: {Label("Home", systemImage: "house")})
                NavigationLink(destination: Controls(), tag: 1, selection: $selection, label: {Label("Controls", systemImage: "hammer")})
                NavigationLink(destination: Settings(),tag: 2,  selection: $selection, label: {Label("Settings", systemImage: "gearshape")})
                Spacer()
                NavigationLink(destination: Text("Should be combined button, with name and system image defined by whether fileprovider is mounted or not"), tag: 3,  selection: $selection, label: {Label("Eject", systemImage: "eject")})
                NavigationLink(destination: Text("Same as eject"),tag: 4,  selection: $selection,  label: {Label("Mount", systemImage: "mount")})
                NavigationLink(destination: Text("Obviously, shouldn't not have a navigation screen"),tag: 5,  selection: $selection,  label: {Label("Log off", systemImage: "arrowshape.turn.up.left.circle")})
            }.onAppear {
                self.selection = 0
            }.navigationTitle("Master")
        }
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
//        VStack {
//            HStack {
//                Text(authHandler?.oauth2.accessToken ?? "no access token").lineLimit(1)
//                Text(authHandler?.oauth2.refreshToken ?? "no refresh token").lineLimit(1)
//                Text(authHandler?.oauth2.accessTokenExpiry?.description ?? "no access token date").lineLimit(1)
//                Button(action: {
//                    viewModel.updateView()
//                }, label: {
//                    Text("Reload")
//                })
//            }
//            HStack {
//                Button(action: {
//                    fileProviderComm.unregister()
//                }, label: {
//                    Text("Unregister")
//                })
//                Button(action: {
//                    fileProviderComm.register()
//                }, label: {
//                    Text("Register")
//                })
//                Button(action: {
//                    fileProviderComm.manager.signalEnumerator(for: .rootContainer) { error in
//                        if error != nil {
//                            print("Error: \(String(describing: error))")
//                        }
//                    }
//                }, label: {
//                    Text("Reload")
//                })
//
//                Button(action: {
//                    authHandler?.LogOut()
//                }, label: {
//                    Text("Clear User Defaults")
//                })
//                Button(action: {
//                    do {
//                        try authHandler?.SignIn()
//                    } catch {
//                        print("Error")
//                    }
//                } , label: {
//                    Text("Relogin")
//                })
//            }
//            ProgressView()
//            Text(viewModel.text)
//        }
//        .frame(maxWidth: .infinity, maxHeight: .infinity)
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
