//
//  ChatListViewModel.swift
//  AnonymousChat
//
//  Created by Chuen on 10/4/2024.
//

import SwiftUI
import Combine
import MultipeerConnectivity

class ChatListViewModel: ObservableObject {
    var peerManager = MultipeerConnectivityManager.sharedInstance
    var alerter: Alerter
    @Published var peerList: [PeerName] = []
    
    var inviteUserName: String = ""
    
    init(alerter: Alerter) {
        self.alerter = alerter
    }
    
    func sendInvitation(name: String) {
        guard let selectedPeer = peerManager.privateChannel.foundPeers.first(where: { $0.displayName == name}),
              let session = peerManager.privateChannel.session else { return }
        inviteUserName = name
        peerManager.privateChannel.browser?.invitePeer(selectedPeer, to: session, withContext: nil, timeout: 10)
    }
    
    func acceptInvitation() {
        peerManager.invitationHandler?(true, peerManager.privateChannel.session)
    }
    
    func denyInvitation() {
        peerManager.invitationHandler?(false, nil)
    }
}
