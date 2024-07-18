//
//  sudoku_solver.swift
//
//  Created by pavel on 20/04/2024.
//

import Foundation


typealias OptFuncWithPosition = ((_ hLine: Int, _ vLine: Int, _ n: Int) -> Void)?
typealias OptFunc = (() -> Void)?

class Field {
    
    private let onNumberFound: OptFuncWithPosition
    private let onFinished: OptFunc
    private let onIllegalInput: OptFunc
    private var squares = [Square]()
    private var arr: [[Int]]
    private var possibleNumbers = Array(repeating: Array(repeating: Set<Int>(), count: 9), count: 9)
    private var numberFound = false
    
    init(_ arr: [[Int]], onNumberFound: OptFuncWithPosition = nil, onFinished: OptFunc = nil, onIllegalInput: OptFunc = nil) {
        self.arr = arr
        self.onNumberFound = onNumberFound
        self.onFinished = onFinished
        self.onIllegalInput = onIllegalInput
        for i in 0..<9 {
            squares.append(Square(field: self, i))
        }
    }
    
    private func checkForCorrectInput() -> Bool {
        for i in 0..<9 {
            guard checkForCorrectHLine(i) && checkForCorrectVLine(i) && checkForCorrectSquare(i) else {
                return false
            }
        }
        return true
    }
    
    private func checkForCorrectHLine(_ hLine: Int) -> Bool {
        return !arr[hLine].filter{ $0 != 0 }.hasDuplicates()
    }
    
    private func checkForCorrectVLine(_ vLine: Int) -> Bool {
        var a = [Int]()
        for line in arr {
            a.append(line[vLine])
        }
        return !a.filter{ $0 != 0 }.hasDuplicates()
    }
    
    private func checkForCorrectSquare(_ n: Int) -> Bool {
        return !squares[n].checkForDuplicates()
    }
    
    subscript(_ hLine: Int, _ vLine: Int) -> Int {
        get {
            arr[hLine][vLine]
        }
        set {
            arr[hLine][vLine] = newValue
        }
    }
    
    func getArr() -> [[Int]] {
        return arr
    }
    
    private func isInHLine(line: Int, _ n: Int) -> Bool {
        arr[line].contains(n)
    }
    
    private func isInVLine(line: Int, _ n: Int) -> Bool {
        for i in arr {
            if i[line] == n {
                return true
            }
        }
        return false
    }
    
    private func getLastPossiblePosInVLine(line: Int, _ n: Int) -> Int {
        for (i, l) in possibleNumbers.enumerated().reversed() {
            if l[line].contains(n) {
                return i
            }
        }
        return -1
    }
    
    private func getFirstPossiblePosInHLine(line: Int, _ n: Int) -> Int {
        return Field.firstPos(arr: possibleNumbers[line], n)
    }
    
    private func getLastPossiblePosInHLine(line: Int, _ n: Int) -> Int {
        return Field.lastPos(arr: possibleNumbers[line], n)
    }
    
    private func getFirstPossiblePosInVLine(line: Int, _ n: Int) -> Int {
        for (i, l) in possibleNumbers.enumerated() {
            if l[line].contains(n) {
                return i
            }
        }
        return -1
    }
    
    private func getFirstPossiblePosInSquare(square: Int, _ n: Int) -> Int {
        return squares[square].getFirstPossiblePos(n)
    }
    
    private func getLastPossiblePosInSquare(square: Int, _ n: Int) -> Int {
        return squares[square].getLastPossiblePos(n)
    }
    
    private func isInSquare(square: Int, _ n: Int) -> Bool {
        return squares[square].isIn(n)
    }
    
    private func isAloneInHLine(line: Int, _ n: Int) -> Bool {
        let firstPos = getFirstPossiblePosInHLine(line: line, n)
        let lastPos = getLastPossiblePosInHLine(line: line, n)
        return firstPos != -1 && firstPos == lastPos
    }
    
    private func isAloneInVLine(line: Int, _ n: Int) -> Bool {
        let firstPos = getFirstPossiblePosInVLine(line: line, n)
        let lastPos = getLastPossiblePosInVLine(line: line, n)
        return firstPos != -1 && firstPos == lastPos
    }
    
    private func isAloneInSquare(square: Int, _ n: Int) -> Bool {
        return squares[square].isAlone(n)
    }
    
