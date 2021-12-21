//
//  RestApiHeaders.swift
//  sessions
//
//  Created by Rohan S on 21/12/21.
//

import Alamofire

final class RestApiHeaders {
  class func defaultHeaders() -> HTTPHeaders {
    let headers = HTTPHeaders(["Content-Type": "application/json"])
    return headers
  }
}
