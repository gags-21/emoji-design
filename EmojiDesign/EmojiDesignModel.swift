//
//  EmojiDesignModel.swift
//  EmojiDesign
//
//  Created by Gagan Bhirangi on 02/01/23.
//

import Foundation

struct EmojiDesignModel {
    var background = Backgoround.blank
    var emojis = [Emoji]()
    
    struct Emoji : Identifiable, Hashable {
        let text: String
        var x: Int
        var y: Int
        var size: Int
        let id: Int
        
        fileprivate init(text: String, x: Int, y: Int, size: Int, id: Int) {
            self.text = text
            self.x = x
            self.y = y
            self.size = size
            self.id = id
        }
    }
    
    init () {}
    
    private var uniqueEmojiId = 0
    
    mutating func emojiAdd (_ text: String, at location: (x: Int, y:Int ), size: Int) {
        uniqueEmojiId += 1
        emojis.append(Emoji(text: text, x: location.x, y: location.y, size: size, id: uniqueEmojiId))
    }
}