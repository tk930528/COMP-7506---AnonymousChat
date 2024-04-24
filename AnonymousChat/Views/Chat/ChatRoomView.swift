//
//  ChatRoomView.swift
//  AnonymousChat
//
//  Created by Chuen on 11/4/2024.
//

import PhotosUI
import SwiftUI
import SwiftyChat

struct ChatRoomView: View {
    @AppStorage("username") var username: String = "Name"
//    @AppStorage("profileImageData") var imageData: Data = UIImage(systemName: "person.circle.fill")?.jpeg(.highest) ?? Data()
    
    @StateObject var viewModel: ChatRoomViewModel
    
    @State var messages: [MockMessages.ChatMessageItem] = []
    @State var showImagePicker: Bool = false
    @State var showTabbar: Bool = false
    @State private var scrollToBottom = false
    @State private var showEndChatAlert = false
    @State private var selectedItem: PhotosPickerItem?
    @State private var message = ""
    
    @Environment(\.scenePhase) var scenePhase
    @Environment(\.dismiss) var dismiss
    
    lazy var user: MockMessages.ChatUserItem = .init(
        userName: self.username,
        avatar: UIImage(systemName: "person.circle.fill")
    )
    
    
    private let pub = NotificationCenter.default.publisher(for: NSNotification.Name("receivedPCDataNotification"))
    
    var body: some View {
        NavigationView {
            VStack{
                chatView
            }
        }
        // Pop alert when private chat is end
        .alert("Your peer ended the chat", isPresented: $showEndChatAlert) {
            Button("OK", role: .cancel) {
                // Clear session
                viewModel.channel.session?.disconnect()
                dismiss()
            }
        }
        .photosPicker(isPresented: $showImagePicker, selection: $selectedItem, matching: .any(of: [.images, .screenshots, .videos]))
        .onChange(of: selectedItem, { _, newValue in
            Task {
                // send video
                if let movie = try? await newValue?.loadTransferable(type: Movie.self),
                    let data = try? JSONEncoder().encode(movie) {
                    self.messages.append( .init(user: MockMessages.sender, messageKind: .video(movie.getVideoItem()), isSender: true))
                    self.scrollToBottom = true
                    self.sendMovie(data: data)
                }
                
                // send image
                if let data = try? await newValue?.loadTransferable(type: Data.self) {
                    guard let image = UIImage(data: data) else { return }
                    self.messages.append( .init(user: MockMessages.sender, messageKind: .image(.local(image)), isSender: true))
                    self.scrollToBottom = true
                    self.sendImage(data: data)
                }
            }
        })
        .onAppear {
            showImagePicker = false
            showEndChatAlert = false
            showTabbar = false
        }
        .onDisappear {
            endChatButtonAction()
            showTabbar = true
        }
        .toolbar(showTabbar ? .visible : .hidden, for: .tabBar)
    }
    
    private func userValue() -> MockMessages.ChatUserItem {
        var mutatableSelf = self
        return mutatableSelf.user
    }
    
    private var chatView: some View {
        ChatView<MockMessages.ChatMessageItem, MockMessages.ChatUserItem>(messages: $messages, scrollToBottom: $scrollToBottom) {

            InputView(
                message: $message,
                placeholder: "Type something",
                onCommit: { messageKind in
                    switch messageKind {
                    case .custom:
                        showImagePicker = true
                        
                    case .text(let text):
                        // update ui
                        messages.append(
                            .init(user: MockMessages.sender, messageKind: messageKind, isSender: true)
                        )
                        self.scrollToBottom = true
                        // send message to connected peers
                        sendMessage(message: text)
                    default: break
                    }
                }
            )
            .background(Color.primary.colorInvert())
            .embedInAnyView()
            
        }
        // ▼ Optional, Implement to register a custom cell for Messagekind.custom
        .registerCustomCell(customCell: { anyParam in AnyView(CustomExampleChatCell(anyParam: anyParam))})
        // ▼ Implement in case ChatMessageKind.quickReply
        .onQuickReplyItemSelected { (quickReply) in
            self.messages.append(
                MockMessages.ChatMessageItem(
                    user: self.userValue(),
                    messageKind: .text(quickReply.title),
                    isSender: true
                )
            )
        }
        // ▼ Implement in case ChatMessageKind.contact
        .contactItemButtons { (contact, message) -> [ContactCellButton] in
            return [
                .init(title: "Save", action: {
                    print(contact.displayName)
                })
            ]
        }
        .environmentObject(ChatMessageCellStyle())
        .navigationBarHidden(true)
        .navigationBarTitle("")
        .listStyle(PlainListStyle())
        // view on appear
        .onAppear(perform: {
            switch viewModel.channel.type {
            case .publicChannel:
                MultipeerConnectivityManager.sharedInstance.inviteAllUser()
            default: break
            }
        })
        // enter background
        .onChange(of: scenePhase) { _, newValue in
            switch newValue {
            case .background:
                didEnterBackground()
            default: break
            }
        }
        // receive notification
        .onReceive(pub) { output in
            guard let received = output.object as? PeerData else {
                return
            }
            
            if let data = received.data {
                // Text data
                if let messageDict = NSKeyedUnarchiver.unarchiveObject(with: data) as? [String: String],
                   let message = messageDict["message"] {
                    
                    //
                    if message == "_end_chat_" {
                        showEndChatAlert = true
                        return
                    }
                    
                    // Append message from others
                    self.messages.append(.init(user: self.userValue(), messageKind: .text(message), isSender: false))
                    self.scrollToBottom = true
                }
                
                // Image or movie data
                if let dataDict = NSKeyedUnarchiver.unarchiveObject(with: data) as? [String: Data] {
                   if let imageData = dataDict["image"],
                      let image = UIImage(data: imageData) {
                       
                       // Append image from others
                       self.messages.append( .init(user: self.userValue(), messageKind: .image(.local(image)), isSender: false))
                       self.scrollToBottom = true
                   }
                    
                    if let movieData = dataDict["movie"],
                       let movie = try? JSONDecoder().decode(Movie.self, from: movieData) {
                        
                        self.messages.append( .init(user: self.userValue(), messageKind: .video(movie.getVideoItem()), isSender: false))
                        self.scrollToBottom = true
                    }
                }
            }
        }
    }
    
    func endChatButtonAction() {
        // Only send end chat notification for private chat
        viewModel.channel.endChatAction()
    }
    
    func didEnterBackground() {
        endChatButtonAction()
        dismiss()
        MultipeerConnectivityManager.sharedInstance.publicChannel.foundPeers = []
        MultipeerConnectivityManager.sharedInstance.privateChannel.foundPeers = []
    }
    
    func sendMessage(message: String) {
        let messageDict: [String: String] = ["message": message]
        viewModel.channel.send(data: messageDict)
    }
    
    func sendImage(data: Data) {
        let imageDict: [String: Data] = ["image": data]
        viewModel.channel.send(data: imageDict)
    }
    
    func sendMovie(data: Data) {
        let movieDict: [String: Data] = ["movie": data]
        viewModel.channel.send(data: movieDict)
    }
}

struct CustomExampleChatCell: View {
    var anyParam: Any
    
    var body: some View {
        VStack{
            Text((anyParam as? String) ?? "Not a String")
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                .padding(5)
                                
        }
        .background(Color.green)
        .cornerRadius(25)
    }
}
