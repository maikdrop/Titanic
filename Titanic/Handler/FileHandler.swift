//
//  FileHandler.swift
//  Titanic
//
//  Created by Maik on 02.07.20.
//  Copyright © 2020 maikdrop. All rights reserved.
//

import Foundation

struct FileHandler {

    // MARK: - Properties
    private let url = try? FileManager.default.url(
                        for: .applicationSupportDirectory,
                        in: .userDomainMask,
                        appropriateFor: nil,
                        create: true)
                        .appendingPathComponent("highscore.json")

    typealias Handler = (Result<[TitanicGame.Player], Error>) -> Void

    // MARK: - Public API
    func loadPlayerFile(then handler: Handler) {
        if let url = url {
            if !FileManager.default.fileExists(atPath: url.path) {
                handler(.success([TitanicGame.Player]()))
                return
            }
            if let data = try? Data(contentsOf: url) {
                do {
                    let player = try JSONDecoder().decode([TitanicGame.Player].self, from: data)
                    handler(.success(player))
                } catch {
                    handler(.failure(error))
                }
            }
        }
    }

    func savePlayerToFile(player: [TitanicGame.Player], then handler: Handler) {
        if let url = url, let json = try? JSONEncoder().encode(player) {
            do {
                try json.write(to: url)
                 handler(.success(player))
            } catch {
                handler(.failure(error))
            }
        }
    }
}
