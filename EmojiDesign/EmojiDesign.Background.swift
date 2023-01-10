//
//  EmojiDesign.Background.swift
//  EmojiDesign
//
//  Created by Gagan Bhirangi on 02/01/23.
//

import Foundation

extension EmojiDesignModel {
        enum Backgoround {
            case blank
            case url(URL)
            case ImageData(Data)
            
            var url: URL? {
                switch self {
                case .url(let url): return url
                default: return nil
                }
            }
            
            var imageData: Data? {
                switch self {
                case .ImageData(let data): return data
                default: return nil
                }
            }
            
        }
}
