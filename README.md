# SDSSupportRequestSheet

![macOS iOS](https://img.shields.io/badge/platform-iOS_macOS-lightgrey)
![iOS](https://img.shields.io/badge/iOS-v14_orLater-blue)
![macOS](https://img.shields.io/badge/macOS-Big_Sur_orLater-blue)
![SPM is supported](https://img.shields.io/badge/SPM-Supported-orange)
![license](https://img.shields.io/badge/license-MIT-lightgrey)

Support Request (Question/Request/BugFix) sheet

<!--
comment
-->

## Feature

SDSSupportRequestSheet provides the sheet for sending requests to app developer.

SDSSupportRequestSheet will collect customer environment info automatically.

on iOS, send those info via MFMailComposeViewController.

on macOS, send those info via NSSharingService.


## Code Example

same code can be used on iOS and macOS.
```
//
//  ContentView.swift
//
//  Created by : Tomoaki Yagishita on 2021/07/24
//  © 2021  SmallDeskSoftware
//

import SwiftUI
import SDSSupportRequestSheet

struct ContentView: View {
    @State private var showSupportDialog = false
    var body: some View {
        VStack {
            Button(action: {
                showSupportDialog.toggle()
            }, label: {
                Text("Show Support Dialog")
            })
            .padding()
        }
        .sheet(isPresented: $showSupportDialog ) {
            SDSSupportRequestSheet(isPresented: $showSupportDialog,
                                   mailRecipients: ["me@example.com"] )
        }
    }
}
```


## Installation
Swift Package Manager: URL: https://github.com/tyagishi/SDSSupportRequestSheet

Currently no stable version available. use main for the moment.

## Requirements
none

## Note
