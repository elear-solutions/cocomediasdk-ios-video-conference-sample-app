//
//  LaunchScreenController.swift
//  sessions
//
//  Created by Rohan S on 18/01/22.
//

import CocoMediaSDK
import OSLog
import UIKit

class LaunchScreenController: UIViewController {
  // MARK: Lifecycle

  override func viewWillAppear(_ animated: Bool) {
    os_log("%s started", log: logger, type: .debug, #function)
    super.viewWillAppear(animated)
    let request = NetworkManagementRequest(commandId: .COCO_MEDIA_NW_CMD_GET_ALL_NETWORKS)
    do {
      try request.execute { result in
        switch result {
        case let .success(response):
          debugPrint(String(describing: self), #function, String(describing: response))
          self.launchSessionsScreen()
        case let .failure(error):
          debugPrint(String(describing: self), #function, String(describing: error))
          AppDelegate().authCallback(authorizationEndpoint: "localhost",
                                     tokenEndpoint: "localhost")
        }
      }
    } catch {
      debugPrint(String(describing: self), #function, String(describing: error))
    }
    os_log("%s completed", log: logger, type: .debug, #function)
  }

  override func viewDidLoad() {
    os_log("%s started", log: logger, type: .debug, #function)
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    os_log("%s completed", log: logger, type: .debug, #function)
  }

  override func viewDidDisappear(_ animated: Bool) {
    // Do any additional wrap up before unloading the view.
    super.viewDidDisappear(animated)
  }

  // MARK: Private

  private let logger = OSLog(LaunchScreenController.self)

  private func launchSessionsScreen() {
    os_log("%s started", log: logger, type: .debug, #function)
    DispatchQueue.main.async {
      let vc = SessionListViewController.initFromNib()
      let nav = UINavigationController(rootViewController: vc)
      nav.modalPresentationStyle = .fullScreen
      nav.modalTransitionStyle = .coverVertical
      nav.setNavigationBarHidden(true, animated: true)
      self.present(nav, animated: true)
    }
    os_log("%s completed", log: logger, type: .debug, #function)
  }
}
