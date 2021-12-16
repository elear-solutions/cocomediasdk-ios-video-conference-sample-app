//
//  CallView.swift
//  sessions
//
//  Created by Rohan S on 15/12/21.
//

import Foundation
import UIKit
import AVFoundation

class CallView: UIView {
  @IBOutlet weak var callerPreview: PreviewView!
  @IBOutlet weak var callPreview02: UIView!
  @IBOutlet weak var callPreview03: UIView!
  @IBOutlet weak var callPreview04: UIView!
  
  @IBOutlet weak var btnToggleCamera: UIButton!
  @IBOutlet weak var btnToggleVideo: UIButton!
  @IBOutlet weak var btnEndCall: UIButton!
  @IBOutlet weak var btnToggleMicrophone: UIButton!
  @IBOutlet weak var btnToggleSpeaker: UIButton!
  
  private func setupToggleCameraButton() {
    btnToggleCamera.addTarget(
      self,
      action: #selector(didTouchUpInside),
      for: .touchUpInside)
  }
  
  private func setupToggleVideoButton() {
    btnToggleVideo.addTarget(
      self,
      action: #selector(didTouchUpInside),
      for: .touchUpInside)
    btnToggleVideo.setImage(
      UIImage(systemName: "video.fill"),
      for: .normal)
    btnToggleVideo.setImage(
      UIImage(systemName: "video.slash.fill"),
      for: .selected)
  }
  
  private func setupEndCallButton() {
    btnEndCall.addTarget(
      self,
      action: #selector(didTouchUpInside),
      for: .touchUpInside)
  }
  
  private func setupToggleMicrophoneButton() {
    btnToggleMicrophone.addTarget(
      self,
      action: #selector(didTouchUpInside),
      for: .touchUpInside)
    btnToggleMicrophone.setImage(
      UIImage(systemName: "mic.fill"),
      for: .normal)
    btnToggleMicrophone.setImage(
      UIImage(systemName: "mic.slash.fill"),
      for: .selected)
  }
  
  private func setupToggleSpeakerButton() {
    btnToggleSpeaker.addTarget(
      self,
      action: #selector(didTouchUpInside),
      for: .touchUpInside)
    btnToggleSpeaker.setImage(
      UIImage(systemName: "speaker.3.fill"),
      for: .normal)
    btnToggleSpeaker.setImage(
      UIImage(systemName: "speaker.slash.fill"),
      for: .selected)
  }
  
  @objc private func didTouchUpInside(sender: UIButton) {
    sender.isSelected = !sender.isSelected
    switch sender {
    case btnToggleCamera:
      break
    case btnToggleVideo:
      if sender.isSelected {
        session.startRunning()
      } else {
        session.stopRunning()
      }
    case btnEndCall:
      break
    case btnToggleMicrophone:
      break
    case btnToggleSpeaker:
      break
    default:
      break
    }
  }
  
  private let session = AVCaptureSession()
  
  private func setupCallerPreviewView() {
    self.callerPreview.session = self.session
    session.beginConfiguration()
    let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera,
                                              for: .video,
                                              position: .unspecified)
    guard
      let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice!),
      session.canAddInput(videoDeviceInput) else
    {
      debugPrint("failed to acquire camera")
      return
    }
    session.addInput(videoDeviceInput)
    let photoOutput = AVCapturePhotoOutput()
    guard session.canAddOutput(photoOutput) else { return }
    session.sessionPreset = .hd1920x1080
    session.addOutput(photoOutput)
    session.commitConfiguration()
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    self.setupToggleCameraButton()
    self.setupToggleVideoButton()
    self.setupEndCallButton()
    self.setupToggleMicrophoneButton()
    self.setupToggleSpeakerButton()
  }
  
  override func willMove(toSuperview newSuperview: UIView?) {
    super.willMove(toSuperview: newSuperview)
  }
  
  override func didMoveToSuperview() {
    super.didMoveToSuperview()
  }
}
