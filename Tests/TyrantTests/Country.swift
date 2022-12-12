//
//  File.swift
//  
//
//  Created by Sean Li on 2022/12/12.
//

import Foundation

struct Country: Codable {
  let name: String
  let flagUrl: String
  let alpha3: String
  
  enum CodingKeys: String, CodingKey {
    case name, alpha3
    case flagUrl = "file_url"
  }
}
