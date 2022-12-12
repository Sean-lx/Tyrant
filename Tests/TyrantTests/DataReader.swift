//
//  File.swift
//  
//
//  Created by Sean Li on 2022/12/12.
//

import Foundation

class DataReader {
  func read(_ file: String, type: String) -> [Country]? {
    let bundle = Bundle.module
    if let filepath = bundle.path(forResource: file, ofType: type) {
      do {
        let data = try Data(contentsOf: URL(fileURLWithPath: filepath), options: .mappedIfSafe)
        let countries = try JSONDecoder().decode([Country].self, from: data)
        return countries
      } catch {
        print("Read data from bundle failed: \(error.localizedDescription)")
        return nil
      }
    } else {
      print("Could not load file: \(file)")
      return nil
    }
  }
}

extension Collection {
  func randomChoose(_ n: Int) -> ArraySlice<Element> { shuffled().prefix(n) }
}
