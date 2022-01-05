//
//  AppDelegate.swift
//  sessions
//
//  Created by Rohan S on 12/11/21.
//

import CocoMediaSDK
import UIKit

@available(iOS 13.0, *)
@main
class AppDelegate: UIResponder, UIApplicationDelegate {
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
    debugPrint("authEndpoint:", authorizationEndpoint)
    debugPrint("tokenEndpoint:", tokenEndpoint)
    UserDataManager().setUserLoggedIn(false)
    DispatchQueue.main.async {
      let vc = ViewController.initFromNib()
      let nav = UINavigationController(rootViewController: vc)
      let window = UIWindow(frame: UIScreen.main.bounds)
      window.rootViewController = nav
      window.makeKeyAndVisible()
    }
  }
}
