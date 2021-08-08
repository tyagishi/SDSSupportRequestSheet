//
//  SDSSupportRequestSheet.swift
//
//  Created by : Tomoaki Yagishita on 2021/07/18
//  © 2021  SmallDeskSoftware
//

import Foundation
import Combine
import SwiftUI

#if canImport(MessageUI)
import MessageUI
#endif

let requestType: [String] = [NSLocalizedString("Question", bundle: .module, comment: ""), NSLocalizedString("Request", bundle: .module, comment: ""),
                             NSLocalizedString("BugReport", bundle: .module, comment: ""), NSLocalizedString("Other", bundle: .module, comment: "")]

#if os(iOS)
@available(iOSApplicationExtension, unavailable)
public struct SDSSupportRequestSheet: View, KeyboardReadable {
    @State private var selectedType: String = requestType[0]
    
    @Binding var isPresented: Bool
    @State private var mailTitle: String = ""
    @State private var mailContent: String = ""
    @State private var placeholder = NSLocalizedString("please write down details", bundle: .module, comment: "")
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
                        Text("Cancel", bundle: .module)
                    })
                    Spacer()
                    Button(action: {
                        showMailComposer = true
                    }, label: {
                        Text("Mail", bundle: .module)
                    })
                        //.disabled(!MFMailComposeViewController.canSendMail())
                }
                .padding(15)
                Spacer()
                NavigationView {
                    Form {
                        Section(header: Text("request type", bundle: .module)) {
                            Picker(NSLocalizedString("type", bundle: .module, comment: ""), selection: $selectedType) {
                                List(requestType, id:\.self) { item in
                                    Text(item)
                                }
                                .navigationBarHidden(true)
                                .navigationBarTitle("")
                            }
                        }
                        Section(header: Text("request detail", bundle: .module)) {
                            TextField(NSLocalizedString("title", bundle: .module, comment: ""), text: $mailTitle)
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
                            environmentForm
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
                        Text("Following will be sent", bundle: .module)
                        Section(header: Text("mail title", bundle: .module)) {
                            Text(composeMailSubject)
                        }
                        Section(header: Text("mail content", bundle: .module)) {
                            Text(composeMailBody)
                        }
                    }
                    Button(action: { showMailComposer.toggle() }, label: {
                        Text("OK", bundle: .module)
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
#endif

#else // macOS
public struct SDSSupportRequestSheet: View {
    @Binding var isPresented: Bool
    @State private var category: String = requestType[0]
    @State private var mailTitle: String = ""
    @State private var mailContent: String = ""

    public init(isPresented: Binding<Bool>) {
        self._isPresented = isPresented
    }
    public var body: some View {
        VStack {
            Text("Support Request", bundle: .module).font(.title)
            Picker(NSLocalizedString("type", bundle: .module, comment: ""), selection: $category) {
                ForEach(requestType, id: \.self) { item in
                    Text(item)
                        .tag(item)
                }
            }
            .padding(.horizontal)
            TextField(NSLocalizedString("title", bundle: .module, comment: ""), text: $mailTitle)
                .overlay(
                    RoundedRectangle(cornerRadius: 3)
                        .stroke(Color.gray)
                )
                .padding(.horizontal)
            TextEditor(text: $mailContent)
                //.textFieldStyle(RoundedBorderTextFieldStyle())
                .textFieldStyle(SquareBorderTextFieldStyle())
                .overlay(
                    RoundedRectangle(cornerRadius: 3)
                        .stroke(Color.gray)
                )
                //.frame(width: 300, height: 200)
                .frame(height: 150)
                .padding(.horizontal)

            Form {
                environmentForm
            }
            .padding(.horizontal)
            
            HStack {
                Button(action: {
                    guard let service = NSSharingService(named: NSSharingService.Name.composeEmail) else { return }
                    service.recipients = ["smalldesksoftware@gmail.com"]
                    service.subject = String("[\(category)] \(mailTitle)")
                    service.perform(withItems: [mailContent, "\n", osVersionAsString, appNameAsString, appVersionAsString])
                    isPresented.toggle()
                }, label: {
                    Text("Mail", bundle: .module)
                })
                .padding()
                if isPresented {
                    Button(action: {
                        isPresented.toggle()
                    }, label: {
                        Text("Cancel", bundle: .module)
                    })
                    .padding()
                }
            }
        }
        .padding()
    }
}
#endif

@available(iOSApplicationExtension, unavailable)
extension SDSSupportRequestSheet {
    
    var environmentForm: some View {
        Section(header: Text("environment info", bundle: .module)) {
                if let deviceName = deviceNameAsString {
                    Text(deviceName)
                }
                Text(osVersionAsString)
                Text(appNameAsString)
                Text(appVersionAsString)
        }
        .font(.caption)
    }
    
    var deviceNameAsString: String? {
        var device = NSLocalizedString("Device : ", bundle: .module, comment: "")
        #if os(macOS)
        return nil
        #elseif os(iOS)
        return device.appending(UIDevice.current.modelName)
        #else
        return device.appending("unknown")
        #endif
    }
    
    var osVersionAsString: String {
        var osName = NSLocalizedString("OS : ", bundle: .module, comment: "")
        #if os(macOS)
        return osName.appending(ProcessInfo.processInfo.operatingSystemVersionString)
        #elseif os(iOS)
        return osName.appending(UIDevice.current.systemVersion)
        #else
        return osName.appending("unknown")
        #endif
    }
    
    var appNameAsString: String {
        let appName = (Bundle.main.infoDictionary?["CFBundleName"] as? String) ?? "UnknownApp"
        return NSLocalizedString("App Name : ", bundle: .module, comment: "").appending(appName)
    }

    var appVersionAsString: String {
        let appVersion = (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String) ?? "0.0"
        return NSLocalizedString("App Version : ", bundle: .module, comment: "").appending(appVersion)
    }
}
