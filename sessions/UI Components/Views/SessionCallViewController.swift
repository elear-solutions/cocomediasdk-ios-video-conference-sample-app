//
//  SessionCallViewController.swift
//  sessions
//
//  Created by Rohan S on 20/12/21.
//

import AMRAudioSwift
import AVFoundation
import CocoMediaPlayer
import CocoMediaSDK
import OSLog
import UIKit

class SessionCallViewController: UIViewController {
  // MARK: Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()

    // Do any additional setup after loading the view.
    setup()
    do {
      selectedNetwork?.delegate = self
      debugPrint("[DBG] \(#file) -> \(#function) \(#file) -> \(#function) connecting: \(selectedNetwork!)")
      try selectedNetwork?.connect()
    } catch {
      debugPrint("[DBG] \(#file) -> \(#function) \(#file) -> \(#function)  error: \(error.localizedDescription)")
    }
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    do {
      debugPrint("[DBG] \(#file) -> \(#function) disconnecting: \(selectedNetwork!)")
      try selectedNetwork?.disconnect()
    } catch {
      debugPrint("[DBG] \(#file) -> \(#function) \(#function) error: \(error.localizedDescription)")
    }
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

  @IBOutlet var callerPreview: PreviewView! // blue
  @IBOutlet var callPreview02: UIView! // red
  @IBOutlet var callPreview03: UIView! // orange
  @IBOutlet var callPreview04: UIView! // green

  @IBOutlet var btnToggleCamera: UIButton!
  @IBOutlet var btnToggleVideo: UIButton!
  @IBOutlet var btnEndCall: UIButton!
  @IBOutlet var btnToggleMicrophone: UIButton!
  @IBOutlet var btnToggleSpeaker: UIButton!

  var selectedNetwork: Network?

  // MARK: Private

  private let session = AVCaptureSession()

  private var players: [SampleBufferPlayer] = .init(repeating: SampleBufferPlayer(),
                                                    count: 3)
  private var videoDecoders: [LiveVideoDecoder] = .init(repeating: .init(),
                                                        count: 3)
  private var audioDecoders: [LiveAudioDecoder] = .init(repeating: .init(AudioMediaFrame.AmrWbFormatHelper(sampleRate: 16000)),
                                                        count: 3)
  private var basetime: Int?

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

    // showSpinner(onView: callPreview02)
    // showSpinner(onView: callPreview03)
    // showSpinner(onView: callPreview04)
  }

  private func setupParticipantView() {
    players[0].attach(view: callPreview02) // red
    players[1].attach(view: callPreview03) // orange
    players[2].attach(view: callPreview04) // green
  }

  private func setupRecordingAudioSession() {
    let avAudioSession = AVAudioSession.sharedInstance()
    do {
      try avAudioSession.setCategory(.playAndRecord,
                                     mode: .voiceChat,
                                     options: [.defaultToSpeaker, .allowBluetooth])
      // try? avAudioSession.setPreferredIOBufferDuration(0.4)
    } catch {
      debugPrint(error.localizedDescription)
    }
  }

  private func setup() {
    setupToggleCameraButton()
    setupToggleVideoButton()
    setupEndCallButton()
    setupToggleMicrophoneButton()
    setupToggleSpeakerButton()
    setupHostPreviewView()
    setupParticipantView()
  }
}

extension SessionCallViewController: NetworkDelegate {
  func didReceiveData(_ network: Network, from node: Node, data: String?) {
    debugPrint("[DBG] \(#file) -> \(#function) \(node)")
    debugPrint("[DBG] \(#file) -> \(#function) \(data ?? "")")
  }

  func didReceiveContentInfo(_ network: Network, from node: Node, metadata: String?, time stamp: TimeInterval) {
    debugPrint("[DBG] \(#file) -> \(#function) \(node)")
    debugPrint("[DBG] \(#file) -> \(#function) \(metadata ?? "")")
    debugPrint("[DBG] \(#file) -> \(#function) \(stamp)")
  }

