//
//  SessionListViewController.swift
//  sessions
//
//  Created by Rohan S on 20/12/21.
//

import CocoMediaSDK
import UIKit

class SessionListViewController: UIViewController {
  // MARK: Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()

    // Do any additional setup after loading the view.
    fill(username: UserDataManager().getUsername())
    // Register nib
    tableListView.registerNib(ListViewItem.self)
    do {
      if let _savedNetworks = try client?.getSavedNetworks() {
        networks = networks.union(_savedNetworks)
      }
    } catch {
      debugPrint("error:", error.localizedDescription)
    }
    let request = NetworkManagementRequest(commandId: .COCO_MEDIA_NW_CMD_GET_ALL_NETWORKS)
    do {
      try request.execute { result in
        switch result {
        case let .success(response):
          debugPrint("response:", response)
        case let .failure(error):
          debugPrint("error:", error.localizedDescription)
        }
      }
    } catch {
      debugPrint("error:", error.localizedDescription)
    }
  }

  /*
   // MARK: - Navigation

   // In a storyboard-based application, you will often want to do a little preparation before navigation
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
       // Get the new view controller using segue.destination.
       // Pass the selected object to the new view controller.
   }
   */

  // MARK: Internal

  static let identifier = String(describing: SessionListViewController.self)

  // Top View
  @IBOutlet var labelWelcome: UILabel!
  @IBOutlet var imageUser: UIImageView!
  // Middle View
  @IBOutlet var tableListView: UITableView!

  // Bottom View
  @IBOutlet var actionButton: UIButton!

  @IBAction func buttonTapped(_ sender: Any) {
    debugPrint("\(#function): \(String(describing: sender))")
  }

  func fill(username: String, _ image: URL? = nil) {
    labelWelcome.text = "Welcome \(username)"
  }

  // MARK: Private

  private var networks: Set<CocoMediaSDK.Network> = .init()
}
