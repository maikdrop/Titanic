//
//  FileHandler.swift
//  Titanic
//
//  Created by Maik on 02.07.20.
//  Copyright © 2020 maikdrop. All rights reserved.
//

import Foundation

class FileHandler {
    
    private let url = try? FileManager.default.url(
                        for: .applicationSupportDirectory,
                        in: .userDomainMask,
                        appropriateFor: nil,
                        create: true)
                        .appendingPathComponent("highscore.json")
    
    typealias Handler = (Result<[Player], Error>) -> Void
    
    func loadPlayerFile(then handler: @escaping Handler){
        if let url = url {
            if !FileManager.default.fileExists(atPath: url.path) {
                handler(.success([Player]()))
                return
            }
            if let data = try? Data(contentsOf: url){
                do {
                    let player = try JSONDecoder().decode([Player].self, from: data)
                    handler(.success(player))
                } catch {
                    handler(.failure(error))
                }
            }
        }
    }
    
    func savePlayerToFile(player: [Player], then handler: Handler) {
        if let url = url, let json = try? JSONEncoder().encode(player)  {
            do {
                try json.write(to: url)
            } catch {
                handler(.failure(error))
            }
        }
        
    }
}
