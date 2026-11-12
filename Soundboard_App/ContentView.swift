//
//  ContentView.swift
//  Soundboard_App
//
//  Created by Corbett Manser on 11/11/26.
//

import SwiftUI

struct ContentView: View {
    @State private var pads: [Pad] = (1...12).map { Pad(title: "Pad \($0)") }

    private let columns = [GridItem(.adaptive(minimum: 100), spacing: 12)]

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(pads) { pad in
                        PadButton(pad: pad) {
                            print("Tapped \(pad.title)")
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Soundboard")
        }
    }
}

#Preview {
    ContentView()
}
