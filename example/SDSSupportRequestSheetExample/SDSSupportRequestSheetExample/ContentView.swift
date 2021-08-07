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
            SDSSupportRequestSheet(isPresented: $showSupportDialog)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
