//
//  File.swift
//  
//
//  Created by Sean Li on 2022/12/12.
//

import Foundation
import UIKit
import AVFoundation

/// Easily throw generic errors with a text description.
extension String: LocalizedError {
  public var errorDescription: String? {
    return self
  }
}

extension Task where Success == Never, Failure == Never {
  /// Suspends the current task for at least the given duration in seconds.
  /// - Parameter seconds: The sleep duration in seconds.
  static func sleep(seconds: TimeInterval) async {
    try? await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
  }
}

struct ResizeError: Error { }

let sharedContext = CIContext(options: [.useSoftwareRenderer : false])
func resize(_ data: Data, to size: CGSize) throws -> UIImage {
  guard let image = UIImage(data: data) else {
    throw ResizeError()
  }
  
  let availableRect = AVFoundation.AVMakeRect(aspectRatio: image.size,
                                              insideRect: .init(origin: .zero, size: size))
  let targetSize = availableRect.size
  
  UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
  image.draw(in: CGRect(origin: CGPoint.zero, size: targetSize))
  let resizedImage = UIGraphicsGetImageFromCurrentImageContext()!
  UIGraphicsEndImageContext()
  return resizedImage
}
