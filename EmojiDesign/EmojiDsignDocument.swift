//
//  EmojiDsignDocument.swift
//  EmojiDesign
//
//  Created by Gagan Bhirangi on 02/01/23.
//

import SwiftUI

class EmojiDesignDocument: ObservableObject
{
    @Published private(set) var emojiDesign: EmojiDesignModel {
        didSet {
            if emojiDesign.background != oldValue.background {
                fetchbackgroundIfNecessary()
            }
        }
    }
    
    private func save (to url: URL) {
       do{
           let data: Data = try emojiDesign.json()
        try data.write(to: url)
           
       } catch {
           print("EmojiDesignDocument.save(to:) error = \(error)")
       }
    }
    
    init (){
        emojiDesign = EmojiDesignModel()
//        emojiDesign.emojiAdd("😀", at: (-200, 100), size: 70)
//        emojiDesign.emojiAdd("🤦‍♂️", at: (100, 50), size: 30)
    }
    
    var emojis: [EmojiDesignModel.Emoji] {emojiDesign.emojis}
    var background: EmojiDesignModel.Backgoround {emojiDesign.background}
    
    @Published var backgroundImage: UIImage?
    @Published var backgroundImageFetchStatus = BackgroundImageFetchStatus.idle
    
    enum BackgroundImageFetchStatus {
        case idle
        case fetching
    }
    
    private func fetchbackgroundIfNecessary () {
        backgroundImage = nil
        switch emojiDesign.background {
        case .url(let url) :
            // fetch URL
            backgroundImageFetchStatus = .fetching
            DispatchQueue.global(qos: .userInitiated).async {
                let imageData = try? Data(contentsOf: url)
                DispatchQueue.main.async { [weak self] in
                    if self?.emojiDesign.background == EmojiDesignModel.Backgoround.url(url) {
                        self?.backgroundImageFetchStatus = .idle
                        if imageData != nil {
                            self?.backgroundImage = UIImage(data: imageData!)
                        }
                    }
                }
            }
        case .ImageData(let data):
            backgroundImage = UIImage(data: data)
        case .blank:
            break
        }
    }
    
    // MARK:    - Intent(s)
    
    func setBackground (_ background: EmojiDesignModel.Backgoround) {
        emojiDesign.background = background
        print("Background updated  = \(background)")
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

