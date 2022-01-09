//
//  ListViewItem.swift
//  sessions
//
//  Created by Rohan S on 13/12/21.
//

import Foundation
import UIKit

class ListViewItem: UITableViewCell {
  // MARK: Internal

  static let identifier = String(describing: ListViewItem.self)

  @IBOutlet var itemLabel: UILabel!
  @IBOutlet var itemButton: UIButton!

  @IBAction func itemButtonTapped(_: Any) {}
  func fill(label: String, networkId: String) {
    itemLabel.text = label
    self.networkId = networkId
  }

  // MARK: Private

  private var networkId: String?
}
