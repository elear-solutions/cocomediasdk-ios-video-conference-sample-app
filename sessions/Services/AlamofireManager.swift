//
//  AlamofireManager.swift
//  sessions
//
//  Created by Rohan S on 21/12/21.
//

import Alamofire
import Foundation
import SwiftyJSON

final class AlamofireManager {
  final var baseURL = URL(string: "http://13.232.105.177:8080")!

  func request(requestMethod: HTTPMethod,
               path: String,
               params: [String: Any]?,
               headers: HTTPHeaders = RestApiHeaders.defaultHeaders(),
               success: @escaping (Any, Int) -> Void,
               failure: @escaping (Error) -> Void)
  {
    let finalURL = baseURL.appendingPathComponent(path)
    let serializer = DataResponseSerializer(emptyResponseCodes: Set([200, 204, 205]))
    let request = AF.request(finalURL,
                             method: HTTPMethod(rawValue: requestMethod.rawValue),
                             parameters: params,
                             encoding: requestMethod == .get ? URLEncoding.default : JSONEncoding.default,
                             headers: headers).validate(statusCode: [200, 204, 205])
    request.response(responseSerializer: serializer) { response in
      debugPrint(response)
    }
  }
}
