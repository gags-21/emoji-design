//
//  EmojiDsignDocument.swift
//  EmojiDesign
//
//  Created by Gagan Bhirangi on 02/01/23.
//

import SwiftUI

class EmojiDesignDocument: ObservableObject
{
    @Published private(set) var emojiDesign: EmojiDesignModel
    
    init (){
        emojiDesign = EmojiDesignModel()
        emojiDesign.emojiAdd("😀", at: (-200, 100), size: 70)
        emojiDesign.emojiAdd("🤦‍♂️", at: (100, 50), size: 30)
    }
    
    var emojis: [EmojiDesignModel.Emoji] {emojiDesign.emojis}
    var background: EmojiDesignModel.Backgoround {emojiDesign.background}
    
    
    // MARK:    - Intent(s)
    
    func setBackground (_ background: EmojiDesignModel.Backgoround) {
        emojiDesign.background = background
    }
    
    func addEmoji(_ emoji: String, at location: (x: Int, y: Int), size: CGFloat) {
        emojiDesign.emojiAdd(emoji, at: location, size: Int(size))
    }
    
    func moveEmoji(_ emoji: EmojiDesignModel.Emoji, by offset: CGSize) {
        if let index = emojiDesign.emojis.index(matching: emoji) {
            emojiDesign.emojis[index].x += Int(offset.width)
            emojiDesign.emojis[index].x += Int(offset.height)
        }
    }
    
    func scaleEmoji(_ emoji: EmojiDesignModel.Emoji, by scale: CGFloat) {
        if let index = emojiDesign.emojis.index(matching: emoji) {
            emojiDesign.emojis[index].size = Int((CGFloat(emojiDesign.emojis[index].size) * scale).rounded(.toNearestOrAwayFromZero))
        }
    }
    
}
