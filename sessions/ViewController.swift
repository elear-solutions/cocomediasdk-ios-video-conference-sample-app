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
    // Demo URL for Development Environment
    baseUri.text = UserDataManager().getURL()
  }

  @objc private func didTouchUpInside(sender: UIButton) {
    debugPrint(sender)
    guard let baseUri = baseUri.text, isValid(input: baseUri) else {
      baseUri.isHighlighted = true
      debugPrint("Base URI is empty")
      return
    }
    UserDataManager().setURL(baseUri)
    guard let username = username.text, isValid(input: username) else {
      username.isHighlighted = true
      debugPrint("Username is empty")
      return
    }
    UserDataManager().setUsername(username)
    switch sender {
    case btnConnect:
      let fetchTokenRequest = FetchTokenParameter(username: username)
      AuthenticationManager.fetchToken(params: fetchTokenRequest,
                                       handler: { [self] result in
                                         guard self != nil else { return }
                                         switch result {
                                         case let .success(tokenResponse):
                                           debugPrint(tokenResponse.accessToken)
                                           // TODO: Set Token and save isUserLoggedIn
                                           UserDataManager().setUserLoggedIn(true)
                                         case let .failure(error):
                                           debugPrint(error.localizedDescription)
                                         }
                                       })

    default:
      break
    }
    let vc = SessionListViewController.initFromNib()
    let nav = UINavigationController(rootViewController: vc)
    nav.modalPresentationStyle = .fullScreen
    nav.modalTransitionStyle = .coverVertical
    nav.setNavigationBarHidden(true, animated: true)
    present(nav, animated: true)
  }

  private func isValid(input: String?) -> Bool {
    return (input?.trimWhiteSpaceAndNewLine().isEmpty ?? true) ? false : true
  }
}
