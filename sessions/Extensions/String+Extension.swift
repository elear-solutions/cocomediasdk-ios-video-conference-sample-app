//
//  String+Extension.swift
//  sessions
//
//  Created by Rohan S on 19/12/21.
//

import UIKit

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

  func height(withConstrainedWidth width: CGFloat, font: UIFont, with maxHeight: CGFloat = .greatestFiniteMagnitude) -> CGFloat {
    let constraintRect = CGSize(width: width, height: maxHeight)
    let boundingBox = (self as NSString).boundingRect(with: constraintRect, options: .usesLineFragmentOrigin,
                                                      attributes: [.font: font], context: nil)

    return ceil(boundingBox.height)
  }

  func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
    let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
    let boundingBox = (self as NSString).boundingRect(with: constraintRect, options: .usesLineFragmentOrigin,
                                                      attributes: [.font: font], context: nil)

    return ceil(boundingBox.width)
  }
}
