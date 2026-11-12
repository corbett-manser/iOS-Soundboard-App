//
//  ContentView.swift
//  Soundboard_App
//
//  Created by Corbett Manser on 11/11/26.
//

import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @EnvironmentObject var store: SoundboardStore

    @State private var padBeingEdited: UUID?
    @State private var showImporter = false
    @State private var renamingID: UUID?
    @State private var newTitle = ""
    @State private var showRename = false

    private let columns = [GridItem(.adaptive(minimum: 100), spacing: 12)]

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(store.pads) { pad in
                        PadButton(pad: pad) {
                            if pad.fileName == nil {
                                chooseSound(for: pad.id)
                            } else {
                                store.play(pad)
                            }
                        }
                        .contextMenu {
                            Button("Choose Sound…", systemImage: "folder") {
                                chooseSound(for: pad.id)
                            }
                            Button("Rename", systemImage: "pencil") {
                                renamingID = pad.id
                                newTitle = pad.title
                                showRename = true
                            }
                            if pad.fileName != nil {
                                Button("Remove Sound", systemImage: "speaker.slash") {
                                    store.clearSound(pad.id)
                                }
                            }
                            Button("Delete Pad", systemImage: "trash", role: .destructive) {
                                store.delete(pad.id)
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Soundboard")
            .toolbar {
                Button("Add Pad", systemImage: "plus") { store.addPad() }
            }
        }
        .fileImporter(isPresented: $showImporter,
                      allowedContentTypes: [.audio]) { result in
            if case .success(let url) = result, let id = padBeingEdited {
                store.assign(url: url, to: id)
            }
            padBeingEdited = nil
        }
        .alert("Rename Pad", isPresented: $showRename) {
            TextField("Name", text: $newTitle)
            Button("Save") {
                if let id = renamingID { store.rename(id, to: newTitle) }
            }
            Button("Cancel", role: .cancel) {}
        }
    }

    private func chooseSound(for id: UUID) {
        padBeingEdited = id
        showImporter = true
    }
}

struct PadButton: View {
    let pad: Pad
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: pad.fileName == nil ? "plus.circle" : "play.fill")
                    .font(.title2)
                Text(pad.title)
                    .font(.footnote.weight(.semibold))
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, minHeight: 100)
            .padding(8)
            .background(pad.fileName == nil ? Color.gray : Color.blue,
                        in: RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
    }
}
