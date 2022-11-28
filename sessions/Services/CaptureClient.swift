//
//  VideoClient.swift
//  sessions
//
//  Created by Vladyslav Danyliak on 27.09.2022.
//

import AVFoundation
import CocoMediaPlayer
import CocoMediaSDK
import Foundation

final class CaptureClient {
  // MARK: Internal

  private(set) var videoTxStream: TxStream?
  private(set) var audioTxStream: TxStream?
  var isMuted = false

  var session: AVCaptureSession {
    return captureManager.session
  }

  func startSendingVideoToServer() throws {
    try videoEncoder.configureCompressSession()

    captureManager.setVideoOutputDelegate(with: videoEncoder)
    captureManager.setAudioOutputDelegate(with: audioEncoder)

    videoEncoder.naluHandling = { [weak self] data, pts in
      self?.sendVideoFrame(data: data, pts: pts)
    }
    audioEncoder.naluHandling = { [weak self] data, pts in
      self?.sendAudioFrame(data: data, pts: pts)
    }
  }

  func setVideo(stream: TxStream?) {
    videoTxStream = stream
  }

  func setAudio(stream: TxStream?) {
    audioTxStream = stream
  }

  func changeCamera() {
    switch cameraPosition {
    case .back:
      cameraPosition = .front
    case .front:
      cameraPosition = .back
    default:
      break
    }
    enableCamera()
  }

  func disableCamera() {
    captureManager.disableCamera()
  }

  func enableCamera() {
    captureManager.enableCamera(position: cameraPosition)
  }

  func restartSession() {
    captureManager.startSessionIfPossible()
  }

  func stopSession() {
    captureManager.stopSession()
  }

  // MARK: Private

  // MARK: - Dependencies

  private lazy var captureManager = CaptureManager()
  private lazy var videoEncoder = LiveVideoEncoder()
  private lazy var audioEncoder = LiveAudioEncoder()
  private var videoIndex = 0
  private var audioIndex = 0
  private var cameraPosition = AVCaptureDevice.Position.front

  private func sendVideoFrame(data: Data, pts: Int) {
    guard let stream = videoTxStream, videoTxStream?.status == .COCO_MEDIA_CLIENT_STREAM_CREATED else {
//      debugPrint("Error while sending a frame: \(videoTxStream?.status ?? .COCO_MEDIA_CLIENT_STREAM_CREATED)")
      return
    }

    let packedFrame = PackedFrame(index: videoIndex,
                                  mime: .COCO_MEDIA_CLIENT_MIME_TYPE_VIDEO_H264,
                                  type: .COCO_MEDIA_CLIENT_FRAME_TYPE_KEY,
                                  duration: captureManager.frameRate,
                                  time: pts,
                                  data: data,
                                  size: data.count)

    try? stream.send(packedFrame)

    videoIndex += 1
  }

  private func sendAudioFrame(data: Data, pts: Int) {
    guard let stream = audioTxStream, audioTxStream?.status == .COCO_MEDIA_CLIENT_STREAM_CREATED, !isMuted else {
//      debugPrint("Error while sending a frame: \(audioTxStream?.status ?? .COCO_MEDIA_CLIENT_STREAM_CREATED)")
      return
    }
    let packedFrame = PackedFrame(index: audioIndex,
                                  mime: .COCO_MEDIA_CLIENT_MIME_TYPE_AUDIO_AAC,
                                  type: .COCO_MEDIA_CLIENT_FRAME_TYPE_KEY,
                                  duration: 0,
                                  time: pts,
                                  data: data,
                                  size: data.count)
    try? stream.send(packedFrame)
    audioIndex += 1
  }
}
