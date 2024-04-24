//
//  MultiPeerManager.swift
//  AnonymousChat
//
//  Created by Chuen on 10/4/2024.
//

import Foundation
import MultipeerConnectivity

protocol PCManagerDelegate {
    func invitationWasReceived(fromPeer: String)
    func connectedWithPeer(peerID: MCPeerID)
}

enum ChannelType: String {
    case publicChannel
    case privateChannel
    case gameChannel
    
    var name: String {
        switch self {
        case .publicChannel:
            "public"
        case .gameChannel:
            "game"
        case .privateChannel:
            ""
        }
    }
}

struct ChatChannel {
    let type: ChannelType
    let peer: MCPeerID
    var session: MCSession?
    var browser: MCNearbyServiceBrowser?
    var advertiser: MCNearbyServiceAdvertiser?
    var foundPeers = [MCPeerID]()
    
    init(type: ChannelType) {
        self.type = type
        
        let name = UserDefaults.standard.string(forKey: "username") ?? UIDevice.current.name
        
        var peerName = name
        switch type {
        case .gameChannel:
            peerName = name + "_game"
        case .publicChannel:
            peerName = name + "_public"
        default: break
        }
        
        self.peer = MCPeerID(displayName: peerName)
        self.session = MCSession(peer: peer)
        self.browser = MCNearbyServiceBrowser(peer: peer, serviceType: type.rawValue)
        self.advertiser = MCNearbyServiceAdvertiser(peer: peer, discoveryInfo: nil, serviceType: type.rawValue)
    }
    
    func send(withDatas dictionary: [String: Any], toPeers targetPeers: [MCPeerID]) -> Bool {
        let data = NSKeyedArchiver.archivedData(withRootObject: dictionary)
        do {
            try session?.send(data, toPeers: targetPeers, with: .reliable)
            return true
        } catch _ {
            return false
        }
    }
    
    func activate() {
        browser?.startBrowsingForPeers()
        advertiser?.startAdvertisingPeer()
    }
    
    func deActivate() {
        browser?.stopBrowsingForPeers()
        advertiser?.stopAdvertisingPeer()
    }
    
    mutating func endChatAction() {
        // Only send end chat notification for private chat
        guard type == .privateChannel else { return }
        
        let message: [String: String] = ["message": "_end_chat_"]
        if let peers = session?.connectedPeers {
            let sended = send(withDatas: message, toPeers: peers)
            if sended {
                // clear your own session
//                session?.disconnect()
            }
        }
    }
    
    func send(data: [String: Any]) {
        if let peers = session?.connectedPeers {
            _ = send(withDatas: data, toPeers: peers)
        }
    }
    
    mutating func appendPeer(peerID: MCPeerID) {
        foundPeers.append(peerID)
    }
    
    mutating func removePeer(peerID: MCPeerID) {
        if let index = foundPeers.firstIndex(of: peerID) {
            foundPeers.remove(at: index)
        }
    }
}

class MultipeerConnectivityManager: NSObject {
    static let sharedInstance = MultipeerConnectivityManager()
    var delegate: PCManagerDelegate?
    
    var publicChannel = ChatChannel(type: .publicChannel)
    var privateChannel = ChatChannel(type: .privateChannel)
    var gameChannel = ChatChannel(type: .gameChannel)
    
    var invitationHandler: ((Bool, MCSession?)->Void)?
    
    override init() {
        super.init()
        
        setupChannel(channel: publicChannel)
        setupChannel(channel: privateChannel)
        setupChannel(channel: gameChannel)
    }
    
    private func setupChannel(channel: ChatChannel) {
        channel.session?.delegate = self
        channel.browser?.delegate = self
        channel.advertiser?.delegate = self
    }
    
    func activateChannels() {
        publicChannel.activate()
        privateChannel.activate()
    }
    
    func deactivateChannels() {
        publicChannel.deActivate()
        privateChannel.deActivate()
        
        
        publicChannel.foundPeers = []
        privateChannel.foundPeers = []
    }
    
    func appendPeer(browser: MCNearbyServiceBrowser, peerId: MCPeerID) {
        if browser.serviceType == ChannelType.publicChannel.rawValue {
            publicChannel.appendPeer(peerID: peerId)
        }
        
        if browser.serviceType == ChannelType.privateChannel.rawValue {
            privateChannel.appendPeer(peerID: peerId)
        }
        
        if browser.serviceType == ChannelType.gameChannel.rawValue {
            gameChannel.appendPeer(peerID: peerId)
        }
    }
    
    func removePeer(browser: MCNearbyServiceBrowser, peerId: MCPeerID) {
        if browser.serviceType == ChannelType.publicChannel.rawValue {
            publicChannel.removePeer(peerID: peerId)
        }
        
        if browser.serviceType == ChannelType.privateChannel.rawValue {
            privateChannel.removePeer(peerID: peerId)
        }
    }
    
    func inviteAllUser() {
        guard let session = publicChannel.session else { return }
        
        publicChannel.foundPeers.forEach { peerId in
            
            let data = NSKeyedArchiver.archivedData(withRootObject: "publicConnection")
            publicChannel.browser?.invitePeer(peerId, to: session, withContext: data, timeout: 10)
        }
    }
}

extension MultipeerConnectivityManager: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case .connected:
            if peerID.displayName.contains("game") {
                delegate?.connectedWithPeer(peerID: peerID)
                return
            }
            
            if !peerID.displayName.contains("public"),
               privateChannel.session?.connectedPeers.contains(where: { $0 == peerID }) ?? false {
                delegate?.connectedWithPeer(peerID: peerID)
            }
        default:
            return
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        let datas = PeerData(data: data, peer: peerID)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "receivedPCDataNotification"), object: datas)
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
    }
}

extension MultipeerConnectivityManager: MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        appendPeer(browser: browser, peerId: peerID)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "peerUpdateNotification"), object: "Peer update -> \(browser.serviceType)")
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        removePeer(browser: browser, peerId: peerID)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "peerUpdateNotification"), object: "Peer update -> \(browser.serviceType)")
    }
}

extension MultipeerConnectivityManager : MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        
        // private channel invite
        if advertiser.serviceType == ChannelType.privateChannel.rawValue,
           !(privateChannel.session?.connectedPeers.contains(where: { $0 == peerID }) ?? false)  {
            self.invitationHandler = invitationHandler
            delegate?.invitationWasReceived(fromPeer: peerID.displayName)
        }
        
        // public channel invite
        if advertiser.serviceType == ChannelType.publicChannel.rawValue {
            invitationHandler(true, self.publicChannel.session)
        }
        
        // game channel invite
        if advertiser.serviceType == ChannelType.gameChannel.rawValue {
            invitationHandler(true, self.gameChannel.session)
        }
    }
}
