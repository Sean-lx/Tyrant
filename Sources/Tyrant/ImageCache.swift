//
//  File.swift
//  
//
//  Created by Sean Li on 2022/12/12.
//

import Foundation
import UIKit

@globalActor public actor ImageCache {
  public static let shared = ImageCache()
  private let imageLoader = ImageLoader()
  
  private var storage: DiskStorage!
  private var storedImagesIndex = Set<String>()
  
  public func image(_ key: String, size: CGSize = CGSize.zero)
  async throws -> UIImage {
    if storage == nil {
      try await setUp()
    }
    
    if let memorizedImage = try await loadFromMemory(key, size: size) {
      return memorizedImage
    }
    
    do {
      let diskImage = try await loadFromDisk(key, size: size)
      return diskImage
    } catch {
      let downloadedImage = try await imageLoader.image(key, size: size)
      try await store(image: downloadedImage, forKey: key)
      return downloadedImage
    }
  }
  
  public func clear() async {
    for name in storedImagesIndex {
      try? await storage.remove(name: name)
    }
    storedImagesIndex.removeAll()
  }
  
  public func clearInMemoryAssets() async {
    await imageLoader.clear()
  }
  
  private func setUp() async throws {
    storage = await DiskStorage()
    for fileURL in try await storage.persistedFiles() {
      storedImagesIndex.insert(fileURL.lastPathComponent)
    }
    await imageLoader.setUp()
  }
  
  private func loadFromMemory(_ key: String, size: CGSize = CGSize.zero)
  async throws -> UIImage? {
    let keys = await imageLoader.cache.keys
    if keys.contains(key) {
      print("Cached in-memory")
      return try await imageLoader.image(key, size: size)
    }
    return nil
  }
  
  private func loadFromDisk(_ key: String, size: CGSize = CGSize.zero)
  async throws -> UIImage {
    var image: UIImage
    let fileName = DiskStorage.fileName(for: key)
    if !storedImagesIndex.contains(fileName) {
      throw "Image not persisted"
    }
    
    let data = try await storage.read(name: fileName)
    
    if size == CGSize.zero {
      guard let loadedImage = UIImage.init(data: data) else {
        throw "Read image data failed: Invalid data!"
      }
      image = loadedImage
    }else {
      guard let resizedImage = try? resize(data, to: size) else {
        throw "Resize image from data failed!"
      }
      image = resizedImage
    }
    
    print("Found cache on disk")
    print("Loading from disk to memory")
    await imageLoader.add(image, forKey: key)
    return image
  }
  
  private func store(image: UIImage, forKey key: String) async throws {
    guard let data = image.pngData() else {
      throw "Could not save image \(key)"
    }
    let fileName = DiskStorage.fileName(for: key)
    try await storage.write(data, name: fileName)
    storedImagesIndex.insert(fileName)
  }
}
