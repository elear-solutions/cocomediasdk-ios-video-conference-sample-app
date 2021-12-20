//
//  UIViewController+Extension.swift
//  sessions
//
//  Created by Rohan S on 21/12/21.
//

import UIKit

extension UIViewController {
  class func initFromNib() -> Self {
    func instanceFromNib<T: UIViewController>() -> T {
      return T(nibName: String(describing: self), bundle: nil)
    }
    return instanceFromNib()
  }
}
