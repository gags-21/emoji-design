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
    
    var body: some Scene {
        WindowGroup {
            EmojiDesignDocumentView(document: document)
        }
    }
}
