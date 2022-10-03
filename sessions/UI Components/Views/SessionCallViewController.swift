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
import VideoToolbox

class SessionCallViewController: UIViewController {
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

  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    videoClient.stopSession()
    do {
      debugPrint("[DBG] \(#file) -> \(#function) disconnecting: \(selectedNetwork!)")
      try selectedNetwork?.disconnect()
    } catch {
      debugPrint("[DBG] \(#file) -> \(#function) \(#function) error: \(error.localizedDescription)")
    }
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    setupRemoteView()
  }

  // MARK: Internal

  static let identifier = String(describing: SessionCallViewController.self)

  @IBOutlet var callerPreview: PreviewView! // blue
  @IBOutlet var callPreview02: UIView! // yellow
  @IBOutlet var callPreview03: UIView! // green
  @IBOutlet var callPreview04: UIView! // red

  @IBOutlet var btnToggleCamera: UIButton!
  @IBOutlet var btnToggleVideo: UIButton!
  @IBOutlet var btnEndCall: UIButton!
  @IBOutlet var btnToggleMicrophone: UIButton!
  @IBOutlet var btnToggleSpeaker: UIButton!

  var selectedNetwork: Network?

  // MARK: Private

  private var videoClient = VideoClient()

  private var players: [SampleBufferPlayer] = [SampleBufferPlayer(), SampleBufferPlayer(), SampleBufferPlayer()]
  private var videoDecoders: [LiveVideoDecoder] = [LiveVideoDecoder(), LiveVideoDecoder(), LiveVideoDecoder()]
  private var audioDecoders: [LiveAudioDecoder] = [LiveAudioDecoder(AudioMediaFrame.AmrWbFormatHelper(sampleRate: 16000)),
                                                   LiveAudioDecoder(AudioMediaFrame.AmrWbFormatHelper(sampleRate: 16000)),
                                                   LiveAudioDecoder(AudioMediaFrame.AmrWbFormatHelper(sampleRate: 16000))]

  private var basetime: Int?
  private var frameRate = 30
  private var videoIndex = 0
  private var newVideoIndex = 0

  private var videoTxStream: TxStream?
  private var someFrame = PackedFrame()

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
      sender.isSelected ? videoClient.restartSession() : videoClient.stopSession()
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

  private func setupRemoteView() {
    players[0].attach(view: callPreview02) // yellow
    players[1].attach(view: callPreview03) // green
    players[2].attach(view: callPreview04) // red
  }

  private func setupLocalAudioFeed() {
    let avAudioSession = AVAudioSession.sharedInstance()
    do {
      try avAudioSession.setCategory(.playAndRecord,
                                     mode: .videoChat,
                                     options: [.defaultToSpeaker, .allowBluetooth])
      AudioRecordingService().start()
    } catch {
      debugPrint(error.localizedDescription)
    }
  }

  private func setupVideoClient() {
    do {
      try videoClient.startSendingVideoToServer()
      callerPreview.session = videoClient.session
    } catch {
      debugPrint("error video client: \(error.localizedDescription)")
    }
  }

  private func setup() {
    setupToggleCameraButton()
    setupToggleVideoButton()
    setupEndCallButton()
    setupToggleMicrophoneButton()
    setupToggleSpeakerButton()
    setupVideoClient()
    setupLocalAudioFeed()
  }

  // MARK: - Helpers

  private func generateVideoDesc() -> String {
    let builder = SessionDescription.Builder()
    builder.origin = "coco_client 0 0 IN IP4 0.0.0.0"
    builder.sessionName = "coco media_sessions"
    builder.timing = "0 0"
    let mediaBuilder = MediaDescription.Builder(mediaType: "video", port: 0, transportProtocol: "RTP/AVP", payloadTypes: [98])
    mediaBuilder.addRtpMapAttribute(rtpMapAttribute: RtpMapAttribute(payload: 98, mediaEncoding: "H264", clockRate: 90000, encodingParameters: 0))
    builder.addMediaDescription(mediaBuilder.build())

    let desc = SessionDescription(builder: builder)

    return SessionDescriptionParser.unParse(sessionDescription: desc)
  }
}

// MARK: - Network

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

// MARK: - Channel

