//
//  SpinnerView.swift
//  sessions
//
//  Created by Rohan S on 09/01/22.
//

import UIKit

var vSpinner: UIView?

extension UIViewController {
  func showSpinner(onView: UIView) {
    let spinnerView = UIView(frame: onView.bounds)
    spinnerView.backgroundColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
    let ai = UIActivityIndicatorView(style: .large)
    ai.startAnimating()
    ai.center = spinnerView.center

    DispatchQueue.main.async {
      spinnerView.addSubview(ai)
      onView.addSubview(spinnerView)
    }

    vSpinner = spinnerView
  }

  func removeSpinner() {
    DispatchQueue.main.async {
      vSpinner?.removeFromSuperview()
      vSpinner = nil
    }
  }
}