    func printSelf() {
        for i in arr.indices {
            for j in arr[i].indices {
                print(arr[i][j], terminator: " ")
            }
            print()
        }
    }
    
    private func numberFound(hLine: Int, vLine: Int, _ n: Int) {
        numberFound = true
        arr[hLine][vLine] = n
        possibleNumbers[hLine][vLine] = []
        removePossibleFromHLine(line: hLine, n)
        removePossibleFromVLine(line: vLine, n)
        removePossiblePromSquare(square: Square.getByPos(hLine: hLine, vLine: vLine), n)
        if let fun = onNumberFound {
            fun(hLine, vLine, n)
        }
    }

    private func removePossiblePromSquare(square: Int, _ n: Int, except: [(Int, Int)] = []) {
        squares[square].removePossible(n, except: except)
    }
    
    private func computePossibleNumbers() {
        for i in arr.indices {
            for j in arr[i].indices {
                if arr[i][j] == 0 {
                    for n in 1...9 {
                        if !isInHLine(line: i, n) && !isInVLine(line: j, n) && !isInSquare(square: Square.getByPos(hLine: i, vLine: j), n) && !possibleNumbers[i][j].contains(n){
                            possibleNumbers[i][j].insert(n)
                        }
                    }
                }
            }
        }
    }
    
    private var pairFound = false
    private var foundPairsInVLines = [((Int, Int), (Int, Int))]()
    private var foundPairsInHLines = [((Int, Int), (Int, Int))]()
    private var foundPairsInSquares = [((Int, Int), (Int, Int))]()
    
    private var tripleFound = false
    private var foundTriplesInVLines = [((Int, Int), (Int, Int), (Int, Int))]()
    private var foundTriplesInHLines = [((Int, Int), (Int, Int), (Int, Int))]()
    private var foundTriplesInSquares = [((Int, Int), (Int, Int), (Int, Int))]()
    
    private func findTriples() {
         repeat {
             tripleFound = false
             for i in 0..<9 {
                 findTriplesInHLine(line: i)
                 findTriplesInVLine(line: i)
                 squares[i].findTriples()
             }
         } while tripleFound
    }
    
    private func findPairs() {
        repeat {
            pairFound = false
            for i in 0..<9 {
                findPairsInHLine(line: i)
                findPairsInVLine(line: i)
                squares[i].findPairs()
            }
        } while pairFound
    }
    
    private func checkIfPairIsFound(foundPairs: inout [((Int, Int), (Int, Int))], p0: (Int, Int), p1: (Int, Int)) -> Bool {
        let result = !foundPairs.contains(where: { $0.0 == p0 && $0.1 == p1 })
        if result {
            pairFound = true
            foundPairs.append((p0, p1))
        }
        return result
    }
    
    private func checkIfTripleIsFound(foundTriples: inout [((Int, Int), (Int, Int), (Int, Int))], p0: (Int, Int), p1: (Int, Int), p2: (Int, Int)) -> Bool {
        let result = !foundTriples.contains(where: { $0.0 == p0 && $0.1 == p1 && $0.2 == p2})
        if result {
            tripleFound = true
            foundTriples.append((p0, p1, p2))
        }
        return result
    }
    
    private func removePossibleFromHLine(line: Int, _ n: Int, except: [Int] = []) {
        for i in possibleNumbers[line].indices where !except.contains(i) {
            possibleNumbers[line][i].remove(n)
        }
    }
    
    private func removePossibleFromVLine(line: Int, _ n: Int, except: [Int] = []) {
        for i in possibleNumbers.indices where !except.contains(i) {
            possibleNumbers[i][line].remove(n)
        }
    }
    
    private func pairFoundInHLine(line: Int, pos0: Int, pos1: Int) {
        if checkIfPairIsFound(foundPairs: &foundPairsInHLines, p0: (line, pos0), p1: (line, pos1)) {
            for i in possibleNumbers[line][pos0] {
                removePossibleFromHLine(line: line, i, except: [pos0, pos1])
            }
        }
    }
    
    private func pairFoundInVLine(line: Int, pos0: Int, pos1: Int) {
        if checkIfPairIsFound(foundPairs: &foundPairsInVLines, p0: (pos0, line), p1: (pos1, line)) {
            for i in possibleNumbers[pos0][line] {
                removePossibleFromVLine(line: line, i, except: [pos0, pos1])
            }
        }
    }
    