  func didChangeStatus(_ network: Network, status from: Network.State, to: Network.State) {
    debugPrint("[DBG] \(#file) -> \(#function) coco_media_client_connect_status_cb_t: ", from, to)
    switch to {
    case .COCO_CLIENT_REMOTE_CONNECTED:
      removeSpinner()
      try! network.getChannels(completionHandler: { result in
        debugPrint("[DBG] \(#file) -> \(#function) result:", result)
        switch result {
        case let .success(channels):
          debugPrint("[DBG] \(#file) -> \(#function) channels.count:", channels.count)
          for channel in channels {
            do {
              debugPrint(channel)
              channel.delegate = self
              try channel.join()
            } catch {
              debugPrint("[DBG] \(#file) -> \(#function) error:", error.localizedDescription)
            }
          }
        case let .failure(error):
          debugPrint("[DBG] \(#file) -> \(#function) getChannels.error:", error.localizedDescription)
        }
      })
    case .COCO_CLIENT_COCONET_BLOCKED,
         .COCO_CLIENT_COCONET_RESET,
         .COCO_CLIENT_CONNECT_ERROR,
         .COCO_CLIENT_DISCONNECTED:
      removeSpinner()
      DispatchQueue.main.async {
        self.navigationController?.popViewController(animated: true)
      }
    default:
      break
    }
  }
}

extension SessionCallViewController: ChannelDelegate {
  func didReceive(_ channel: Channel, rxStream: RxStream) {
    debugPrint("[DBG] \(#function) channel: \(channel)")
    debugPrint("[DBG] \(#function) rxStream: \(rxStream)")
    guard let sdpString = rxStream.sdp else {
      debugPrint("sdpString is nil")
      return
    }
    let sdp = players[0].parse(sdpString: sdpString)
    debugPrint("[DBG] \(#function) sdpString: \(String(describing: sdp))")
    guard let mediaDesc = sdp?.mediaDescriptionList.first else {
      return
    }
    switch mediaDesc.mediaType {
    case "video":
      videoDecoders[0].delegate = self
    case "audio":
      audioDecoders[0].delegate = self
    default:
      break
    }
    try! rxStream.start { status in
      switch status {
      case .COCO_MEDIA_CLIENT_STREAM_STARTED:
        rxStream.delegate = self
      default:
        break
      }
    }
  }

  func didChangeStatus(_ channel: Channel, status from: Channel.Status, to: Channel.Status) {
    debugPrint("[DBG] \(#file) -> \(#function) channel: \(channel)")
    debugPrint("[DBG] \(#file) -> \(#function) status from -> to", from, to)
  }
}

extension SessionCallViewController: LiveDecoderDelegate {
  func output(mediaFrame: MediaFrame) {
    debugPrint("[DBG] \(#function) started.")
    players[0].enqueue(mediaFrame)
    if players[0].state != .PLAYING {
      players[0].play()
    }
    debugPrint("[DBG] \(#function) completed.")
  }
}

extension SessionCallViewController: RxStreamDelegate {
  func didReceiveFrame(_ stream: CocoMediaSDK.Stream, frame: PackedFrame) {
    debugPrint("[DBG] \(#function) started.")
    debugPrint("[DBG] \(#function) stream: \(String(describing: stream))")
    debugPrint("[DBG] \(#function) frame: \(String(describing: frame))")
    debugPrint("[DBG] \(#function) frame.data: \(String(describing: frame.data?.hex))")
    if basetime == nil {
      basetime = frame.time
    }
    guard let basetime = basetime else {
      return
    }
    let tmpDiff = Double(frame.time) - Double(basetime)
    let ptsDiff = tmpDiff
    let ptsTime: Double = .init(ptsDiff / 10_000_000) // convert into seconds
    guard let data = frame.data else {
      return
    }
    switch frame.mime {
    case .COCO_MEDIA_CLIENT_MIME_TYPE_VIDEO_H264:
      let time = CMTime(seconds: ptsTime, preferredTimescale: 90000)
      try! videoDecoders[0].feed(data: data, sampleTime: time)
    case .COCO_MEDIA_CLIENT_MIME_TYPE_AUDIO_AAC:
      let time = CMTime(seconds: ptsTime, preferredTimescale: 16000)
      // let data = AMRAudio.decodeAMRDataToWAVEData(amrData: data)
      try! audioDecoders[0].feed(data: data, sampleTime: time)
    default:
      break
    }
    debugPrint("[DBG] \(#function) completed.")
  }

  func didChangeStatus(_ stream: CocoMediaSDK.Stream, status from: CocoMediaSDK.Stream.Status, to: CocoMediaSDK.Stream.Status) {
    // TODO: Add in extension
  }
}
