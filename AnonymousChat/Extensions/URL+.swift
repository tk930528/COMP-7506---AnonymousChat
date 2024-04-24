//
//  URL+.swift
//  AnonymousChat
//
//  Created by Chuen on 16/4/2024.
//

import UIKit
import AVKit

extension URL {
    var videoPreviewUIimage: UIImage? {
        let asset = AVURLAsset(url: self)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        
        let timestamp = CMTime(seconds: 2, preferredTimescale: 60)
        
        guard let imageRef = try? generator.copyCGImage(at: timestamp, actualTime: nil) else { return nil }
        return UIImage(cgImage: imageRef)
    }
}
