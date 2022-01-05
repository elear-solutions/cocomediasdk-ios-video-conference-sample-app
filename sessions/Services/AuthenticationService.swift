//
//  AuthenticationService.swift
//  sessions
//
//  Created by Rohan S on 20/12/21.
//
import SwiftyJSON

class FetchTokenParameter: RequestModel {
  // MARK: Lifecycle

  init(username: String) {
    userId = username
  }

  // MARK: Internal

  var userId: String

  func wrap() -> [String: Any] {
    return [
      "userId": userId,
    ]
  }
}

class FetchTokenResponse: ResponseResult, Encodable {
  // MARK: Lifecycle

  required init(json: JSON) {
    accessToken = json["access_token"].stringValue
    expiresIn = json["expires_in"].stringValue
    tokenType = json["token_type"].stringValue
  }

  // MARK: Internal

  var accessToken: String
  var expiresIn: String
  var tokenType: String
  var refreshToken: String = "willRemoveLater" // TODO: Remove after fix from platform

  var rawString: String? {
    let encoder = JSONEncoder()
    if let data = try? encoder.encode(self) {
      return String(data: data, encoding: .utf8)
    }
    return nil
  }

  // MARK: Private

  private enum CodingKeys: String, CodingKey {
    case accessToken = "access_token"
    case expiresIn = "expires_in"
    case tokenType = "token_type"
    case refreshToken = "refresh_token"
  }
}

typealias FetchTokenResult = (_ result: Result<FetchTokenResponse, Error>) -> Void

final class AuthenticationManager {
  class func fetchToken(params: FetchTokenParameter,
                        handler: @escaping FetchTokenResult)
  {
    let parameters = params.wrap()

    AlamofireManager().request(requestMethod: .post,
                               path: "/v1.0/token/fetch-user-token",
                               params: parameters,
                               success: { result, statusCode in
                                 switch statusCode {
                                 case 200 ... 299:
                                   let json = JSON(result)
                                   let tokenResponse = FetchTokenResponse(json: json)
                                   handler(.success(tokenResponse))
                                 default:
                                   break
                                 }
                               },
                               failure: { error in
                                 handler(.failure(error))
                               })
  }
}
