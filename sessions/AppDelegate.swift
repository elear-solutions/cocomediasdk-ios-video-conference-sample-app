//
//  AppDelegate.swift
//  sessions
//
//  Created by Rohan S on 12/11/21.
//

import AVFoundation
import CocoMediaSDK
import OSLog
import UIKit

@available(iOS 13.0, *)
@main
class AppDelegate: UIResponder, UIApplicationDelegate {
  // MARK: Internal

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    // Override point for customization after application launch.
    // Initialize CocoMediaSDK
    let config = CocoMediaConfig(authDelegate: self)
    do {
      try CocoMediaClient.setup(config)
      client = CocoMediaClient.shared
    } catch {
      debugPrint("error using setup()", error.localizedDescription)
    }
    setUpAudioSession()
    return true
  }

  // MARK: UISceneSession Lifecycle

  func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
  }

  func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
  }

  // MARK: Private

  private let logger = OSLog(AppDelegate.self)
}

extension AppDelegate {
  private func setUpAudioSession() {
    os_log("%s started", log: logger, type: .debug, #function)
    let session = AVAudioSession.sharedInstance()
    do {
      try session.setCategory(.playAndRecord,
                              mode: .voiceChat,
                              options: [.defaultToSpeaker, .allowBluetooth])
      try? session.setPreferredIOBufferDuration(0.4)
    } catch {
      os_log("%s failed: %s", log: logger, type: .error,
             #function, error.localizedDescription)
    }
    os_log("%s completed", log: logger, type: .debug, #function)
  }
}

extension AppDelegate: CocoClientAuthDelegate {
  func accessTokenCallback(accessToken: String, status: Command.Status, context: UnsafeRawPointer?) {
    // TODO: Add default implementation
    return
  }

  func refreshTokenCallback(status: Command.Status) {
    // TODO: Add default implementation
    return
  }

  func authCallback(authorizationEndpoint: String, tokenEndpoint: String) {
    os_log("%s started", log: logger, type: .debug, #function)
    os_log("%s authEndpoint: %s", log: logger, type: .info, #function,
           authorizationEndpoint)
    os_log("%s tokenEndpoint: %s", log: logger, type: .info, #function,
           tokenEndpoint)
    DispatchQueue.main.async {
      guard let rootViewController = UIApplication.shared.windows.first?.rootViewController else {
        os_log("%s rootViewController: nil", log: self.logger, type: .error, #function)
        return
      }
      let loginVC = UIStoryboard(name: "Main", bundle: nil)
        .instantiateViewController(identifier: "LoginViewController")
      rootViewController.modalPresentationStyle = .fullScreen
      rootViewController.modalTransitionStyle = .coverVertical
      rootViewController.present(loginVC, animated: true)
    }
    os_log("%s completed", log: logger, type: .debug, #function)
  }
}
