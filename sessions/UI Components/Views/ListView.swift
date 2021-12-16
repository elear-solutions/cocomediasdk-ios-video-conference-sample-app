//
//  ListView.swift
//  sessions
//
//  Created by Rohan S on 14/12/21.
//

import Foundation
import UIKit

class ListView: UIView {
  // Top View
  @IBOutlet var labelWelcome: UILabel!
  @IBOutlet var imageUser: UIImageView!
  // Middle View
  @IBOutlet var tableListView: UITableView!
  // Bottom View
  @IBOutlet var actionButton: UIButton!

  @IBAction func buttonTapped(_: Any) {}

  func fill(username: String, image: URL) {
    labelWelcome.text = "Welcome \(username),"
  }
}
