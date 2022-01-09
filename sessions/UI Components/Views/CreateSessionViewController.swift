//
//  CreateSessionViewController.swift
//  sessions
//
//  Created by Rohan S on 09/01/22.
//

import UIKit

class CreateSessionViewController: UIViewController {
  // MARK: Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()

    // Do any additional setup after loading the view.
  }

  // MARK: Internal

  @IBOutlet var txtSessionName: UITextField!
  @IBOutlet var btnCreateSession: UIButton!

  @IBAction func didTapButton(_ sender: Any) {
    debugPrint(sender)
  }
}
