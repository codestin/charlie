//
//  PhotoManager.swift
//  charlie
//
//  Manages Charlie's photo rewards
//

import Foundation
import SwiftUI

struct CharliePhoto {
    let id: Int
    let imageName: String
    
    var image: Image {
        Image(imageName)
    }
}

class PhotoManager {
    static let shared = PhotoManager()
    
    // Photo names - you'll add these images to Assets.xcassets
    // Name them: charlie_1, charlie_2, ... charlie_10
    let photos: [CharliePhoto] = (1...10).map { index in
        CharliePhoto(id: index, imageName: "charlie_\(index)")
    }
    
    private var unlockedPhotoIds: Set<Int> = []
    private var availablePhotoIds: [Int] = []
    
    private init() {
        resetAvailablePhotos()
    }
    
    func getRandomPhoto(excluding: Set<Int> = []) -> CharliePhoto? {
        // If we've shown all photos, reset the pool
        if availablePhotoIds.isEmpty {
            resetAvailablePhotos()
        }
        
        // Filter out excluded photos
        let available = availablePhotoIds.filter { !excluding.contains($0) }
        
        guard !available.isEmpty else { return photos.first }
        
        let randomIndex = Int.random(in: 0..<available.count)
        let photoId = available[randomIndex]
        
        // Remove from available pool
        availablePhotoIds.removeAll { $0 == photoId }
        unlockedPhotoIds.insert(photoId)
        
        return photos.first { $0.id == photoId }
    }
    
    private func resetAvailablePhotos() {
        availablePhotoIds = Array(1...10)
    }
    
}