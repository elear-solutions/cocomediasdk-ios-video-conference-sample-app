//
//  UserDataManager.swift
//  sessions
//
//  Created by Rohan S on 21/12/21.
//

import Foundation

private let defaults = UserDefaults.standard

private enum savedKey: String {
  case isUserLoggedIn
  case usernameLoggedIn
  case accessToken
  case baseURL
}

final class UserDataManager {
  func getUserLoggedIn() -> Bool {
    return defaults.bool(forKey: savedKey.isUserLoggedIn.rawValue)
  }

  func setUserLoggedIn(_ value: Bool) {
    defaults.set(value, forKey: savedKey.isUserLoggedIn.rawValue)
  }

  func getUsername() -> String {
    return defaults.string(forKey: savedKey.usernameLoggedIn.rawValue) ?? String()
  }

  func setUsername(_ value: String) {
    defaults.setValue(value, forKey: savedKey.usernameLoggedIn.rawValue)
  }

  func getURL() -> String {
    let defaultURL = "http://13.232.105.177:8080"
    return defaults.string(forKey: savedKey.baseURL.rawValue) ?? defaultURL
  }

  func setURL(_ value: String) {
    defaults.setValue(value, forKey: savedKey.baseURL.rawValue)
  }
}
