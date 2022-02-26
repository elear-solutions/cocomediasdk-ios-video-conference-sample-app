//
//  UITableView+Extension.swift
//  sessions
//
//  Created by Rohan S on 05/01/22.
//

import UIKit

var reloadSource: TableViewReloadDataDelegate?

public protocol TableViewReloadDataDelegate {
  func reload()
}

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

  func configureRefreshController(_ delegate: TableViewReloadDataDelegate? = nil) {
    reloadSource = delegate
    let refreshControl = UIRefreshControl()
    refreshControl.addTarget(self, action: #selector(reload(_:)), for: .valueChanged)
    refreshControl.attributedTitle = NSAttributedString(string: "Fetching data...")
    if #available(iOS 10.0, *) {
      self.refreshControl = refreshControl
    } else {
      addSubview(refreshControl)
    }
  }

  @objc private func reload(_: Any) {
    DispatchQueue.main.async {
      reloadSource?.reload()
    }
  }
}
