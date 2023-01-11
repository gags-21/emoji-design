//
//  ContentView.swift
//  EmojiDesign
//
//  Created by Gagan Bhirangi on 02/01/23.
//

import SwiftUI

struct EmojiDesignDocumentView: View {
    
    @ObservedObject var document: EmojiDesignDocument
    
    let defaultEmojiSize: CGFloat = 40
    
    var body: some View {
        
        VStack {
            documentBody
            pallete
        }
    }
    
    var documentBody: some View {
        GeometryReader {gProxy in
            ZStack {
                Color.white.overlay(
                    OptionalImage(uiImage: document.backgroundImage)
                        .position(convertFromEmojiCoordinates((0,0), in: gProxy))
                )
                ForEach (document.emojis) { emoji in
                    Text(emoji.text)
                        .font(.system(size: fontSize(for: emoji)))
                        .position(position(for: emoji, in: gProxy))
                }
            }
            .onDrop(of: [.plainText, .url, .image], isTargeted: nil) { providers, location in
                return drop(providers: providers, at: location, in: gProxy)
            }
        }
        
    }
    
    private func drop(providers: [NSItemProvider], at location: CGPoint, in geometry: GeometryProxy ) -> Bool {
        
        var found = providers.loadObjects(ofType: URL.self) { url in
            document.setBackground(.url(url.imageURL))
        }
         
        if !found {
            found = providers.loadObjects(ofType: UIImage.self) { image in
                if let data = image.jpegData(compressionQuality: 1) {
                    document.setBackground(.ImageData(data))
                }
            }
        }
        
        if !found {
            found = providers.loadObjects(ofType: String.self) { string in
                if let emoji = string.first, emoji.isEmoji {
                    document.addEmoji(
                        String(emoji),
                        at: convertToEmojiCoordinates(location, in: geometry), size: defaultEmojiSize)
                }
            }
        }
        
        return found
    }
    
    private func position (for emoji: EmojiDesignModel.Emoji, in geometry: GeometryProxy) -> CGPoint {
        //        CGPoint(x: emoji.x, y: emoji.y)
        convertFromEmojiCoordinates((emoji.x, emoji.y), in: geometry)
    }
    
    private func convertToEmojiCoordinates (_ location: CGPoint, in geometry: GeometryProxy ) -> (x: Int, y: Int) {
        let center = geometry.frame(in: .local).center
        let location = CGPoint (
            x: location.x - center.x,
            y: location.y - center.y
        )
        return ( Int(location.x), Int(location.y))
    }
    
    private func convertFromEmojiCoordinates (_ location: (x: Int, y: Int), in geometry: GeometryProxy) -> CGPoint {
        
        let center = geometry.frame(in: .local).center
        
        return CGPoint (
            x: center.x + CGFloat(location.x),
            y: center.y + CGFloat(location.y)
        )
    }
    
    private func fontSize (for emoji: EmojiDesignModel.Emoji) -> CGFloat {
        CGFloat(emoji.size)
    }
    
    var pallete: some View {
        ScrollingEmojisView(emojis: testEmojis)
            .font(.system(size: defaultEmojiSize))
    }
    
    let testEmojis =  "🤦‍♂️😅😀😶‍🌫️🚃🚀🎡🏦📻💻⌨️🚝🖥️🖨️🖲️🗜️🔨"
}

struct ScrollingEmojisView: View {
    let emojis: String
    
    var body: some View {
        ScrollView(.horizontal){
            HStack {
                ForEach (emojis.map { String ($0) },id: \.self ) { emoji in
                    Text(emoji)
                        .onDrag {NSItemProvider(object: emoji  as NSString) }
                }
            }
        }
        
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        EmojiDesignDocumentView(document: EmojiDesignDocument())
    }
}
