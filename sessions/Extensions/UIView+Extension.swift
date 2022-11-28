//
//  UIView+Extension.swift
//  sessions
//
//  Created by Vladyslav Danyliak on 28.11.2022.
//

import UIKit

extension UIView {
  @discardableResult  func addSelfNibUsingConstraints(nibName: String) -> UIView? {
    guard let nibView = loadSelfNib(nibName: nibName) else {
      assert(true, "---- UIView Extension Nib file not found ----")
      return nil
    }
    addSubviewUsingConstraints(view: nibView)
    return nibView
  }

  @discardableResult  func addSelfNibUsingConstraints() -> UIView? {
    guard let nibView = loadSelfNib() else {
      assert(true, "---- UIView Extension Nib file not found ----")
      return nil
    }
    addSubviewUsingConstraints(view: nibView)
    return nibView
  }

  func loadSelfNib() -> UIView? {
    let nibName = String(describing: type(of: self))
    if let nibFiles = Bundle.main.loadNibNamed(nibName, owner: self, options: nil),
       nibFiles.count > 0
    {
      return nibFiles.first as? UIView
    }
    return nil
  }

  func loadSelfNib(nibName: String) -> UIView? {
    if let nibFiles = Bundle.main.loadNibNamed(nibName, owner: self, options: nil), nibFiles.count > 0 {
      return nibFiles.first as? UIView
    }
    return nil
  }

  func addSubviewUsingConstraints(view: UIView, spacing: CGFloat = 0) {
    view.translatesAutoresizingMaskIntoConstraints = false
    addSubview(view)

    let left = NSLayoutConstraint(item: view,
                                  attribute: .left,
                                  relatedBy: .equal,
                                  toItem: self,
                                  attribute: .left,
                                  multiplier: 1,
                                  constant: spacing)
    let top = NSLayoutConstraint(item: view,
                                 attribute: .top,
                                 relatedBy: .equal,
                                 toItem: self,
                                 attribute: .top,
                                 multiplier: 1,
                                 constant: spacing)
    let right = NSLayoutConstraint(item: self,
                                   attribute: .trailing,
                                   relatedBy: .equal,
                                   toItem: view,
                                   attribute: .trailing,
                                   multiplier: 1,
                                   constant: spacing)
    let bottom = NSLayoutConstraint(item: self,
                                    attribute: .bottom,
                                    relatedBy: .equal,
                                    toItem: view,
                                    attribute: .bottom,
                                    multiplier: 1,
                                    constant: spacing)
    addConstraints([left, top, right, bottom])
  }
}
