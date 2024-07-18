//
//  extensions.swift
//  sudoku_solver_app
//
//  Created by pavel on 26/04/2024.
//

import Foundation
import SwiftUI

extension View {
    @warn_unqualified_access
    func square() -> some View {
        Rectangle()
            .aspectRatio(1, contentMode: .fit)
            .overlay(
                self
                    .scaledToFill()
            )
            .clipShape(Rectangle())
    }
}
