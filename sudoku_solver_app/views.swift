//
//  views.swift
//  sudoku_solver_app
//
//  Created by pavel on 21/04/2024.
//

import SwiftUI


struct ButtonWithPositionInField : View {
    private let position: (hLine: Int, vLine: Int)
    private let action: () -> Void
    @State var value: String = "8"
    init(hLine: Int, vLine: Int, action: @escaping () -> Void) {
        self.position = (hLine, vLine)
        self.action = action
    }
    func getHLine() -> Int {
        return position.hLine
    }
    func getVLine() -> Int {
        return position.vLine
    }
    mutating func setValue(_ v: Int) {
//        if v == 0 {
//            value = ""
//        } else {
//            value = "\(v)"
//        }
//        print("\(value) \(v)")
//        value = "\(v + 1)"
//        print("\(value) \(v)")
//        print("=========")
    }
    func getValue() -> Int {
        return value == "" ? 0 : Int(value)!
    }
    var body: some View {
        Button(value, action: action)
    }
}

//struct NumberButton : View {
//    private let number: Int
//    private let action: () -> Void
//    init(number: Int, action: @escaping () -> Void) {
//        self.number = number
//        self.action = action
//    }
//    func getNumber() -> Int {
//        return number
//    }
//    var body: some View {
//        Button("\(number)", action: action).square()
//    }
//}
