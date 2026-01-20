//
//  ContentView.swift
//  Pause
//
//  Created by 施奇 on 2026/1/20.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text(HelloProvider.message())
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