extension SessionCallViewController: ChannelDelegate {
  func didReceive(_ channel: Channel, rxStream: RxStream) {
    debugPrint("[DBG] \(#function) channel: \(channel)")
    debugPrint("[DBG] \(#function) rxStream: \(rxStream)")
    if rxStream.status != .COCO_MEDIA_CLIENT_STREAM_CREATED {
      return
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
    switch to {
    case .COCO_MEDIA_CLIENT_CHANNEL_JOINED:
      let string1 = "v=0\r\no=coco_client 0 0 IN IP4 0.0.0.0\r\ns=coco media_sessions\r\nt=0 0\r\nm=video 0 RTP/AVP 98\r\na=rtpmap:98 H264/90000/0\r\na=orientation:front_camera\r\n"
      let vTxStream = try! channel.createStream(descriptor: string1, statusHandler: { status in
        switch status {
        case .COCO_MEDIA_CLIENT_STREAM_CREATED:
          debugPrint("video stream created")
        default:
          debugPrint("txStream status: \(status)")
        }
      })
      vTxStream.delegate = self
    //      let string = "v=0\r\no=coco_client 0 0 IN IP4 0.0.0.0\r\ns=coco media_sessions\r\nt=0 0\r\nm=audio 0 RTP/AVP 99\r\na=rtpmap:99 AMR-WB/16000/1\r\n"
    //      let aTxStream = try! channel.createStream(descriptor: string, statusHandler: { status in
    //        switch status {
    //        case .COCO_MEDIA_CLIENT_STREAM_CREATED:
    //          debugPrint("audio stream created")
    //        default:
    //          debugPrint(status)
    //        }
    //      })
    //      aTxStream.delegate = self
    default:
      break
    }
  }
}

// MARK: - MediaFrame

extension SessionCallViewController: LiveDecoderDelegate {
  func output(mediaFrame: MediaFrame, sender: LiveDecoder) {
    debugPrint("[DBG] \(#function) started.")
    guard let index = videoDecoders.firstIndex(where: { $0.rxStreamId == sender.rxStreamId }) else {
      debugPrint("[DBG] \(#function) No decoder with such index: \(sender)")
      return
    }
    enqueueFrame(frame: mediaFrame, index: index)
    debugPrint("[DBG] \(#function) completed.")
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
      guard let index = videoDecoders.firstIndex(where: { $0.rxStreamId == stream.sourceNodeId }) else {
        debugPrint("[DBG] No video decoder with such sourceNodeId: \(stream)")
        return
      }
      try! videoDecoders[index].feed(data: data, sampleTime: time)
    case .COCO_MEDIA_CLIENT_MIME_TYPE_AUDIO_AAC:
      let time = CMTime(seconds: ptsTime, preferredTimescale: 16000)
      guard let index = audioDecoders.firstIndex(where: { $0.rxStreamId == stream.sourceNodeId }) else {
        debugPrint("[DBG] \(#function) No audio decoder with such sourceNodeId: \(stream)")
        return
      }
      try! audioDecoders[index].feed(data: AMRAudioSwift.DecodeAMRToWAVE(data) ?? data, sampleTime: time)
    default:
      break
    }
    debugPrint("[DBG] \(#function) completed.")
  }
}

// MARK: - TxStream

extension SessionCallViewController: TxStreamDelegate {
  func didChangeStatus(_ stream: CocoMediaSDK.Stream, status from: CocoMediaSDK.Stream.Status, to: CocoMediaSDK.Stream.Status) {
    debugPrint("[DBG] \(#function) txstream: \(stream)")
    if stream is TxStream, to == .COCO_MEDIA_CLIENT_STREAM_CREATED {
      videoClient.txStream = stream as? TxStream
      videoClient.txStream?.delegate = self
    }
    if to == .COCO_MEDIA_CLIENT_STREAM_STARTED && !videoDecoders.contains(where: { $0.rxStreamId == stream.sourceNodeId }) && stream is RxStream {
      let audioDecoder = audioDecoders.first(where: { $0.rxStreamId == nil })
      let videoDecoder = videoDecoders.first(where: { $0.rxStreamId == nil })

      audioDecoder?.rxStreamId = stream.sourceNodeId
      videoDecoder?.rxStreamId = stream.sourceNodeId

      audioDecoder?.delegate = self
      videoDecoder?.delegate = self
    } else if to == .COCO_MEDIA_CLIENT_STREAM_CLOSED || to == .COCO_MEDIA_CLIENT_STREAM_DESTROYED {
      audioDecoders.first(where: { $0.rxStreamId == stream.sourceNodeId })?.rxStreamId = nil
      videoDecoders.first(where: { $0.rxStreamId == stream.sourceNodeId })?.rxStreamId = nil
    }
    debugPrint("[DBG] \(#function) status: \(to)")
  }
}
