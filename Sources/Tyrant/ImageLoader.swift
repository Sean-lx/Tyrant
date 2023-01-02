//
//  File.swift
//  
//
//  Created by Sean Li on 2022/12/12.
//

import Foundation
import UIKit

actor ImageLoader: ObservableObject {
  enum DownloadState {
    case inProgress(Task<UIImage, Error>)
    case completed(UIImage)
    case failed
  }
  
  private(set) var cache: [String: DownloadState] = [:]
  @MainActor private(set) var inMemoryAccess: AsyncStream<Int>?
  
  private var inMemoryAccessCounter = 0 {
    didSet { inMemoryAccessContinuation?.yield(inMemoryAccessCounter) }
  }
  private var inMemoryAccessContinuation: AsyncStream<Int>.Continuation?
  
  func setUp() async {
    let accessStream = AsyncStream<Int> { continuation in
      inMemoryAccessContinuation = continuation
    }
    
    await MainActor.run { inMemoryAccess = accessStream }
  }
  
  func add(_ image: UIImage, forKey key: String) {
    cache[key] = .completed(image)
  }
  
  func image(_ serverPath: String, size: CGSize = CGSize.zero)
  async throws -> UIImage {
    if let cached = cache[serverPath] {
      switch cached {
      case .completed(let image):
        inMemoryAccessCounter += 1
        return image
      case .inProgress(let task):
        return try await task.value
      case .failed: throw "Download failed"
      }
    }
    
    let download: Task<UIImage, Error> = Task.detached {
      guard let url = URL(string: serverPath) else {
        throw "Could not create the download URL"
      }
      print("Download: \(url.absoluteString)")
      let data = try await URLSession.shared.data(from: url).0
      guard size != CGSize.zero else {
        if let image = UIImage.init(data: data) {
          return image
        }else {
          throw "UIImage init failed: Invalid image data!"
        }
      }
      return try resize(data, to: size)
    }
    
    cache[serverPath] = .inProgress(download)
    
    do {
      let result = try await download.value
      add(result, forKey: serverPath)
      return result
    } catch {
      cache[serverPath] = .failed
      throw error
    }
  }
  
  func clear() {
    cache.removeAll()
  }
  
  deinit {
    inMemoryAccessContinuation?.finish()
  }
}