    private func tripleFoundInHLine(line: Int, pos0: Int, pos1: Int, pos2: Int) {
        if checkIfTripleIsFound(foundTriples: &foundTriplesInHLines, p0: (line, pos0), p1: (line, pos1), p2: (line, pos2)) {
            for i in possibleNumbers[line].unionOf(pos0, pos1, pos2) {
                removePossibleFromHLine(line: line, i, except: [pos0, pos1, pos2])
            }
        }
    }
    
    private func tripleFoundInVLine(line: Int, pos0: Int, pos1: Int, pos2: Int) {
        if checkIfTripleIsFound(foundTriples: &foundTriplesInVLines, p0: (pos0, line), p1: (pos1, line), p2: (pos2, line)) {
            for i in possibleNumbers[pos0][line].union(possibleNumbers[pos1][line]).union(possibleNumbers[pos2][line]) {
                removePossibleFromVLine(line: line, i, except: [pos0, pos1, pos2])
            }
        }
    }
    
    private func findTriplesInHLine(line: Int) {
        if let t = Field.findTriplesInArray(arr: possibleNumbers[line]) {
            tripleFoundInHLine(line: line, pos0: t.0, pos1: t.1, pos2: t.2)
        }
    }
    
    private func findTriplesInVLine(line: Int) {
        if let t = Field.findTriplesInArray(arr: possibleNumbers.map { $0[line] }) {
            tripleFoundInVLine(line: line, pos0: t.0, pos1: t.1, pos2: t.2)
        }
    }
    
    private func findPairsInHLine(line: Int) {
        for i in possibleNumbers[line].indices {
            if possibleNumbers[line][i].count == 2 && i < 8 {
                for j in (i + 1)...8 {
                    if possibleNumbers[line][i] == possibleNumbers[line][j] {
                        pairFoundInHLine(line: line, pos0: i, pos1: j)
                    }
                }
            }
        }
    }
    
    private func findPairsInVLine(line: Int) {
        for i in possibleNumbers.indices {
            if possibleNumbers[i][line].count == 2 && i < 8 {
                for j in (i + 1)...8 {
                    if possibleNumbers[i][line] == possibleNumbers[j][line] {
                        pairFoundInVLine(line: line, pos0: i, pos1: j)
                    }
                }
            }
        }
    }
    
    private func checkForCorrectInputAndCallObserver() -> Bool {
        guard checkForCorrectInput() else {
            if let fun = onIllegalInput {
                fun()
            }
            return false
        }
        return true
    }
    
    func process() {
        if !checkForCorrectInputAndCallObserver() { return }
        computePossibleNumbers()
        repeat {
            numberFound = false
            findPairs()
            findTriples()
            for i in arr.indices {
                for j in arr[i].indices {
                    if possibleNumbers[i][j].count == 1 {
                        numberFound(hLine: i, vLine: j, possibleNumbers[i][j].first!)
                    } else {
                        for n in possibleNumbers[i][j] {
                            if isAloneInHLine(line: i, n) || isAloneInVLine(line: j, n) || isAloneInSquare(square: Square.getByPos(hLine: i, vLine: j), n) {
                                numberFound(hLine: i, vLine: j, n)
                                break
                            }
                        }
                    }
                }
            }
        } while numberFound
        if !checkForCorrectInputAndCallObserver() { return }
        if let fun = onFinished {
            fun()
        }
    }
    
    private static func firstPos(arr: [Set<Int>], _ n: Int) -> Int {
        for (i, s) in arr.enumerated() {
            if s.contains(n) {
                return i
            }
        }
        return -1
    }
    
    private static func lastPos(arr: [Set<Int>], _ n: Int) -> Int {
        for (i, s) in arr.enumerated().reversed() {
            if s.contains(n) {
                return i
            }
        }
        return -1
    }
    
    private static func findTriplesInArray(arr: [Set<Int>]) -> (Int, Int, Int)? {
        for i in 0..<(arr.count - 2) where !arr[i].isEmpty {
            for j in (i + 1)..<(arr.count - 1) where !arr[j].isEmpty {
                for k in (j + 1)..<arr.count where !arr[k].isEmpty {
                    if arr.unionOf(i, j, k).count == 3 {
                        return (i, j, k)
                    }
                }
            }
        }
        return nil
    }
    
