//
//  UITableView+Extension.swift
//  sessions
//
//  Created by Rohan S on 05/01/22.
//

import UIKit

extension UITableView {
  func registerNib(_ cellType: UITableViewCell.Type) {
    let cellName = String(describing: cellType.self)
    let nib = UINib(nibName: cellName, bundle: nil)
    register(nib, forCellReuseIdentifier: cellName)
  }

  func dequeueReusableCell<T: UITableViewCell>(cellType: T.Type, indexPath: IndexPath) -> T {
    let cellName = String(describing: cellType.self)
    let cell = dequeueReusableCell(withIdentifier: cellName, for: indexPath) as! T
    return cell
  }
}
