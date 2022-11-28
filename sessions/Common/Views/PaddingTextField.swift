//
//  PaddingTextField.swift
//  sessions
//
//  Created by Vladyslav Danyliak on 25.11.2022.
//

import UIKit

class PaddingTextField: UITextField {
  // MARK: Open

  override open func textRect(forBounds bounds: CGRect) -> CGRect {
    return bounds.inset(by: padding)
  }

  override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
    return bounds.inset(by: padding)
  }

  override open func editingRect(forBounds bounds: CGRect) -> CGRect {
    return bounds.inset(by: padding)
  }

  // MARK: Internal

  let padding = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
}
