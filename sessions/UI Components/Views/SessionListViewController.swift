//
//  SessionListViewController.swift
//  sessions
//
//  Created by Rohan S on 20/12/21.
//

import UIKit

class SessionListViewController: UIViewController {
  // MARK: Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()

    // Do any additional setup after loading the view.
    fill(username: UserDataManager().getUsername())
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
}
