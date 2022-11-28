//
//  SessionCallViewController.swift
//  sessions
//
//  Created by Rohan S on 20/12/21.
//

import AVFoundation
import CocoMediaPlayer
import CocoMediaSDK
import OSLog
import UIKit

final class SessionCallViewController: UIViewController {
  // MARK: Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()

    selectedNetwork?.delegate = self
    do {
      debugPrint("[DBG] \(#file) -> \(#function) connecting: \(selectedNetwork!)")
      try selectedNetwork?.connect()
    } catch {
      debugPrint("[DBG] \(#file) -> \(#function)  error: \(error.localizedDescription)")
    }
    setup()
  }

  deinit {
    captureSession.stopSession()
    do {
      debugPrint("[DBG] \(#file) -> \(#function) disconnecting: \(selectedNetwork!)")
      try selectedNetwork?.disconnect()
    } catch {
      debugPrint("[DBG] \(#file) -> \(#function) \(#function) error: \(error.localizedDescription)")
    }
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    callerPreview.setSession(captureSession.session)
    reattachPlayers()
    sendButton.layer.cornerRadius = sendButton.bounds.height / 2
    inviteButton.layer.cornerRadius = 4
  }

  // MARK: Internal

  static let identifier = String(describing: SessionCallViewController.self)

  var selectedNetwork: Network?

  // MARK: Private

  @IBOutlet private var callPreview04: UIView! // blue
  @IBOutlet private var callPreview02: UIView! // yellow
  @IBOutlet private var callPreview03: UIView! // green
  @IBOutlet private var callerPreview: PreviewView! // red

  @IBOutlet private var btnToggleCamera: UIButton!
  @IBOutlet private var btnToggleVideo: UIButton!
  @IBOutlet private var btnToggleMicrophone: UIButton!

  @IBOutlet private var inviteButton: UIButton!
  @IBOutlet private var chatContainerView: UIView!
  @IBOutlet private var chatField: PaddingTextField!
  @IBOutlet private var sendButton: UIButton!

  private let captureSession = CaptureClient()

  private var players = [SampleBufferPlayer(), SampleBufferPlayer(), SampleBufferPlayer()]
  private var videoDecoders = [LiveVideoDecoder]()
  private var audioDecoders = [LiveAudioDecoder]()

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

    let largeConfig = UIImage.SymbolConfiguration(pointSize: 32, weight: .medium, scale: .medium)
    let video = UIImage(systemName: "video", withConfiguration: largeConfig)
    let videoOff = UIImage(systemName: "video.slash", withConfiguration: largeConfig)

    btnToggleVideo.setImage(video, for: .normal)
    btnToggleVideo.setImage(videoOff, for: .selected)
  }

  private func setupToggleMicrophoneButton() {
    btnToggleMicrophone.addTarget(
      self,
      action: #selector(didTouchUpInside),
      for: .touchUpInside
    )
    let largeConfig = UIImage.SymbolConfiguration(pointSize: 32, weight: .medium, scale: .medium)
    let mic = UIImage(systemName: "mic", withConfiguration: largeConfig)
    let micOff = UIImage(systemName: "mic.slash", withConfiguration: largeConfig)

    btnToggleMicrophone.setBackgroundImage(mic, for: .normal)
    btnToggleMicrophone.setBackgroundImage(micOff, for: .selected)
  }

  private func setupVideoClient() {
    do {
      try captureSession.startSendingVideoToServer()
    } catch {
      debugPrint("error video client: \(error.localizedDescription)")
    }
  }

  private func setup() {
    enableKeyboardDismissal()
    setupToggleCameraButton()
    setupToggleVideoButton()
    setupToggleMicrophoneButton()
    setupVideoClient()
    chatField.attributedPlaceholder = NSAttributedString(string: "Type a message...", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white.withAlphaComponent(0.5)])
  }

  @objc private func didTouchUpInside(sender: UIButton) {
    switch sender {
    case btnToggleCamera:
      if !btnToggleVideo.isSelected {
        captureSession.changeCamera()
      }
    case btnToggleVideo:
      sender.isSelected = !sender.isSelected
      sender.isSelected ? captureSession.disableCamera() : captureSession.enableCamera()
    case btnToggleMicrophone:
      sender.isSelected = !sender.isSelected
      captureSession.isMuted = !captureSession.isMuted
    default:
      break
    }
  }

  @IBAction private func invite() {
    view.endEditing(true)
    let controller = InviteViewController.initFromNib()
    controller.network = selectedNetwork
    navigationController?.pushViewController(controller, animated: true)
  }

  @IBAction private func sendMessage() {
    guard let message = chatField.text else {
      return
    }
    chatField.text = ""
    selectedNetwork?.sendMessage(message: message)
  }

  // MARK: - Helpers

  private func generateDesc(isVideo: Bool) -> String {
    let builder = SessionDescription.Builder()
    builder.origin = "coco_client 0 0 IN IP4 0.0.0.0"
    builder.sessionName = "coco media_sessions"
    builder.timing = "0 0"

    if isVideo {
      let mediaBuilder = MediaDescription.Builder(mediaType: "video", port: 0, transportProtocol: "RTP/AVP", payloadTypes: [98])
      mediaBuilder.addRtpMapAttribute(rtpMapAttribute: RtpMapAttribute(payload: 98, mediaEncoding: "H264", clockRate: 90000, encodingParameters: 0))
      builder.addMediaDescription(mediaBuilder.build())
    } else {
      let mediaBuilder = MediaDescription.Builder(mediaType: "audio", port: 0, transportProtocol: "RTP/AVP", payloadTypes: [99])
      mediaBuilder.addRtpMapAttribute(rtpMapAttribute: RtpMapAttribute(payload: 99, mediaEncoding: "ALAW", clockRate: 16000, encodingParameters: 1))
      builder.addMediaDescription(mediaBuilder.build())
    }

    let desc = SessionDescription(builder: builder)

    return SessionDescriptionParser.unParse(sessionDescription: desc)
  }
}

