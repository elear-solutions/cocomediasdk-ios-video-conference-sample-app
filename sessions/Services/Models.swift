//
//  Models.swift
//  sessions
//
//  Created by Rohan S on 21/12/21.
//

import SwiftyJSON

protocol ResponseResult {
  init(json: JSON)
}

protocol RequestModel {
  func wrap() -> [String: Any]
}
