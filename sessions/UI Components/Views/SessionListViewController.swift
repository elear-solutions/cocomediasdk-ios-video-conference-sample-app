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
    tableListView.dataSource = self
    tableListView.delegate = self
    tableListView.configureRefreshController(self)
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.isNavigationBarHidden = true
    NetworkService().fetchNetworksApi(
      success: { _networks in
        guard let _networks = _networks else {
          return
        }
        self.networks.removeAll()
        self.networks = self.networks.union(_networks)
        DispatchQueue.main.async {
          self.tableListView.reloadData()
        }
      },
      failure: { _error in
        debugPrint("error:", _error.localizedDescription)
      }
    )
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
    let controller = CreateSessionViewController.initFromNib()
    navigationController?.pushViewController(controller, animated: true)
  }

  func fill(username: String, _ image: URL? = nil) {
    labelWelcome.text = "Welcome \(username)"
  }

  // MARK: Private

  private var networks: Set<CocoMediaSDK.Network> = .init()
}

extension SessionListViewController: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return networks.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(cellType: ListViewItem.self, indexPath: indexPath)

    let items = networks.sorted(by: {
      $0.id > $1.id
    })
    let item = items[indexPath.row]
    cell.tag = indexPath.row
    cell.fill(network: item)
    cell.selectionStyle = .none
    return cell
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if let selectedCell = tableView.cellForRow(at: indexPath) as? ListViewItem {
      let controller = SessionCallViewController.initFromNib()
      controller.selectedNetwork = selectedCell.network
      navigationController?.pushViewController(controller, animated: true)
    }
  }

  func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == .delete {
      if let selectedCell = tableView.cellForRow(at: indexPath) as? ListViewItem {
        guard let networkId = selectedCell.networkId,
              let network = selectedCell.network else
        {
          fatalError("networkId: nil")
        }
        showSpinner(onView: view)
        NetworkService().deleteNetworkApi(networkId: networkId,
                                          success: {
                                            DispatchQueue.main.async {
                                              tableView.beginUpdates()
                                              self.networks.remove(network)
                                              tableView.deleteRows(at: [indexPath], with: .automatic)
                                              tableView.endUpdates()
                                              self.removeSpinner()
                                            }
                                          },
                                          failure: { error in
                                            debugPrint(#function, "error: ", error.localizedDescription)
                                            self.removeSpinner()
                                          })
      }
    }
  }
}

extension SessionListViewController: TableViewReloadDataDelegate {
  func reload() {
    NetworkService().fetchNetworksApi(
      success: { _networks in
        guard let _networks = _networks else {
          return
        }
        self.networks = self.networks.union(_networks)
        DispatchQueue.main.async {
          self.tableListView.reloadData()
          self.tableListView.refreshControl?.endRefreshing()
        }
      },
      failure: { error in
        debugPrint(error.localizedDescription)
        DispatchQueue.main.async {
          self.tableListView.refreshControl?.endRefreshing()
        }
      }
    )
  }
}