// MARK: - Network

extension SessionCallViewController: NetworkDelegate {
  func didReceiveData(_ network: Network, from node: Node, data: String?) {
    debugPrint("[DBG] \(#file) -> \(#function) \(node)")
    debugPrint("[DBG Message] \(#file) -> \(#function) \(data ?? "")")
    guard let message = data else {
      return
    }
    DispatchQueue.main.async { [weak self] in
      guard let self = self else { return }
      MessageView().show(message: message, node: node.id, on: self.view)
    }
  }

  func didReceiveContentInfo(_ network: Network, from node: Node, metadata: String?, time stamp: TimeInterval) {
    debugPrint("[DBG] \(#file) -> \(#function) \(node)")
    debugPrint("[DBG] \(#file) -> \(#function) \(metadata ?? "")")
    debugPrint("[DBG] \(#file) -> \(#function) \(stamp)")

    guard let message = metadata else {
      return
    }
    DispatchQueue.main.async { [weak self] in
      guard let self = self else { return }
      MessageView().show(message: message, node: node.id, on: self.view)
    }
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

// MARK: - Channel

extension SessionCallViewController: ChannelDelegate {
  func didReceive(_ channel: Channel, rxStream: RxStream) {
    debugPrint("[DBG] \(#function) channel: \(channel)")
    debugPrint("[DBG] \(#function) rxStream: \(rxStream)")
    if rxStream.status != .COCO_MEDIA_CLIENT_STREAM_CREATED {
      return
    }
    try? rxStream.start { status in
      switch status {
      case .COCO_MEDIA_CLIENT_STREAM_STARTED:
        rxStream.delegate = self
      default:
        break
      }
    }
  }

  func didChangeStatus(_ channel: Channel, status from: Channel.Status, to: Channel.Status) {
    switch to {
    case .COCO_MEDIA_CLIENT_CHANNEL_JOINED:
      let vTxStream = try! channel.createStream(descriptor: generateDesc(isVideo: true), statusHandler: { status in
        switch status {
        case .COCO_MEDIA_CLIENT_STREAM_CREATED:
          debugPrint("video stream created")
        default:
          debugPrint("txStream status: \(status)")
        }
      })
      vTxStream.delegate = self
      let aTxStream = try! channel.createStream(descriptor: generateDesc(isVideo: false), statusHandler: { status in
        switch status {
        case .COCO_MEDIA_CLIENT_STREAM_CREATED:
          debugPrint("audio stream created")
        default:
          debugPrint(status)
        }
      })
      aTxStream.delegate = self
    default:
      break
    }
  }
}

// MARK: - MediaFrame

extension SessionCallViewController: LiveDecoderDelegate, VideoAngleDelegate {
  func output(mediaFrame: MediaFrame, sender: LiveDecoder) {
    debugPrint("[DBG] \(#function) started.")
    guard let index = videoDecoders.firstIndex(where: { $0.rxStreamId == sender.rxStreamId }) else {
      debugPrint("[DBG] \(#function) No decoder with such index: \(sender)")
      return
    }
    enqueueFrame(frame: mediaFrame, index: index)
    debugPrint("[DBG] \(#function) completed.")
  }

  func rotate(angle: CGFloat, sender: LiveDecoder) {
    guard let index = videoDecoders.firstIndex(where: { $0.rxStreamId == sender.rxStreamId }) else {
      debugPrint("[DBG] \(#function) No decoder with such index: \(sender)")
      return
    }
    DispatchQueue.main.async { [weak self] in
      self?.players[index].rotate(angle: angle)
      self?.view.setNeedsLayout()
    }
  }

  private func enqueueFrame(frame: MediaFrame, index: Int) {
    players[index].enqueue(frame)
    if players[index].state != .PLAYING {
      players[index].play()
    }
  }
}

// MARK: - RxStream

extension SessionCallViewController: RxStreamDelegate {
  func didReceiveFrame(_ stream: CocoMediaSDK.Stream, frame: PackedFrame) {
    debugPrint("[DBG] \(#function) started.")
    debugPrint("[DBG] \(#function) stream: \(String(describing: stream))")
    debugPrint("[DBG] \(#function) frame: \(String(describing: frame))")
    debugPrint("[DBG] \(#function) frame.data: \(String(describing: frame.data?.hex))")

    guard let data = frame.data else {
      return
    }
    switch frame.mime {
    case .COCO_MEDIA_CLIENT_MIME_TYPE_VIDEO_H264:
      let time = CMTime(value: CMTimeValue(frame.time), timescale: 1_000_000_000)
      guard let index = videoDecoders.firstIndex(where: { $0.rxStreamId == stream.sourceNodeId }) else {
        debugPrint("[DBG] No video decoder with such sourceNodeId: \(stream)")
        return
      }
      try! videoDecoders[index].feed(data: data, sampleTime: time)
    case .COCO_MEDIA_CLIENT_MIME_TYPE_AUDIO_AAC:
      let newTime = CMTime(value: CMTimeValue(frame.time), timescale: 16000)
      guard let index = audioDecoders.firstIndex(where: { $0.rxStreamId == stream.sourceNodeId }) else {
        debugPrint("[DBG] \(#function) No audio decoder with such sourceNodeId: \(stream)")
        return
      }
      try! audioDecoders[index].feed(data: data, sampleTime: newTime)
    default:
      break
    }
    debugPrint("[DBG] \(#function) completed.")
  }
}

// MARK: - Stream status

extension SessionCallViewController: TxStreamDelegate {
  func didChangeStatus(_ stream: CocoMediaSDK.Stream, status from: CocoMediaSDK.Stream.Status, to: CocoMediaSDK.Stream.Status) {
    debugPrint("[DBG] \(#function) txstream: \(stream)")

    if stream is TxStream, to == .COCO_MEDIA_CLIENT_STREAM_CREATED {
      setupTxStream(stream)
    }

    if to == .COCO_MEDIA_CLIENT_STREAM_STARTED && stream is RxStream {
      setupRxStream(stream)
    } else if to == .COCO_MEDIA_CLIENT_STREAM_CLOSED || to == .COCO_MEDIA_CLIENT_STREAM_DESTROYED {
      stopStream(stream)
    }
    debugPrint("[DBG] \(#function) status: \(to)")
  }

  private func setupTxStream(_ stream: CocoMediaSDK.Stream) {
    let sdp = try? SessionDescriptionParser.parse(sdpString: stream.sdp ?? "")
    guard let mediaDesc = sdp?.mediaDescriptionList.first else {
      return
    }

    if mediaDesc.mediaType == mediaDesc.MEDIA_TYPE_VIDEO {
      captureSession.setVideo(stream: stream as? TxStream)
    } else if mediaDesc.mediaType == mediaDesc.MEDIA_TYPE_AUDIO {
      captureSession.setAudio(stream: stream as? TxStream)
    }
  }

  private func setupRxStream(_ stream: CocoMediaSDK.Stream) {
    if !videoDecoders.contains(where: { $0.rxStreamId == stream.sourceNodeId }) {
      if videoDecoders.count == players.count {
        players.append(SampleBufferPlayer())
      }

      DispatchQueue.main.async {
        self.reattachPlayers()
      }

      let videoDecoder = LiveVideoDecoder(rxStreamId: stream.sourceNodeId, delegate: self)
      videoDecoder.angleDelegate = self
      videoDecoders.append(videoDecoder)
      audioDecoders.append(LiveAudioDecoder(rxStreamId: stream.sourceNodeId, delegate: self))
    }
  }

  private func stopStream(_ stream: CocoMediaSDK.Stream) {
    guard let index = videoDecoders.firstIndex(where: { $0.rxStreamId == stream.sourceNodeId }) else {
      return
    }
    
    videoDecoders.removeAll(where: { $0.rxStreamId == stream.sourceNodeId })
    audioDecoders.removeAll(where: { $0.rxStreamId == stream.sourceNodeId })
    players.remove(at: index)
    reattachPlayers()
  }

  private func reattachPlayers() {
    switch players.count {
    case 1:
      players[0].attach(view: callPreview02)
    case 2:
      players[0].attach(view: callPreview02)
      players[1].attach(view: callPreview03)
    case 3:
      players[0].attach(view: callPreview02)
      players[1].attach(view: callPreview03)
      players[2].attach(view: callPreview04)
    default:
      break
    }
  }
}
