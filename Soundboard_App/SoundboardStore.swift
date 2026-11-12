//
//  SoundboardStore.swift
//  Soundboard_App
//
//  Created by Corbett Manser on 11/11/26.
//


import SwiftUI
import AVFoundation

struct Pad: Identifiable, Codable {
    var id = UUID()
    var title: String
    var fileName: String?   // name of the copy stored in Documents/Sounds
}

@MainActor
final class SoundboardStore: ObservableObject {
    @Published var pads: [Pad] {
        didSet { save() }
    }

    private var players: [UUID: AVAudioPlayer] = [:]
    private let fm = FileManager.default

    private var docs: URL { fm.urls(for: .documentDirectory, in: .userDomainMask)[0] }
    private var soundsDir: URL { docs.appendingPathComponent("Sounds", isDirectory: true) }
    private var padsFile: URL { docs.appendingPathComponent("pads.json") }

    init() {
        try? fm.createDirectory(at: soundsDir, withIntermediateDirectories: true)

        if let data = try? Data(contentsOf: padsFile),
           let saved = try? JSONDecoder().decode([Pad].self, from: data) {
            pads = saved
        } else {
            pads = (1...12).map { Pad(title: "Pad \($0)") }
        }

        // Lets sounds play even when the silent switch is on
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
        try? AVAudioSession.sharedInstance().setActive(true)
    }

    // MARK: - Playback

    func play(_ pad: Pad) {
        guard let name = pad.fileName else { return }
        let url = soundsDir.appendingPathComponent(name)
        do {
            let player: AVAudioPlayer
            if let existing = players[pad.id] {
                player = existing
            } else {
                player = try AVAudioPlayer(contentsOf: url)
                player.prepareToPlay()
                players[pad.id] = player
            }
            player.currentTime = 0
            player.play()
        } catch {
            print("Could not play \(name): \(error)")
        }
    }

    // MARK: - Editing pads

    /// Copies the picked file into the app's sandbox and maps it to the pad.
    func assign(url: URL, to id: UUID) {
        guard let idx = pads.firstIndex(where: { $0.id == id }) else { return }

        let accessing = url.startAccessingSecurityScopedResource()
        defer { if accessing { url.stopAccessingSecurityScopedResource() } }

        let ext = url.pathExtension.isEmpty ? "mp3" : url.pathExtension
        let newName = "\(UUID().uuidString).\(ext)"
        let dest = soundsDir.appendingPathComponent(newName)

        do {
            try fm.copyItem(at: url, to: dest)
            removeFile(for: pads[idx])
            players[id]?.stop()
            players[id] = nil
            pads[idx].fileName = newName
            pads[idx].title = url.deletingPathExtension().lastPathComponent
        } catch {
            print("Could not import file: \(error)")
        }
    }

    func clearSound(_ id: UUID) {
        guard let idx = pads.firstIndex(where: { $0.id == id }) else { return }
        removeFile(for: pads[idx])
        players[id]?.stop()
        players[id] = nil
        pads[idx].fileName = nil
    }

    func rename(_ id: UUID, to title: String) {
        guard let idx = pads.firstIndex(where: { $0.id == id }) else { return }
        pads[idx].title = title
    }

    func addPad() {
        pads.append(Pad(title: "Pad \(pads.count + 1)"))
    }

    func delete(_ id: UUID) {
        if let pad = pads.first(where: { $0.id == id }) { removeFile(for: pad) }
        players[id]?.stop()
        players[id] = nil
        pads.removeAll { $0.id == id }
    }

    // MARK: - Helpers

    private func removeFile(for pad: Pad) {
        guard let name = pad.fileName else { return }
        try? fm.removeItem(at: soundsDir.appendingPathComponent(name))
    }

    private func save() {
        if let data = try? JSONEncoder().encode(pads) {
            try? data.write(to: padsFile, options: .atomic)
        }
    }
}
