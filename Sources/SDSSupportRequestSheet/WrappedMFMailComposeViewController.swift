//
//  WrappedMFMailComposeViewController.swift
//
//  Created by : Tomoaki Yagishita on 2021/07/13
//  © 2021  SmallDeskSoftware
//

import Foundation
import SwiftUI
import MessageUI

struct WrappedMFMailComposeViewController: UIViewControllerRepresentable {
    typealias UIViewControllerType = MFMailComposeViewController
    
    @Environment(\.presentationMode) var presentationMode

    var mailRecipients:[String] = []
    var mailSubject:String = ""
    var mailBody:String = ""
    var completion: ((MFMailComposeResult) -> Void)? = nil
    
    
    internal init(mailRecipients: [String] = [], mailSubject: String = "", mailBody: String = "", completion: ((MFMailComposeResult)->Void)? = nil) {
        self.mailRecipients = mailRecipients
        self.mailSubject = mailSubject
        self.mailBody = mailBody
        self.completion = completion
    }

    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let viewController = MFMailComposeViewController()
        viewController.delegate = context.coordinator
        viewController.mailComposeDelegate = context.coordinator
        viewController.setToRecipients(mailRecipients)
        viewController.setSubject(mailSubject)
        viewController.setMessageBody(mailBody, isHTML: false)
        return viewController
    }
    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {
    }
    func makeCoordinator() -> Coordinator {
        let coordinator = Coordinator(self)
        return coordinator
    }
    class Coordinator: NSObject, MFMailComposeViewControllerDelegate, UINavigationControllerDelegate {
        var parent: WrappedMFMailComposeViewController
        
        init(_ parent: WrappedMFMailComposeViewController) {
            self.parent = parent
        }
        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            switch result {
            case .sent:
                print("send")
            case .cancelled:
                print("cancelled")
            case .failed:
                print("failed")
            case .saved:
                print("saved")
            default:
                print("default")
            }
            parent.presentationMode.wrappedValue.dismiss()
            parent.completion?(result)
        }
    }
}
