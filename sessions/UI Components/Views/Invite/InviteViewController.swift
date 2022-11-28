//
//  InviteViewController.swift
//  sessions
//
//  Created by Vladyslav Danyliak on 17.11.2022.
//

import CocoMediaSDK
import UIKit

final class InviteViewController: UIViewController {
  // MARK: Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()
    enableKeyboardDismissal()
    textField.layer.borderColor = UIColor.white.cgColor
    button.layer.cornerRadius = 4
    textField.becomeFirstResponder()
    textField.attributedPlaceholder = NSAttributedString(string: "Username", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white.withAlphaComponent(0.5)])
    title = "Invite User"
  }

  // MARK: Internal

  var network: Network?

  // MARK: Private

  @IBOutlet private var button: UIButton!
  @IBOutlet private var textField: PaddingTextField!

  @IBAction private func invite() {
    guard let network = network, let text = textField.text else {
      return
    }

    try? network.inviteUser(externalUserId: text) { [weak self] result in
      switch result {
      case .success:
        DispatchQueue.main.async {
          self?.view.endEditing(true)
          self?.navigationController?.popViewController(animated: true)
        }
      case let .failure(error):
        debugPrint("User invitation: \(error.localizedDescription)")
      }
    }
  }
}
