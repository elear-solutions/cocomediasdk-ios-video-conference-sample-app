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
    navigationController?.isNavigationBarHidden = false

    // Do any additional setup after loading the view.
  }

  // MARK: Internal

  @IBOutlet var txtSessionName: UITextField!
  @IBOutlet var btnCreateSession: UIButton!

  @IBAction func didTapButton(_ sender: Any) {
    debugPrint(sender)
    guard let networkName = txtSessionName.text else {
      let alert = UIAlertController(title: "Error Encountered",
                                    message: "Please enter a name",
                                    preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "Dismiss",
                                    style: .default,
                                    handler: nil))
      present(alert, animated: true, completion: nil)
      return
    }
    showSpinner(onView: view)
//    NetworkService().createNetworkApi(
//      networkName: networkName,
//      success: { _ in
//        self.removeSpinner()
//        DispatchQueue.main.async {
//          self.navigationController?.popViewController(animated: true)
//        }
//      },
//      failure: { error in
//        self.removeSpinner()
//        let alert = UIAlertController(title: "Error Encountered",
//                                      message: error.localizedDescription,
//                                      preferredStyle: .alert)
//        alert.addAction(UIAlertAction(title: "Dismiss",
//                                      style: .default,
//                                      handler: nil))
//        self.present(alert, animated: true, completion: nil)
//      }
//    )
    try? NetworkService().createNetworkApi(name: networkName,
                                           success: { _ in
                                             self.removeSpinner()
                                             DispatchQueue.main.async {
                                               self.navigationController?.popViewController(animated: true)
                                             }
                                           },
                                           failure: { error in
                                             self.removeSpinner()
                                             let alert = UIAlertController(title: "Error Encountered",
                                                                           message: error.localizedDescription,
                                                                           preferredStyle: .alert)
                                             alert.addAction(UIAlertAction(title: "Dismiss",
                                                                           style: .default,
                                                                           handler: nil))
                                             self.present(alert, animated: true, completion: nil)
                                           })
  }
}
