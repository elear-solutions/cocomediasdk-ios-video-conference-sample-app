//
//  String+Extension.swift
//  sessions
//
//  Created by Rohan S on 19/12/21.
//

import Foundation

extension String {
  func trimWhiteSpace() -> String {
    return trimmingCharacters(in: .whitespaces)
  }

  func trimRemoveNewLine() -> String {
    return trimmingCharacters(in: .newlines)
  }

  func trimWhiteSpaceAndNewLine() -> String {
    return trimmingCharacters(in: .whitespacesAndNewlines)
  }
}
