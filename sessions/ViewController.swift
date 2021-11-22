//
//  ViewController.swift
//  sessions
//
//  Created by Rohan S on 12/11/21.
//

import AVFoundation
import UIKit

class ViewController: UIViewController {
  @IBOutlet weak var previewView: PreviewView!
  @IBOutlet weak var btnEnableVideo: UIButton!
  @IBOutlet weak var btnEnableMicrophone: UIButton!
  @IBOutlet weak var btnEnableSpeaker: UIButton!
  
  private let session = AVCaptureSession()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    self.setup()

  }
  
  override func viewDidDisappear(_ animated: Bool) {
    self.session.stopRunning()
    // Do any additional wrap up before unloading the view.
    super.viewDidDisappear(animated)
  }
  
  private func setup() {
    setupButtons()
    setupPreview()
  }
  
  private func setupPreview() {
    previewView.session = session
    session.beginConfiguration()
    let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera,
                                              for: .video,
                                              position: .unspecified)
    guard
      let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice!),
      session.canAddInput(videoDeviceInput)
    else {
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
  
  private func setupVideoButton() {
    btnEnableVideo.addTarget(self,
                             action: #selector(buttonDidTap),
                             for: .touchUpInside)
    btnEnableVideo.setImage(UIImage(systemName: "video.circle"),
                            for: .normal)
    btnEnableVideo.setImage(UIImage(systemName: "video.circle.fill"),
                            for: .selected)
  }
  
  private func setupMicrophoneButton() {
    btnEnableMicrophone.addTarget(self,
                                  action: #selector(buttonDidTap),
                                  for: .touchUpInside)
    btnEnableMicrophone.setImage(UIImage(systemName: "mic.circle"),
      for: .normal)
    btnEnableMicrophone.setImage(UIImage(systemName: "mic.circle.fill"),
      for: .selected)
  }
  
  private func setupSpeakerButton() {
    btnEnableSpeaker.setImage(UIImage(systemName: "speaker.wave.2.circle.fill"),
      for: .normal)
    btnEnableSpeaker.setImage(UIImage(systemName: "speaker.slash.circle.fill"),
      for: .selected)
    btnEnableSpeaker.addTarget(self,
                               action: #selector(buttonDidTap),
                               for: .touchUpInside)
  }
  
  private func setupButtons() {
    setupVideoButton()
    setupMicrophoneButton()
    setupSpeakerButton()
  }
  
  @objc private func buttonDidTap(sender: UIButton) {
    sender.isSelected = !sender.isSelected
    switch sender {
      case btnEnableVideo:
        if sender.isSelected {
          self.session.startRunning()
        } else {
          self.session.stopRunning()
        }
      default:
        break
    }
  }
}

