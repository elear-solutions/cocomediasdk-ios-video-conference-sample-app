//
//  NetworkService.swift
//  sessions
//
//  Created by Rohan S on 07/01/22.
//
import CocoMediaSDK
import Foundation

final class NetworkService {
  func fetchNetworksApi(success: (([Network]?) -> Void)?,
                        failure: ((Error) -> Void)?)
  {
    // let request = NetworkManagementRequest<GetNetworksResponse>(commandId: .COCO_MEDIA_NW_CMD_GET_ALL_NETWORKS)
    let request = NetworkManagementRequest(commandId: .COCO_MEDIA_NW_CMD_GET_ALL_NETWORKS)
    do {
      try request.execute { result in
        switch result {
        case let .success(response):
          debugPrint("response:", response)
          guard let success = success else {
            return
          }

          guard let response = response.params else {
            success(nil)
            return
          }

          let networks = GetNetworksResponse(response).networks
          success(networks)
        case let .failure(error):
          debugPrint("error:", error)
          guard let failure = failure else {
            return
          }
          failure(error)
        }
      }
    } catch {
      debugPrint("error:", error.localizedDescription)
    }
  }

  func deleteNetworkApi(network: Network) {
    let params = DeleteNetworkParameters(network: network)
    let request = NetworkManagementRequest(
      commandId: .COCO_MEDIA_NW_CMD_DELETE_NETWORK,
      params
    )
    do {
      try request.execute { result in
        switch result {
        case let .success(response):
          debugPrint("response:", response)
          guard let response = response.params else {
            return
          }
        case let .failure(error):
          debugPrint("error:", error)
        }
      }
    } catch {
      debugPrint("error:", error.localizedDescription)
    }
  }
}
