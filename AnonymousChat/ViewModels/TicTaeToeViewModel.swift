//
//  TicTaeToeViewModel.swift
//  AnonymousChat
//
//  Created by Chuen on 17/4/2024.
//

import SwiftUI
import Combine
import MultipeerConnectivity

enum SquareStatus {
    case empty
    case x
    case o
    case xw
    case ow
}

class Square : ObservableObject {
    @Published var squareStatus : SquareStatus
    
    init(status: SquareStatus) {
        self.squareStatus = status
    }
}

class TicTaeToeViewModel: ObservableObject {
    @Published var _gameOver: Bool = false
    @Published var _winner: SquareStatus = .empty
    
    @Published var squares = [Square]()
    @Published var playerToMove: Bool = false
    var onClick: ((Int) -> Void)?
    
    var peerManager = MultipeerConnectivityManager.sharedInstance
    var channel: ChatChannel
    
    init(channel: ChatChannel) {
        self.channel = channel
        
        for _ in 0...8 {
            squares.append(Square(status: .empty))
        }
    }
    
    func searchOpponent() {
        peerManager.gameChannel.activate()
    }
    
    func sendRandomInvitation() {
        guard peerManager.gameChannel.type == .gameChannel,
              let selectedPeer = peerManager.gameChannel.foundPeers.random(),
              let session = peerManager.gameChannel.session else { return }
        peerManager.gameChannel.browser?.invitePeer(selectedPeer, to: session, withContext: nil, timeout: 10)
    }
    
    func disconnectToGameChannel() {
        self.peerManager.gameChannel.session?.disconnect()
        self.peerManager.gameChannel.deActivate()
        self.peerManager.gameChannel.foundPeers = []
    }
    
    func resetGame() -> Void {
        for i in 0...8 {
            squares[i].squareStatus = .empty
            playerToMove = false
        }
    }
    
    var gameOver: (SquareStatus, Bool) {
        get {
            if _gameOver == false {
                if winner.0 != .empty {
                    colorize(check: winner.0, row: winner.1)
                    _winner = winner.0
                    return (winner.0, true)
                } else {
                    for i in 0...8 {
                        if squares[i].squareStatus == .empty {
                            return (.empty, false)
                        }
                    }
                    _gameOver = true
                    return (.empty, true)
                }
            }
            return (.empty, false)
        }
    }
    
    func colorize(check: SquareStatus, row: [Int]) {
        withAnimation {
            if check == .x {
                squares[row[0]].squareStatus = .xw
                squares[row[1]].squareStatus = .xw
                squares[row[2]].squareStatus = .xw
            } else {
                squares[row[0]].squareStatus = .ow
                squares[row[1]].squareStatus = .ow
                squares[row[2]].squareStatus = .ow
            }
        }
        _gameOver = true
    }
    
    func makeMove(index: Int, gameType: Bool) -> Bool {
        var player: SquareStatus
        if playerToMove == false {
            player = .x
        } else {
            player = .o
        }
        if squares[index].squareStatus == .empty {
            squares[index].squareStatus = player
            if playerToMove == false && gameType == false && gameOver.1 == false {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.moveAI()
                    TicTacToeView.triggerHapticFeedback(type: 2)
                    _ = self.gameOver
                }
            }
            playerToMove.toggle()
            _ = self.gameOver
            onClick?(index)
            return true
        }
        return false
    }
    
    var getBoard: [SquareStatus] {
        var moves: Array = [SquareStatus]()
        for i in 0...8 {
            moves.append(squares[i].squareStatus)
        }
        return moves
    }
    
    private func moveAI() {
        let boardMoves: [SquareStatus] = getBoard
        let testBoard: Board = Board(position: boardMoves, turn: .o, lastMove: -1)
        let answer = testBoard.findBestMove(testBoard)
        playerToMove = true
        _ = makeMove(index: answer, gameType: true)
    }
    
    private var winner: (SquareStatus, [Int]) {
        get {
            if let check = self.checkIndexes([0, 1, 2]) {
                return (check, [0, 1, 2])
            } else if let check = self.checkIndexes([3, 4, 5]) {
                return (check, [3, 4, 5])
            } else if let check = self.checkIndexes([6, 7, 8]) {
                return (check, [6, 7, 8])
            } else if let check = self.checkIndexes([0, 3, 6]) {
                return (check, [0, 3, 6])
            } else if let check = self.checkIndexes([1, 4, 7]) {
                return (check, [1, 4, 7])
            } else if let check = self.checkIndexes([2, 5, 8]) {
                return (check, [2, 5, 8])
            } else if let check = self.checkIndexes([0, 4, 8]) {
                return (check, [0, 4, 8])
            } else if let check = self.checkIndexes([2, 4, 6]) {
                return (check, [2, 4, 6])
            }
            return (.empty, [])
        }
    }
    
    private func checkIndexes(_ indexes : [Int]) -> SquareStatus? {
        var xCount : Int = 0
        var oCount : Int = 0
        for index in indexes {
            let square = squares[index]
            if square.squareStatus == .x || square.squareStatus == .xw {
                xCount += 1
            } else if square.squareStatus == .o || square.squareStatus == .ow {
                oCount += 1
            }
        }
        if xCount == 3 {
            return .x
        } else if oCount == 3 {
            return .o
        }
        return nil
    }
}

