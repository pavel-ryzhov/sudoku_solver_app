//
//  NumberButton.swift
//  sudoku_solver_app
//
//  Created by pavel on 25/04/2024.
//

import SwiftUI

struct NumberButton : View {
    private let number: Int
    private let action: () -> Void
    init(number: Int, action: @escaping () -> Void) {
        self.number = number
        self.action = action
    }
    func getNumber() -> Int {
        return number
    }
    var body: some View {
        Button(action: action) {
            Text("\(number)")
                .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                .shadow(radius: 3, y: 1)
                .foregroundColor(.black)
                .square()
                .foregroundColor(.white)
        }
    }
}

#Preview {
    NumberButton(number: 2, action: {})
}