    func isSolved() -> Bool {
        for i in arr {
            for j in i {
                if j == 0 {
                    return false
                }
            }
        }
        return true
    }
    
    struct Square {
        
        let index: Int
        let field: Field
        var points: [(Int, Int)]
        
        init(field: Field, _ n: Int) {
            index = n
            self.field = field
            points = Square.computePoints(n)
        }
        
        static func computePoints(_ n: Int) -> [(Int, Int)] {
            var result = [(Int, Int)]()
            result.reserveCapacity(9)
            for i in (n / 3 * 3)..<(n / 3 * 3 + 3) {
                for j in (n % 3 * 3)..<(n % 3 * 3 + 3) {
                    result.append((i, j))
                }
            }
            return result
        }
        
        func isIn(_ n: Int) -> Bool {
            for (i, j) in points {
                if field.arr[i][j] == n {
                    return true
                }
            }
            return false
        }
        
        func getFirstPossiblePos(_ n: Int) -> Int {
            for (i, pos) in points.enumerated() {
                if field.possibleNumbers[pos.0][pos.1].contains(n) {
                    return i
                }
            }
            return -1
        }
        
        func getLastPossiblePos(_ n: Int) -> Int {
            for (i, pos) in points.enumerated().reversed() {
                if field.possibleNumbers[pos.0][pos.1].contains(n) {
                    return i
                }
            }
            return -1
        }
        
        func isAlone(_ n: Int) -> Bool {
            let firstPos = getFirstPossiblePos(n)
            let lastPos = getLastPossiblePos(n)
            return firstPos != -1 && firstPos == lastPos
        }
        
        func removePossible(_ n: Int, except: [(Int, Int)] = []) {
            for p in points where !except.contains(where: { $0 == p }){
                field.possibleNumbers[p.0][p.1].remove(n)
            }
        }
        
        private func pairFound(pos0: Int, pos1: Int) {
            if field.checkIfPairIsFound(foundPairs: &field.foundPairsInSquares, p0: points[pos0], p1: points[pos1]) {
                for i in field.possibleNumbers[points[pos0].0][points[pos0].1] {
                    removePossible(i, except: [points[pos0], points[pos1]])
                }
            }
        }
        
        func findPairs() {
            for (i, p) in points.enumerated() {
                if field.possibleNumbers[p.0][p.1].count == 2 && i < 8 {
                    for j in (i + 1)...8 {
                        if field.possibleNumbers[p.0][p.1] == field.possibleNumbers[points[j].0][points[j].1] {
                            pairFound(pos0: i, pos1: j)
                        }
                    }
                }
            }
        }
        
        private func tripleFound(pos0: Int, pos1: Int, pos2: Int) {
            if field.checkIfTripleIsFound(foundTriples: &field.foundTriplesInSquares, p0: points[pos0], p1: points[pos1], p2: points[pos2]) {
                for i in field.possibleNumbers[points[pos0].0][points[pos0].1].union(field.possibleNumbers[points[pos1].0][points[pos1].1]).union(field.possibleNumbers[points[pos2].0][points[pos2].1]) {
                    removePossible(i, except: [points[pos0], points[pos1], points[pos2]])
                }
            }
        }
        
        func findTriples() {
            if let t = Field.findTriplesInArray(arr: points.map { field.possibleNumbers[$0.0][$0.1] }) {
                tripleFound(pos0: t.0, pos1: t.1, pos2: t.2)
            }
        }
        
        func checkForDuplicates() -> Bool {
            var a = [Int]()
            for (i, j) in points {
                a.append(field.arr[i][j])
            }
            return a.filter{ $0 != 0 }.hasDuplicates()
        }
        
        static func getByPos(hLine: Int, vLine: Int) -> Int {
            return hLine / 3 * 3 + vLine / 3
        }
    }
}

private extension Array where Element : Hashable {
    func hasDuplicates() -> Bool {
        return self.count != Set(self).count
    }
}

private extension Array where Element == Set<Int> {
    func unionOf(_ indices: Int...) -> Set<Int> {
        var result = Set<Int>()
        for i in indices {
            result.formUnion(self[i])
        }
        return result
    }
}
