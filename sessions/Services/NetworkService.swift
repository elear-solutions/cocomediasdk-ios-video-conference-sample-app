//
//  NetworkService.swift
//  sessions
//
//  Created by Rohan S on 07/01/22.
//
import CocoMediaSDK
import Foundation

final class NetworkService {
  func createNetworkApi(networkName: String,
                        success: ((String) -> Void)?,
                        failure: ((Error) -> Void)?)
  {
    let params = CreateNetworkParameters(name: networkName,
                                         metadata: "sample metadata",
                                         type: .COCO_CLIENT_COCONET_TYPE_CALL_NET)
    let request = NetworkManagementRequest(commandId: .COCO_MEDIA_NW_CMD_CREATE_NETWORK,
                                           params)
    do {
      try request.execute { result in
        switch result {
        case let .success(response):
          debugPrint("response: ", response)
          guard let params = response.params else {
            return
          }
          guard let success = success else {
            return
          }
          let networkId = CreateNetworkResponse(params).networkId
          success(networkId)
        case let .failure(error):
          debugPrint("error: ", error)
          guard let failure = failure else {
            return
          }
          failure(error)
        }
      }
    } catch {
      debugPrint("error: ", error)
      guard let failure = failure else {
        return
      }
      failure(error)
    }
  }

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
      guard let failure = failure else {
        return
      }
      failure(error)
    }
  }

  func deleteNetworkApi(networkId: String,
                        success: @escaping(() -> Void),
                        failure: @escaping(Error) -> Void)
  {
    let params = DeleteNetworkParameters(id: networkId)
    let request = NetworkManagementRequest(
      commandId: .COCO_MEDIA_NW_CMD_DELETE_NETWORK,
      params
    )
    do {
      try request.execute { result in
        switch result {
        case let .success(response):
          debugPrint("response:", response)
          success()
        case let .failure(error):
          debugPrint("error:", error)
          failure(error)
        }
      }
    } catch {
      debugPrint("error:", error.localizedDescription)
      failure(error)
    }
  }

  func createNetworkApi(name: String,
                        success: @escaping ((Network) -> Void),
                        failure: @escaping ((Error) -> Void)) throws
  {
    try Network.create(name: name,
                       metadata: "metadata",
                       type: .COCO_CLIENT_COCONET_TYPE_CALL_NET,
                       completionHandler: { result in
                         switch result {
                         case let .success(network):
                           success(network)
                         case let .failure(error):
                           failure(error)
                         }
                       })
  }
}
