//
//  ViewController.swift
//  sessions
//
//  Created by Rohan S on 12/11/21.
//

import UIKit

class ViewController: UIViewController {
  // MARK: Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    setup()
  }

  override func viewDidDisappear(_ animated: Bool) {
    // Do any additional wrap up before unloading the view.
    super.viewDidDisappear(animated)
  }

  // MARK: Internal

  @IBOutlet var baseUri: UITextField!
  @IBOutlet var username: UITextField!
  @IBOutlet var btnConnect: UIButton!
  @IBOutlet var btnDemo: UIButton!

  // MARK: Private

  private func setup() {
    btnConnect.addTarget(self,
                         action: #selector(didTouchUpInside),
                         for: .touchUpInside)
    btnDemo.addTarget(self,
                      action: #selector(didTouchUpInside),
                      for: .touchUpInside)
  }

  @objc private func didTouchUpInside(sender: UIButton) {
    debugPrint(sender)
    guard isValid(input: baseUri.text) else {
      baseUri.isHighlighted = true
      return
    }
    guard isValid(input: username.text) else {
      username.isHighlighted = true
      return
    }
    switch sender {
    case btnConnect:
      break
    case btnDemo:
      break
    default:
      break
    }
  }
  
  private func isValid(input: String?) -> Bool {
    return (input?.trimWhiteSpaceAndNewLine().isEmpty ?? true) ? false : true
  }
}
