//
//  PaletteBar.swift
//  EmojiDesign
//
//  Created by Gagan Bhirangi on 25/01/23.
//

import SwiftUI

struct Palette: Identifiable, Codable {
    var name: String
    var emojis: String
    var id: Int
}

class PaletteBar: ObservableObject {
    
    let name: String
    
    @Published var palettes = [Palette]() {
        didSet {
            storeInUserDefaults()
        }
    }
    
    private var userDefaultKeys: String {
        "PaletteStore: " + name
    }
    
    private func storeInUserDefaults() {
        
        UserDefaults.standard.setValue(try? JSONEncoder().encode(palettes), forKey: userDefaultKeys)
        
//        UserDefaults.standard.set(palettes.map { [String($0.id), $0.name, $0.emojis] }, forKey: userDefaultKeys)
    }
    
    private func restoreFromUserDefaults() {
        
        if let jsonData = UserDefaults.standard.data(forKey: userDefaultKeys),
           let decodedPalettes = try? JSONDecoder().decode(Array<Palette>.self, from: jsonData) {
            palettes = decodedPalettes
        }
        
//        if let palettesAsPropertyList = UserDefaults.standard.array(forKey: userDefaultKeys) as? [[String]] {
//            for palettesAsArray in palettesAsPropertyList {
//                if palettesAsArray.count == 3, let id = Int(palettesAsArray[0]), !palettes.contains(where: {$0.id == id}) {
//                    let palette = Palette(name: ..[1], emojis: ..[2], id: [0])
//                    palettes.append(contentsOf: palette)
//                }
//            }
//        }
    }
    
    init(named name: String) {
        self.name = name
        restoreFromUserDefaults()
        if palettes.isEmpty {
            print("using built-in Palettes")
            insertPalette(named: "Vehicles", emojis: "🚝🖥️🖨️🖲️🗜️🔨")
            insertPalette(named: "Sports", emojis: "🤦‍♂️😅😀😶‍🌫️🚃🖥️🖨️🖲️🗜️🔨")
            insertPalette(named: "Animals", emojis: "🏦📻💻⌨️🚝🖥️🖨️🖲️🗜️🔨")
            insertPalette(named: "Faces", emojis: "🤦‍♂️😅😀😶‍🌫️🖨️🖲️🗜️🔨")
        } else {
            print("Sucessfully loaded from userdefaults \(palettes)")
        }
    }
    
    // MARK: - Intent
    
    func palette(at index: Int) -> Palette {
        let safeIndex = min(max(index, 0), palettes.count - 1)
        return palettes[safeIndex]
    }
    
    @discardableResult
    func removePalette(at index: Int) -> Int {
        if palettes.count > 1, palettes.indices.contains (index) {
            palettes.remove(at: index)
        }
        return index % palettes.count
    }
    
    func insertPalette(named name: String, emojis: String? = nil, at index: Int = 0) {
        let unique = (palettes.max(by: { $0.id < $1.id })?.id ?? 0) + 1
        let palette = Palette (name: name, emojis: emojis ?? "", id: unique)
        let safeIndex = min(max(index, 0), palettes.count)
        palettes.insert(palette, at: safeIndex)
    }
    
}
