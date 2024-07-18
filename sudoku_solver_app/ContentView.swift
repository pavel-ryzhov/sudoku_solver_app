//
//  ContentView.swift
//  sudoku_solver_app
//
//  Created by pavel on 21/04/2024.
//

import SwiftUI

struct ContentView: View {
    
    let impactFeedbackGenerator = UIImpactFeedbackGenerator(style: .heavy)
    @State var isIllegalInputAlertPresented = false
    @State var sourceArr = Array(repeating: Array(repeating: 0, count: 9), count: 9)
    @State var focus: (hLine: Int, vLine: Int)?
    //private var field: Field?
    
    var body: some View {
        
        VStack {
            FieldView(sourceArr: $sourceArr, focus: $focus)
            HStack {
                ForEach(1..<10) { i in
                    NumberButton(number: i) {
                        if let f = focus {
                            sourceArr[f.hLine][f.vLine] = sourceArr[f.hLine][f.vLine] != i ? i : 0
                        }
                    }
                    .padding(.top, 32)
                }
            }
            HStack {
                Spacer()
                Button("Clear") {
                    sourceArr = Array(repeating: Array(repeating: 0, count: 9), count: 9)
                    focus = nil
                }
                .padding(8)
                .background(Color.blue.cornerRadius(6).shadow(radius: 8, y: 8))
                .foregroundColor(.white)
                .font(.title2)
                Spacer()
                Button("Solve") {
                    initField()
                }
                .padding(8)
                .background(Color.blue.cornerRadius(6).shadow(radius: 8, y: 8))
                .foregroundColor(.white)
                .font(.title2)
                Spacer()
            }
            .padding(.top, 32)
            
            Spacer()
        }
        .frame(maxHeight: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
        .padding()
        .padding(.top, 50)
        .background(.white)
        .alert("It seems that the entered data is incorrect!", isPresented: $isIllegalInputAlertPresented) {
            Button("OK") {}
        }
    }
    
    private func initField() {
        let field = Field(sourceArr, onNumberFound: { hLine, vLine, n in
            sourceArr[hLine][vLine] = n
        }, onFinished: {
            print("Success!")
        }, onIllegalInput: {
            isIllegalInputAlertPresented = true
            impactFeedbackGenerator.impactOccurred()
        })
        field.process()
    }
}

#Preview {
    ContentView()
}
