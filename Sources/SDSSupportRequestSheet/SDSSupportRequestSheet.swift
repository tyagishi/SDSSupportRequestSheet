//
//  SDSSupportRequestSheet.swift
//
//  Created by : Tomoaki Yagishita on 2021/07/18
//  © 2021  SmallDeskSoftware
//

import Foundation
import Combine
import MessageUI
import SwiftUI

@available(iOSApplicationExtension, unavailable)
public struct SDSSupportRequestSheet: View, KeyboardReadable {
    let requestType: [String] = [NSLocalizedString("Question", comment: ""), NSLocalizedString("Request", comment: ""),
                                 NSLocalizedString("BugReport", comment: ""), NSLocalizedString("Other", comment: "")]
    @State private var selectedType: String = "Question"
    
    @Binding var isPresented: Bool
    @State private var mailTitle: String = ""
    @State private var mailContent: String = ""
    @State private var placeholder = NSLocalizedString("please write down details here", comment: "")
    @State private var isKeyboardVisible = false
    
    @State private var showMailComposer = false
    
    public init(isPresented: Binding<Bool>) {
        self._isPresented = isPresented
    }
    
    public var body: some View {
        let tapGesture = TapGesture()
            .onEnded { _ in
                self.hideKeyboard()
            }
        return ZStack {
            Color.white.opacity(0.001)
                .onTapGesture {
                    self.hideKeyboard()
                }
            VStack {
                HStack {
                    Button(action: {
                        isPresented.toggle()
                    }, label: {
                        Text("Cancel")
                    })
                    Spacer()
                    Button(action: {
                        showMailComposer = true
                    }, label: {
                        Text("Mail")
                    })
                        //.disabled(!MFMailComposeViewController.canSendMail())
                }
                .padding(15)
                Spacer()
                NavigationView {
                    Form {
                        Section(header: Text("request type")) {
                            Picker("type", selection: $selectedType) {
                                List(requestType, id:\.self) { item in
                                    Text(item)
                                }
                                .navigationBarHidden(true)
                            }
                        }
                        Section(header: Text("request detail")) {
                            TextField("title", text: $mailTitle)
                            ZStack(alignment: .top) {
                                TextEditor(text: $mailContent)
                                    .frame(height: 200)
                                Text(placeholder).padding(15)
                                    .opacity(mailContent=="" ? 1.0 : 0.0)
                            }
                            .onReceive(keyboardPublisher) { result in
                                isKeyboardVisible = result
                            }
                        }
                        .simultaneousGesture(tapGesture)
                        .navigationBarHidden(true)
                        if !isKeyboardVisible {
                            Section(header: Text("environment info")) {
                                HStack {
                                    Text("Device")
                                    Spacer()
                                    Text(deviceNameAsString)
                                }
                                HStack {
                                    Text("OS")
                                    Spacer()
                                    Text(osVersionAsString)
                                }
                                HStack {
                                    Text("App")
                                    Spacer()
                                    Text(appNameAsString)
                                }
                                HStack {
                                    Text("App Version")
                                    Spacer()
                                    Text(appVersionAsString)
                                }
                            }
                            .font(.caption)
                            .padding()
                        }
                    }

                }
            }
            .sheet(isPresented: $showMailComposer) {
                if MFMailComposeViewController.canSendMail() {
                    WrappedMFMailComposeViewController(mailRecipients: ["smalldesksoftware@gmail.com"],
                                                       mailSubject: composeMailSubject, mailBody: composeMailBody) { result in
                        if result == .cancelled || result == .failed {
                            
                        } else {
                            isPresented.toggle()
                        }
                    }
                } else {
                    Form {
                        Text("Following will be sent")
                        Section(header: Text("mail title")) {
                            Text(composeMailSubject)
                        }
                        Section(header: Text("mail content")) {
                            Text(composeMailBody)
                        }
                    }
                    Button(action: { showMailComposer.toggle() }, label: {
                        Text("OK")
                    })
                    .padding()
                }
            }
        }
    }
    
    var composeMailSubject: String {
        let title = "<".appending(selectedType).appending("> ").appending(mailTitle)
        return title
    }
    var composeMailBody: String {
        let body = mailContent.appending("\n\n")
            .appending("Device: \(deviceNameAsString)\n")
            .appending("OS    : \(osVersionAsString)\n")
            .appending("App   : \(appNameAsString)\n")
            .appending("AppVer: \(appVersionAsString)")
        return body
    }
    
    var deviceNameAsString: String {
        UIDevice.current.modelName
    }
    
    var osVersionAsString: String {
        UIDevice.current.systemVersion
    }
    
    var appNameAsString: String {
        let appName = Bundle.main.infoDictionary?["CFBundleName"] as? String
        return appName ?? "UnknownApp"
    }
    
    var appVersionAsString: String {
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        return appVersion ?? "0.0"
    }
}

/// Publisher to read keyboard changes.
protocol KeyboardReadable {
    var keyboardPublisher: AnyPublisher<Bool, Never> { get }
}

extension KeyboardReadable {
    var keyboardPublisher: AnyPublisher<Bool, Never> {
        Publishers.Merge(
            NotificationCenter.default
                .publisher(for: UIResponder.keyboardWillShowNotification)
                .map { _ in true },
            
            NotificationCenter.default
                .publisher(for: UIResponder.keyboardWillHideNotification)
                .map { _ in false }
        )
        .eraseToAnyPublisher()
    }
}

#if canImport(UIKit)
@available(iOSApplicationExtension, unavailable)
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif

public extension UIDevice {
    var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return identifier
    }
}
