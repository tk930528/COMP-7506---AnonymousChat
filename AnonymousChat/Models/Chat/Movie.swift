//
//  Movie.swift
//  AnonymousChat
//
//  Created by Chuen on 15/4/2024.
//

import AVKit
import SwiftUI
import CoreTransferable
import SwiftyChat

struct Movie: Codable {
    var imageData: Data
    var pictureInPicturePlayingMessage: String
    let url: URL

    init(url: URL, message: String, imageData: Data) {
        self.url = url
        self.pictureInPicturePlayingMessage = message
        self.imageData = imageData
    }
    
    func getVideoItem() -> PCVideoItem {
        PCVideoItem(
            url: url,
            placeholderImage: .local(UIImage(data: imageData) ?? UIImage()),
            pictureInPicturePlayingMessage: pictureInPicturePlayingMessage
        )
    }
}


extension Movie: Transferable {
//    static var transferRepresentation: some TransferRepresentation {
//        CodableRepresentation(contentType: .movie)
//        FileRepresentation(contentType: .movie) { movie in
//            SentTransferredFile(movie.url)
//        } importing: { received in
//            let copy = URL.documentsDirectory.appending(path: "movie.mp4")
//            
//            if FileManager.default.fileExists(atPath: copy.path()) {
//                try FileManager.default.removeItem(at: copy)
//            }
//            
//            try FileManager.default.copyItem(at: received.file, to: copy)
//            
//            // Prepare placeholder image for video message
//            let placeHolderImage = copy.videoPreviewUIimage ?? UIImage(systemName: "video.fill") ?? UIImage()
//            let placeHolderImageData = placeHolderImage.jpeg(.low) ?? Data()
//            
//            return Self.init(url: copy, message: "", imageData: placeHolderImageData)
//        }
//    }
    
    static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(contentType: .movie) { movie in
            SentTransferredFile(movie.url)
        } importing: { received in
            let copy = URL.documentsDirectory.appending(path: "movie.mp4")
            
            if FileManager.default.fileExists(atPath: copy.path()) {
                try FileManager.default.removeItem(at: copy)
            }
            
            try FileManager.default.copyItem(at: received.file, to: copy)
            
            // Prepare placeholder image for video message
            let placeHolderImage = copy.videoPreviewUIimage ?? UIImage(systemName: "video.fill") ?? UIImage()
            let placeHolderImageData = placeHolderImage.jpeg(.low) ?? Data()
            
            return Self.init(url: copy, message: "", imageData: placeHolderImageData)
        }
    }
}

//extension UTType {
//    static var movie = UTType(exportedAs: "com.example.note")
//}

struct PCVideoItem: VideoItem {
    var url: URL
    var placeholderImage: SwiftyChat.ImageLoadingKind
    var pictureInPicturePlayingMessage: String
}

//
//struct Movie: Transferable, VideoItem {
//    var placeholderImage: SwiftyChat.ImageLoadingKind
//    var pictureInPicturePlayingMessage: String
//    let url: URL
//    let data: Data?
//
//    static var transferRepresentation: some TransferRepresentation {
//        FileRepresentation(contentType: .movie) { movie in
//            SentTransferredFile(movie.url)
//        } importing: { received in
//            let copy = URL.documentsDirectory.appending(path: "movie.mp4")
//
//            if FileManager.default.fileExists(atPath: copy.path()) {
//                try FileManager.default.removeItem(at: copy)
//            }
//
//            try FileManager.default.copyItem(at: received.file, to: copy)
//            
//            // Prepare video data & placeholder image for video message
//            let movieData = try? Data(contentsOf: copy)
//            let placeHolderImage = copy.videoPreviewUIimage ?? UIImage(systemName: "video.fill") ?? UIImage()
//            
//            return Self.init(placeholderImage: .local(placeHolderImage), pictureInPicturePlayingMessage: "", url: copy, data: movieData)
//        }
//    }
//}
