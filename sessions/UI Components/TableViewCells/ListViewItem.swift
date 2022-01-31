//
//  ListViewItem.swift
//  sessions
//
//  Created by Rohan S on 13/12/21.
//

import CocoMediaSDK
import Foundation
import UIKit

protocol ListViewItemDelegate: AnyObject {
  func didDeleteItem(_ item: Any?)
}

class ListViewItem: UITableViewCell {
  // MARK: Public

  public weak var delegate: ListViewItemDelegate?

  // MARK: Internal

  static let identifier = String(describing: ListViewItem.self)

  @IBOutlet var itemLabel: UILabel!
  @IBOutlet var itemButton: UIButton!

  var network: Network?

  var networkId: String? {
    network?.id
  }

  @IBAction func itemButtonTapped(_ sender: Any) {
    debugPrint("sender: ", sender)
    guard let networkId = self.networkId else {
      return
    }
    NetworkService().deleteNetworkApi(
      networkId: networkId,
      success: {
        debugPrint("Deleted Successful: ", networkId)
        self.delegate?.didDeleteItem(self.network)
      },
      failure: { error in
        debugPrint(#function, "error: ", error.localizedDescription)
      }
    )
  }

  func fill(network: Network) {
    self.network = network
    itemLabel.text = network.name
  }
}
