//
//  File.swift
//  
//
//  Created by Sean Li on 2022/12/12.
//

import Foundation

@ImageCache class DiskStorage {
  private var folder: URL
  
  init() {
    guard let supportFolderURL = FileManager.default
      .urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
      fatalError("Couldn't open the application support folder")
    }
    let imageCacheFolderURL = supportFolderURL.appendingPathComponent("imagecache")
    
    do {
      try FileManager.default.createDirectory(at: imageCacheFolderURL, withIntermediateDirectories: true, attributes: nil)
    } catch {
      fatalError("Couldn't create the application support folder")
    }
    
    folder = imageCacheFolderURL
  }
  
  nonisolated static func fileName(for path: String) -> String {
    guard let url = URL(string: path) else {
      return path
    }
    let name = url.lastPathComponent
    return name
      .components(separatedBy: .punctuationCharacters)
      .joined(separator: "_")
  }
  
  func write(_ data: Data, name: String) throws {
    try data.write(to: folder.appendingPathComponent(name), options: .atomic)
  }
  
  func read(name: String) throws -> Data {
    return try Data(contentsOf: folder.appendingPathComponent(name))
  }
  
  func remove(name: String) throws {
    try FileManager.default.removeItem(at: folder.appendingPathComponent(name))
  }
  
  func persistedFiles() throws -> [URL] {
    var result: [URL] = []
    guard let directoryEnumerator = FileManager.default
      .enumerator(at: folder, includingPropertiesForKeys: []) else {
      throw "Could not open the application support folder"
    }
    for case let fileURL as URL in directoryEnumerator {
      result.append(fileURL)
    }
    return result
  }
}
