//
//  TicTacToeView.swift
//  AnonymousChat
//
//  Created by Chuen on 17/4/2024.
//

import SwiftUI
import Combine
import MultipeerConnectivity

struct TicTacToeView: View {
    @Environment(\.colorScheme) var colorScheme
    @StateObject var viewModel: TicTaeToeViewModel
    @State var selection: Bool = true
    @State var move: Bool = false
    @State private var vibro: Bool = true
    @State var popup: Bool = false
    @State var connected = false
    
    private let pub = NotificationCenter.default.publisher(for: NSNotification.Name("receivedPCDataNotification"))
    
    static func setVibro(mode: Bool) {
        UserDefaults.standard.set(mode, forKey: "vibro")
    }
    
    static func triggerHapticFeedback(type: Int, overrdie: Bool = false) {
        let vibro = Foundation.UserDefaults.standard.value(forKey: "vibro") as? Bool
        if vibro == true || overrdie == true {
            if type == 1 {
                let generator = UIImpactFeedbackGenerator(style: .soft)
                generator.impactOccurred()
            } else if type == 2 {
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.impactOccurred()
            } else if type == 3 {
                let generator = UIImpactFeedbackGenerator(style: .rigid)
                generator.impactOccurred()
            } else if type == 4 {
                let generator = UIImpactFeedbackGenerator(style: .rigid)
                generator.impactOccurred()
            }
        }
    }
    
    static func showAIAlert(won: SquareStatus, reset: @escaping () -> Void) -> Alert {
        return Alert(title: Text("Game Over"),
              message: Text(won != .empty ? won == .x ? "You Won!" : "AI Won!" : "Draw!"),
              dismissButton: Alert.Button.destructive(Text("Ok"), action: reset)
        )
    }
    
    static func showPVPAlert(won: SquareStatus, reset: ()) -> Alert {
        Alert(title: Text("Game Over"),
              message: Text(won != .empty ? won == .x ? "X won!" : "O Won!" : "Draw!"),
              dismissButton: Alert.Button.destructive(Text("Ok"), action: { reset }
        ))
    }
    
    func buttonAction(_ index : Int) {
        if (viewModel.playerToMove == false && selection == false) || selection == true {
            _ = viewModel.makeMove(index: index, gameType: selection)
        }
        TicTacToeView.triggerHapticFeedback(type: 2)
    }
    
    var currPlayer: String {
        return viewModel.playerToMove == false ? "X" : "O"
    }
    
    var AIMove: String {
        return viewModel.playerToMove == false ? "Your" : "AI"
    }
    
    var body: some View {
        ZStack {
            if connected {
                tictactoe
            } else {
                ZStack {
                    Text("Wait for opponent..")
                }
            }
        }
        .onAppear {
            connected = false
            viewModel.resetGame()
            viewModel.peerManager.gameChannel.activate()
            viewModel.peerManager.delegate = self
            
            viewModel.onClick = { index in
                self.sendAction(index: index)
            }
            
            Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { _ in
                if !viewModel.peerManager.gameChannel.foundPeers.isEmpty {
                    viewModel.sendRandomInvitation()
                }
            }
        }
        .onDisappear {
            viewModel.disconnectToGameChannel()
        }
        .onReceive(pub) { output in
            guard let received = output.object as? PeerData else {
                return
            }
            
            if let data = received.data {
                // Text data
                if let actionDict = NSKeyedUnarchiver.unarchiveObject(with: data) as? [String: Int],
                   let index = actionDict["action"] {
                    viewModel.makeMove(index: index, gameType: true)
                }
            }
        }
    }
    
    var tictactoe: some View {
        VStack {
            Text("Tic Tac Toe - PVP")
                .bold()
                .font(.title)
                .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.7) : Color.black.opacity(0.7))
            
            Text("\(currPlayer) to move")
                .bold()
                .font(.title2)
                .padding(.bottom)
                .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.7) : Color.black.opacity(0.7))
            
            ForEach(0 ..< viewModel.squares.count / 3, id: \.self, content: { row in
                HStack {
                    ForEach(0 ..< 3, content: { column in
                        let index = row * 3 + column
                        SquareView(dataSouce: viewModel.squares[index], action: { self.buttonAction(index) })
                    })
                }
            })
            
            Spacer()
            
            Button(action: {
                viewModel.resetGame()
                TicTacToeView.triggerHapticFeedback(type: 3)
            }, label: {
                Text("Reset")
                    .foregroundColor(Color.red.opacity(0.7))
            })            .alert(isPresented: $viewModel._gameOver, content: {
                var text = ""
                if self.selection == false {
                    if viewModel._winner == .x { text = "You won!" }
                    else if viewModel._winner == .o { text = "AI won!" }
                    else { text = "Draw!" }
                } else {
                    if viewModel._winner == .x { text = "X won!" }
                    else if viewModel._winner == .o { text = "O won!" }
                    else { text = "Draw!" }
                }
                return Alert(title: Text(text),
                      dismissButton: Alert.Button.cancel(Text("Ok"), action: {
                    viewModel.resetGame()
                    viewModel._gameOver = false
                    viewModel._winner = .empty
                })
                )
            })
        }
    }
    
    func sendAction(index: Int) {
        let actionDict: [String: Int] = ["action": index]
        viewModel.peerManager.gameChannel.send(data: actionDict)
    }
}

extension TicTacToeView: PCManagerDelegate {
    func invitationWasReceived(fromPeer: String) {
    }
    
    func connectedWithPeer(peerID: MCPeerID) {
        DispatchQueue.main.async{
            connected = true
        }
    }
}
