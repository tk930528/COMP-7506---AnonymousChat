//
//  AnonymousChatApp.swift
//  AnonymousChat
//
//  Created by Chuen on 10/4/2024.
//

import SwiftUI

@main
struct AnonymousChatApp: App {
    @StateObject var alerter: Alerter = Alerter()
    
    var body: some Scene {
        WindowGroup {
            TabView {
                ChatListView(viewModel: ChatListViewModel(alerter: alerter))
                    .environmentObject(alerter)
                    .alert(isPresented: $alerter.isShowingAlert) {
                        alerter.alert ?? Alert(title: Text(""))
                    }
                    .tabItem {
                        Label("Chat list", systemImage: "ellipsis.message.fill")
                    }
                TicTacToeView(viewModel: TicTaeToeViewModel(channel: MultipeerConnectivityManager.sharedInstance.gameChannel))
                    .tabItem {
                        Label("Game", systemImage: "gamecontroller.fill")
                    }
                ProfileView()
                    .tabItem {
                        Label("Profile", systemImage: "person.crop.circle.fill")
                    }
            }
            .overlay(
                 VStack {
                     Spacer()
                     Rectangle()
                         .foregroundColor(.clear)
                         .frame(height: 80)
                 }
                 .edgesIgnoringSafeArea(.all)
             )
        }
    }
}
