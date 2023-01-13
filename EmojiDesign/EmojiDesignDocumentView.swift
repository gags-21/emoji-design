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
                        .scaleEffect(zoomScale)
                        .position(convertFromEmojiCoordinates((0,0), in: gProxy))
                )
                .gesture(doubleTapToZoom(in: gProxy.size))
                if document.backgroundImageFetchStatus == .fetching {
                    ProgressView().scaleEffect(2)
                } else {
                    ForEach (document.emojis) { emoji in
                        Text(emoji.text)
                            .font(.system(size: fontSize(for: emoji)))
                            .scaleEffect(zoomScale)
                            .position(position(for: emoji, in: gProxy))
                    }
                }
            }
            .clipped()
            .onDrop(of: [.plainText, .url, .image], isTargeted: nil) { providers, location in
                return drop(providers: providers, at: location, in: gProxy)
            }
            .gesture(zoomGesture())
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
                    document.addEmoji (
                        String(emoji),
                        at: convertToEmojiCoordinates(location, in: geometry),
                        size: defaultEmojiSize / zoomScale
                    )
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
            x: (location.x - center.x) / zoomScale,
            y: (location.y - center.y) / zoomScale
        )
        return ( Int(location.x), Int(location.y))
    }
    
    private func convertFromEmojiCoordinates (_ location: (x: Int, y: Int), in geometry: GeometryProxy) -> CGPoint {
        
        let center = geometry.frame(in: .local).center
        
        return CGPoint (
            x: center.x + CGFloat(location.x) * zoomScale,
            y: center.y + CGFloat(location.y) * zoomScale
        )
    }
    
    private func fontSize (for emoji: EmojiDesignModel.Emoji) -> CGFloat {
        CGFloat(emoji.size)
    }
    
    @State private var steadyStateZoomScale: CGFloat = 1
    @GestureState private var gestureZoomScale: CGFloat = 1

    private var zoomScale: CGFloat {
        steadyStateZoomScale * gestureZoomScale
    }
    
    
    private func zoomGesture() -> some Gesture {
        MagnificationGesture()
            .updating($gestureZoomScale) { latestGestureScale, gestureZoomScale, transaction in
                gestureZoomScale = latestGestureScale
            }
            .onEnded { gestureScale in
                steadyStateZoomScale *= gestureScale
            }
    }
    
    private func doubleTapToZoom (in size: CGSize) -> some Gesture {
        TapGesture(count: 2)
            .onEnded {
                withAnimation {
                    zoomFit(document.backgroundImage, in: size)
                }
            }
    }
    
    private func zoomFit (_ image: UIImage?, in size: CGSize) {
        if let image = image , image.size.width > 0, image.size.height > 0, size.width > 0, size.height > 0{
            let hZoom = size.width / image.size.width
            let vZoom = size.height / image.size.height
            steadyStateZoomScale = min(hZoom, vZoom)
        }
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
