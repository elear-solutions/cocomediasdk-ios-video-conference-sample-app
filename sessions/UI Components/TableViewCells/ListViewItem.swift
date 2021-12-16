//
//  ListViewItem.swift
//  sessions
//
//  Created by Rohan S on 13/12/21.
//

import Foundation
import UIKit

class ListViewItem: UITableViewCell {
  @IBOutlet var itemLabel: UILabel!
  @IBOutlet var itemButton: UIButton!

  @IBAction func itemButtonTapped(_: Any) {}

  func fill(label: String) {
    itemLabel.text = label
  }
}
