//
//  Board.swift
//  AnonymousChat
//
//  Created by Karl on 18/4/2024.
//

import Foundation

struct Board {
    let pos: [SquareStatus]
    let turn: SquareStatus
    let lastMove: Int
    let opposite: SquareStatus
    
    init(position: [SquareStatus] = [.empty, .empty, .empty, .empty, .empty, .empty, .empty, .empty, .empty], turn: SquareStatus = .x, lastMove: Int = -1) {
        self.pos = position
        self.turn = turn
        self.lastMove = lastMove
        self.opposite = turn == .x ? .o : .x
    }
    
    func move(_ location: Int) -> Board {
        var tempPosition = pos
        tempPosition[location] = turn
        return Board(position: tempPosition, turn: opposite, lastMove: location)
    }
    
    var legalMoves: [Int] {
        return pos.indices.filter { pos[$0] == .empty }
    }
    
    var isWin: Bool {
        return pos[0] == pos[1] && pos[0] == pos[2] && pos[0] != .empty ||
        pos[3] == pos[4] && pos[3] == pos[5] && pos[3] != .empty ||
        pos[6] == pos[7] && pos[6] == pos[8] && pos[6] != .empty ||
        pos[0] == pos[3] && pos[0] == pos[6] && pos[0] != .empty ||
        pos[1] == pos[4] && pos[1] == pos[7] && pos[1] != .empty ||
        pos[2] == pos[5] && pos[2] == pos[8] && pos[2] != .empty ||
        pos[0] == pos[4] && pos[0] == pos[8] && pos[0] != .empty ||
        pos[2] == pos[4] && pos[2] == pos[6] && pos[2] != .empty
    }
    
    var isDraw: Bool {
        return !isWin && legalMoves.count == 0
    }
    
    func minimax(_ board: Board, maximizing: Bool, originalPlayer: SquareStatus) -> Int {
        if board.isWin && originalPlayer == board.opposite { return 1 }
        else if board.isWin && originalPlayer != board.opposite { return -1 }
        else if board.isDraw { return 0 }
      
        if maximizing {
            var bestEval = Int.min
            for move in board.legalMoves {
                let result = minimax(board.move(move), maximizing: false, originalPlayer: originalPlayer)
                bestEval = max(result, bestEval)
            }
            return bestEval
        } else {
            var worstEval = Int.max
            for move in board.legalMoves {
                let result = minimax(board.move(move), maximizing: true, originalPlayer: originalPlayer)
                worstEval = min(result, worstEval)
            }
            return worstEval
        }
    }
    
    func findBestMove(_ board: Board) -> Int {
        var bestEval = Int.min
        var bestMove = -1
        for move in board.legalMoves {
            let result = minimax(board.move(move), maximizing: false, originalPlayer: board.turn)
            if result > bestEval {
                bestEval = result
                bestMove = move
            }
        }
        return bestMove
    }
}
