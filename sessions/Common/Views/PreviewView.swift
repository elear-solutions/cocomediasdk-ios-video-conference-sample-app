//
//  PreviewView.swift
//  sessions
//
//  Created by Rohan S on 16/11/21.
//

import AVFoundation
import UIKit

final class PreviewView: UIView {
  // MARK: Internal

  func setSession(_ session: AVCaptureSession) {
    CATransaction.begin()
    CATransaction.setDisableActions(true)

    videoLayer.session = session
    videoLayer.frame = bounds
    videoLayer.videoGravity = .resizeAspectFill
    layer.insertSublayer(videoLayer, at: 0)

    CATransaction.commit()
  }

  // MARK: Private

  private let videoLayer = AVCaptureVideoPreviewLayer()
}
