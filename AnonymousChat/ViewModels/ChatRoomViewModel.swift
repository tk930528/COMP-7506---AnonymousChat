//
//  ChatRoomViewModel.swift
//  AnonymousChat
//
//  Created by Chuen on 11/4/2024.
//

import SwiftUI
import Combine

class ChatRoomViewModel: ObservableObject {
    var channel: ChatChannel
    
    init(channel: ChatChannel) {
        self.channel = channel
    }
    
    func sendInvitation(name: String) {
        guard channel.type == .privateChannel,
              let selectedPeer = channel.foundPeers.first(where: { $0.displayName == name}),
              let session = channel.session else { return }
        channel.browser?.invitePeer(selectedPeer, to: session, withContext: nil, timeout: 10)
    }
}
