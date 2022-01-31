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
    do {
      if let _savedNetworks = try client?.getSavedNetworks() {
        networks = networks.union(_savedNetworks)
        tableListView.reloadData()
      }
    } catch {
      debugPrint("error:", error.localizedDescription)
    }
    NetworkService().fetchNetworksApi(
      success: { _networks in
        guard let _networks = _networks else {
          return
        }
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

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.isNavigationBarHidden = true
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
    cell.delegate = self
    return cell
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if let selectedCell = tableView.cellForRow(at: indexPath) as? ListViewItem {
      selectedCell.network?.delegate = self
      do {
        showSpinner(onView: view)
        try selectedCell.network?.connect()
      } catch {
        debugPrint(error.localizedDescription)
        removeSpinner()
      }
    }
  }
}

extension SessionListViewController: TableViewReloadDataDelegate {
  func reload() {
    if let savedNetworks = try? client?.getSavedNetworks() {
      networks = networks.intersection(savedNetworks)
    }
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

extension SessionListViewController: NetworkDelegate {
  func didChangeStatus(status from: Network.State, to: Network.State) {
    debugPrint("[DBG] coco_media_client_connect_status_cb_t: ", from, to)
    switch to {
    case .COCO_CLIENT_REMOTE_CONNECTED:
      removeSpinner()
      DispatchQueue.main.async {
        let controller = SessionCallViewController.initFromNib()
        self.navigationController?.pushViewController(controller, animated: true)
      }
    case .COCO_CLIENT_COCONET_BLOCKED,
         .COCO_CLIENT_COCONET_RESET,
         .COCO_CLIENT_CONNECT_ERROR,
         .COCO_CLIENT_DISCONNECTED:
      removeSpinner()
    default:
      break
    }
  }
}

extension SessionListViewController: ListViewItemDelegate {
  func didDeleteItem(_ item: Any?) {
    guard let network = item as? Network else {
      return
    }
    self.networks.remove(network)
    DispatchQueue.main.async {
      self.tableListView.reloadData()
      self.tableListView.refreshControl?.endRefreshing()
    }
  }
}
