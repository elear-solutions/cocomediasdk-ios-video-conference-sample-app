//
//  CreateSessionViewController.swift
//  sessions
//
//  Created by Rohan S on 09/01/22.
//

import CocoMediaSDK
import UIKit

class CreateSessionViewController: UIViewController {
  // MARK: Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()

    // Do any additional setup after loading the view.
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
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
    try? NetworkService().createNetworkApi(name: networkName,
                                           success: { [weak self] network in
                                             self?.fetchNetworks(id: network.id)
                                           },
                                           failure: { [weak self] error in
                                             self?.removeSpinner()
                                             let alert = UIAlertController(title: "Error Encountered",
                                                                           message: error.localizedDescription,
                                                                           preferredStyle: .alert)
                                             alert.addAction(UIAlertAction(title: "Dismiss",
                                                                           style: .default,
                                                                           handler: nil))
                                             DispatchQueue.main.async {
                                               self?.present(alert, animated: true, completion: nil)
                                             }
                                           })
  }

  // MARK: Private

  private func fetchNetworks(id: String) {
    NetworkService().fetchNetworksApi(
      success: { [weak self] networks in
        guard let network = networks?.first(where: { $0.id == id }) else {
          return
        }

        self?.connect(network: network)
      }, failure: { [weak self] error in
        self?.removeSpinner()
        debugPrint("error:", error.localizedDescription)
      }
    )
  }

  private func connect(network: Network) {
    network.delegate = self
    do {
      debugPrint("[DBG] \(#file) -> \(#function) connecting: \(network)")
      try network.connect()
    } catch {
      debugPrint("[DBG] \(#file) -> \(#function)  error: \(error.localizedDescription)")
    }
  }

  private func openSession(network: Network) {
    let controller = SessionCallViewController.initFromNib()
    controller.selectedNetwork = network
    navigationController?.pushViewController(controller, animated: true)
  }
}

// MARK: - Network

extension CreateSessionViewController: NetworkDelegate {
  func didReceiveData(_ network: Network, from node: Node, data: String?) {}

  func didReceiveContentInfo(_ network: Network, from node: Node, metadata: String?, time stamp: TimeInterval) {}

  func didChangeStatus(_ network: Network, status from: Network.State, to: Network.State) {
    debugPrint("[DBG] \(#file) -> \(#function) coco_media_client_connect_status_cb_t: ", from, to)
    switch to {
    case .COCO_CLIENT_REMOTE_CONNECTED:
      try? network.createChannel(name: "call channel", metadata: "-") { [weak self] _ in
        DispatchQueue.main.async {
          self?.openSession(network: network)
          self?.removeSpinner()
        }
      }
    case .COCO_CLIENT_COCONET_BLOCKED,
         .COCO_CLIENT_COCONET_RESET,
         .COCO_CLIENT_CONNECT_ERROR,
         .COCO_CLIENT_DISCONNECTED:
      removeSpinner()
      DispatchQueue.main.async {
        self.navigationController?.popViewController(animated: true)
      }
    default:
      break
    }
  }
}
