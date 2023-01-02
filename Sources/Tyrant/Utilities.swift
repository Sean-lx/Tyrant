//
//  File.swift
//  
//
//  Created by Sean Li on 2022/12/12.
//

import Foundation
import UIKit
import CoreImage

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
  guard let uiImage = UIImage(data: data) else {
    throw ResizeError()
  }
  guard let image = CIImage(data: data) else {
    throw ResizeError()
  }
  
  let scale = size.width / uiImage.size.width
  let aspectRatio = uiImage.size.width / uiImage.size.height
  
  let filter = CIFilter(name: "CILanczosScaleTransform")
  filter?.setValue(image, forKey: kCIInputImageKey)
  filter?.setValue(scale, forKey: kCIInputScaleKey)
  filter?.setValue(aspectRatio, forKey: kCIInputAspectRatioKey)
  
  guard let outputCIImage = filter?.outputImage,
        let outputCGImage = sharedContext.createCGImage(outputCIImage,
                                                        from: outputCIImage.extent)
  else {
    throw ResizeError()
  }
  
  return UIImage(cgImage: outputCGImage)
}
