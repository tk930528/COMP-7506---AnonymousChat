//
//  Alerter.swift
//  AnonymousChat
//
//  Created by Chuen on 12/4/2024.
//

import SwiftUI
import Combine

class Alerter: ObservableObject {
    @Published var alert: Alert? {
        didSet { isShowingAlert = alert != nil }
    }
    @Published var isShowingAlert = false
}
