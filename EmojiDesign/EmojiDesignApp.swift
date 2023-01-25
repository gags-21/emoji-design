//
//  EmojiDesignApp.swift
//  EmojiDesign
//
//  Created by Gagan Bhirangi on 02/01/23.
//

import SwiftUI

@main
struct EmojiDesignApp: App {
    
    let document = EmojiDesignDocument()
    let paletteBar = PaletteBar(named: "Default")
    
    var body: some Scene {
        WindowGroup {
            EmojiDesignDocumentView(document: document)
        }
    }
}
