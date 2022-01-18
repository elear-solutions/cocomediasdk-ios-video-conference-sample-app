//
//  ListViewItem.swift
//  sessions
//
//  Created by Rohan S on 13/12/21.
//

import Foundation
import UIKit

class ListViewItem: UITableViewCell {
  static let identifier = String(describing: ListViewItem.self)

  @IBOutlet var itemLabel: UILabel!
  @IBOutlet var itemButton: UIButton!

  var networkId: String?

  @IBAction func itemButtonTapped(_: Any) {
    guard let networkId = self.networkId else {
      return
    }
    NetworkService().deleteNetworkApi(
      networkId: networkId,
      success: {
        debugPrint("Deleted Successful ", networkId)
      },
      failure: { error in
        debugPrint(#function, "error: ", error.localizedDescription)
      }
    )
  }

  func fill(label: String, networkId: String) {
    itemLabel.text = label
    self.networkId = networkId
  }
}
