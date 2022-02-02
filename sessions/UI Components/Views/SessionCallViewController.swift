//
//  SessionCallViewController.swift
//  sessions
//
//  Created by Rohan S on 20/12/21.
//

import AVFoundation
import CocoMediaPlayer
import CocoMediaSDK
import UIKit

class SessionCallViewController: UIViewController {
  // MARK: Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()

    // Do any additional setup after loading the view.
    setup()
  }

  // MARK: Internal

  static let identifier = String(describing: SessionCallViewController.self)

  /*
   // MARK: - Navigation

   // In a storyboard-based application, you will often want to do a little preparation before navigation
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
       // Get the new view controller using segue.destination.
       // Pass the selected object to the new view controller.
   }
   */

  @IBOutlet var callerPreview: PreviewView!
  @IBOutlet var callPreview02: UIView!
  @IBOutlet var callPreview03: UIView!
  @IBOutlet var callPreview04: UIView!

  @IBOutlet var btnToggleCamera: UIButton!
  @IBOutlet var btnToggleVideo: UIButton!
  @IBOutlet var btnEndCall: UIButton!
  @IBOutlet var btnToggleMicrophone: UIButton!
  @IBOutlet var btnToggleSpeaker: UIButton!

  var selectedNetwork: Network?

  // MARK: Private

  private let session = AVCaptureSession()

  private var players: [SampleBufferPlayer] = .init()

  private func setupToggleCameraButton() {
    btnToggleCamera.addTarget(
      self,
      action: #selector(didTouchUpInside),
      for: .touchUpInside
    )
  }

  private func setupToggleVideoButton() {
    btnToggleVideo.addTarget(
      self,
      action: #selector(didTouchUpInside),
      for: .touchUpInside
    )
    btnToggleVideo.setImage(
      UIImage(systemName: "video.fill"),
      for: .normal
    )
    btnToggleVideo.setImage(
      UIImage(systemName: "video.slash.fill"),
      for: .selected
    )
  }

  private func setupEndCallButton() {
    btnEndCall.addTarget(
      self,
      action: #selector(didTouchUpInside),
      for: .touchUpInside
    )
  }

  private func setupToggleMicrophoneButton() {
    btnToggleMicrophone.addTarget(
      self,
      action: #selector(didTouchUpInside),
      for: .touchUpInside
    )
    btnToggleMicrophone.setImage(
      UIImage(systemName: "mic.fill"),
      for: .normal
    )
    btnToggleMicrophone.setImage(
      UIImage(systemName: "mic.slash.fill"),
      for: .selected
    )
  }

  private func setupToggleSpeakerButton() {
    btnToggleSpeaker.addTarget(
      self,
      action: #selector(didTouchUpInside),
      for: .touchUpInside
    )
    btnToggleSpeaker.setImage(
      UIImage(systemName: "speaker.3.fill"),
      for: .normal
    )
    btnToggleSpeaker.setImage(
      UIImage(systemName: "speaker.slash.fill"),
      for: .selected
    )
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
      try? selectedNetwork?.disconnect()
      navigationController?.popViewController(animated: true)
    case btnToggleMicrophone:
      break
    case btnToggleSpeaker:
      break
    default:
      break
    }
  }

  private func setupHostPreviewView() {
    callerPreview.session = self.session
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

  private func setupParticipantView() {
    players = .init(repeating: SampleBufferPlayer(),
                    count: 3)
    players[0].attach(view: callPreview02)
    players[1].attach(view: callPreview03)
    players[2].attach(view: callPreview04)
  }

  private func setup() {
    setupToggleCameraButton()
    setupToggleVideoButton()
    setupEndCallButton()
    setupToggleMicrophoneButton()
    setupToggleSpeakerButton()
    setupHostPreviewView()
  }
}
