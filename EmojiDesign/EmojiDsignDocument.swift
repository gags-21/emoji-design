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
            scheduleAutosave()
            if emojiDesign.background != oldValue.background {
                fetchbackgroundIfNecessary()
            }
        }
    }
    
    private var autoSaverTimer: Timer?
    
    private func scheduleAutosave() {
        autoSaverTimer?.invalidate()
        autoSaverTimer = Timer.scheduledTimer(withTimeInterval: AutoSave.coalescingInterval, repeats: false) {_ in
            self.autosave()
        }
    }
    
    private struct AutoSave {
        static let filename = "AutoSaved.emojidesign"
        static var url: URL? {
            let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
            return documentDirectory?.appendingPathComponent(filename)
        }
        static let coalescingInterval = 5.0
    }
    
    private func autosave() {
        if let url  = AutoSave.url {
            save(to: url)
        }
    }
    
    private func save (to url: URL) {
        let thisfunction = "\(String(describing: self)).\(#function)"
       do{
           let data: Data = try emojiDesign.json()
           print("\(thisfunction) json = \(String(data: data, encoding: .utf8) ?? "nil")")
           try data.write(to: url)
           print("\(thisfunction) success!")
       } catch let encodingError where encodingError is EncodingError{
           print("\(thisfunction) couldn't encode Emoji Design as JSON because \(encodingError.localizedDescription)")
       } catch {
           print("\(thisfunction) error = \(error)")
       }
    }
    
    init (){
        if let url = AutoSave.url, let autoSaveEmojiDesign = try? EmojiDesignModel(url: url) {
            emojiDesign = autoSaveEmojiDesign
            fetchbackgroundIfNecessary()
        } else {
        emojiDesign = EmojiDesignModel()
//        emojiDesign.emojiAdd("😀", at: (-200, 100), size: 70)
//        emojiDesign.emojiAdd("🤦‍♂️", at: (100, 50), size: 30)
        }
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
        case .imageData(let data):
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

