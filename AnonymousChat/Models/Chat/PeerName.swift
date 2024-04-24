//
//  PeerName.swift
//  AnonymousChat
//
//  Created by Chuen on 16/4/2024.
//

import SwiftUI

class PeerName: Identifiable, ObservableObject {
    @Published var name: String
    
    init(name: String) {
        self.name = name
    }
}
