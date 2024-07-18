//
//  FieldView.swift
//  sudoku_solver_app
//
//  Created by pavel on 24/04/2024.
//

import SwiftUI

struct FieldView: View {
    
    @Binding var sourceArr: [[Int]]
    @Binding var focus: (hLine: Int, vLine: Int)?
        
    var body: some View {
        VStack(spacing: 2) {
            ForEach(0..<9) { i in
                HStack(spacing: 2) {
                    ForEach(0..<9) { j in
                        Button(action: {
                            focus = (focus != nil && focus! == (i, j)) ? nil : (i, j)
                        }, label: {
                            Text(getText(hLine: i, vLine: j))
                                .font(.title)
                                .foregroundColor(.black)
                                .square()
                                .background(.white)
                        })
                        .foregroundColor(chooseBackground(hLine: i, vLine: j))
                        .buttonStyle(NoTapAnimationStyle())
                    }
                }
            }
        }
        .padding(2)
        .background(.lightgrey)
        .overlay {
            VStack {
                Rectangle()
                    .frame(height: 2)
                    .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
                    .foregroundColor(.black)
                ForEach(0..<3) { _ in
                    Spacer()
                    Rectangle()
                        .frame(height: 2)
                        .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
                        .foregroundColor(.black)
                }
            }
        }
        .overlay {
            HStack {
                Rectangle()
                    .frame(width: 2)
                    .frame(maxHeight: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
                    .foregroundColor(.black)
                ForEach(0..<3) { _ in
                    Spacer()
                    Rectangle()
                        .frame(width: 2)
                        .frame(maxHeight: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
                        .foregroundColor(.black)
                }
            }
        }
    }
    
    func getText(hLine: Int, vLine: Int) -> String {
        let n = sourceArr[hLine][vLine]
        return n == 0 ? "" : "\(n)"
    }
    
    func chooseBackground(hLine: Int, vLine: Int) -> Color {
        let color: Color
        if focus == nil {
            color = .white
        } else if focus! == (hLine, vLine) {
            color = .blue
        } else if focus!.hLine == hLine || focus!.vLine == vLine || isFocusInSquare(fhLine: focus!.hLine, fvLine: focus!.vLine, hLine: hLine, vLine: vLine) {
            color = .blue.opacity(0.3)
        } else {
            color = .white
        }
        return color
    }
    
    func isFocusInSquare(fhLine: Int, fvLine: Int, hLine: Int, vLine: Int) -> Bool {
        Field.Square.getByPos(hLine: hLine, vLine: vLine) == Field.Square.getByPos(hLine: fhLine, vLine: fvLine)
    }
    
}

struct NoTapAnimationStyle : PrimitiveButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .contentShape(Rectangle())
            .onTapGesture(perform: configuration.trigger)
    }
}
