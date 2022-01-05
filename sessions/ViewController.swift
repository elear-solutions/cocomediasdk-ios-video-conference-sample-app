//
//  ViewController.swift
//  sessions
//
//  Created by Rohan S on 12/11/21.
//

import CocoMediaSDK
import UIKit

class ViewController: UIViewController {
  // MARK: Lifecycle

  override func viewWillAppear(_: Bool) {
    super.viewWillAppear(true)
    if UserDataManager().getUserLoggedIn() == true {
      DispatchQueue.main.async {
        let vc = SessionListViewController.initFromNib()
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        nav.modalTransitionStyle = .coverVertical
        nav.setNavigationBarHidden(true, animated: true)
        self.present(nav, animated: true)
      }
    }
  }

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
                                           // TODO: Set Token and save isUserLoggedIn
                                           UserDataManager().setUserLoggedIn(true)
                                           try! client?.set(token: tokenResponse.rawString!)
                                           DispatchQueue.main.async {
                                             let vc = SessionListViewController.initFromNib()
                                             let nav = UINavigationController(rootViewController: vc)
                                             nav.modalPresentationStyle = .fullScreen
                                             nav.modalTransitionStyle = .coverVertical
                                             nav.setNavigationBarHidden(true, animated: true)
                                             present(nav, animated: true)
                                           }
                                         case let .failure(error):
                                           debugPrint(error.localizedDescription)
                                         }
                                       })

    default:
      break
    }
  }

  private func isValid(input: String?) -> Bool {
    return (input?.trimWhiteSpaceAndNewLine().isEmpty ?? true) ? false : true
  }
}
