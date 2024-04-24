//
//  ChatListView.swift
//  AnonymousChat
//
//  Created by Chuen on 10/4/2024.
//

import SwiftUI
import MultipeerConnectivity

struct ChatListView: View {
    @StateObject var viewModel: ChatListViewModel
    private let pub = NotificationCenter.default.publisher(for: NSNotification.Name("peerUpdateNotification"))
//    private let pub2 = NotificationCenter.default.publisher(for: NSNotification.Name("peerConnectedNotification"))
    @Environment(\.scenePhase) var scenePhase
    @EnvironmentObject var alerter: Alerter
    
    @State private var path = NavigationPath()
    @State var pushActive = false
    
    var body: some View {
        NavigationView {
            List {
                NavigationLink("Public", destination: ChatRoomView(viewModel: ChatRoomViewModel(channel: viewModel.peerManager.publicChannel)))
                
                ForEach(viewModel.peerList) { peer in
                    ZStack {
                        NavigationLink(
                            "",
                            destination: ChatRoomView(viewModel: ChatRoomViewModel(channel: viewModel.peerManager.privateChannel)),
                            isActive: $pushActive
                        ).frame(height: 0)
                        
                        Text(peer.name)
                            .padding(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                viewModel.sendInvitation(name: peer.name)
                            }
                    }
                }
            }
            .listStyle(.plain)
            .navigationBarTitle("Chat List")
        }
        // enter background
        .onChange(of: scenePhase) { _, newValue in
            switch newValue {
            case .background:
                didEnterBackground()
            default: break
            }
        }
        .onReceive(pub) { output in
            guard let msg = output.object as? String else {
                return
            }
            
            // Update peer list data source
            if msg.contains("Peer update"),
               msg.contains(ChannelType.publicChannel.name) {
                Task {
                    await updatePeerList()
                    MultipeerConnectivityManager.sharedInstance.inviteAllUser()
                }
            }
        }
//        .onReceive(pub2) { output in
//            guard let msg = output.object as? String else {
//                return
//            }
//            
//            // Update peer list data source
//            if msg == "Peer connected" {
//                pushActive = true
//            }
//        }
        .onDisappear {
            pushActive = false
            viewModel.peerManager.deactivateChannels()
            
        }
        .onAppear {
            viewModel.peerManager.activateChannels()
            viewModel.peerManager.delegate = self
        }
    }
    
    func updatePeerList() async {
        await MainActor.run {
            viewModel.peerList = viewModel.peerManager.privateChannel.foundPeers.map { PeerName(name: $0.displayName) }
        }
    }
    
    func didEnterBackground() {
        MultipeerConnectivityManager.sharedInstance.publicChannel.foundPeers = []
        MultipeerConnectivityManager.sharedInstance.privateChannel.foundPeers = []
    }
    
    func pushToChatRoom() {
        pushActive = true
    }
}

extension ChatListView: PCManagerDelegate {
    func invitationWasReceived(fromPeer: String) {
        alerter.alert = Alert(
            title: Text("Someone invite you"),
            message: Text("Do you accept?"),
            primaryButton: .destructive(
                Text("Accept"),
                action: {
                    viewModel.acceptInvitation()
                }
            ),
            secondaryButton: .cancel(
                Text("Deny"),
                action: {
                    viewModel.denyInvitation()
                }
            )
        )
    }
    
    func connectedWithPeer(peerID: MCPeerID) {
        DispatchQueue.main.async{
            pushToChatRoom()
        }
    }
}
