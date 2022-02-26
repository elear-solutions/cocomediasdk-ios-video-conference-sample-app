//
//  ListViewItem.swift
//  sessions
//
//  Created by Rohan S on 13/12/21.
//

import CocoMediaSDK
import Foundation
import UIKit

class ListViewItem: UITableViewCell {
  static let identifier = String(describing: ListViewItem.self)

  @IBOutlet var itemLabel: UILabel!
  @IBOutlet var itemButton: UIButton!

  var network: Network?

  var networkId: String? {
    network?.id
  }

  func fill(network: Network) {
    self.network = network
    itemLabel.text = network.name
  }
}
