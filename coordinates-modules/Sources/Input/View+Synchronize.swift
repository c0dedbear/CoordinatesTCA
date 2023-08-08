//
//  View+Synchronize.swift
//  Coordinates
//
//  Created by Mikhail Medvedev on 07.08.2023.
//

import SwiftUI

extension View {
    func synchronize<Value>(
        _ first: Binding<Value>,
        _ second: FocusState<Value>.Binding
    ) -> some View {
        self
            .onChange(of: first.wrappedValue) { second.wrappedValue = $0 }
            .onChange(of: second.wrappedValue) { first.wrappedValue = $0 }
    }
}
