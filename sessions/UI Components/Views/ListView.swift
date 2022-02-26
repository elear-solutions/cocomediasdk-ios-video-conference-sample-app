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
  @IBOutlet weak var labelWelcome: UILabel!
  @IBOutlet weak var imageUser: UIImageView!
  // Middle View
  @IBOutlet weak var tableListView: UITableView!
  // Bottom View
  @IBOutlet weak var actionButton: UIButton!
  
  @IBAction func buttonTapped(_ sender: Any) {
  }
  
  func fill(username: String, image: URL) {
    self.labelWelcome.text = "Welcome \(username),"
  }
}
