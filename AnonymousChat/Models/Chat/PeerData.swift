//
//  PeerData.swift
//  AnonymousChat
//
//  Created by Chuen on 10/4/2024.
//

import MultipeerConnectivity

class PeerData {
    var data : Data?
    var peer : MCPeerID
    
    init(data: Data, peer: MCPeerID) {
        self.data = data
        self.peer = peer
    }
}
