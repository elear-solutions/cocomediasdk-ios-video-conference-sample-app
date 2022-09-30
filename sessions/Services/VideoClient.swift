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

final class VideoClient {
  // MARK: Internal

  var txStream: TxStream?

  var session: AVCaptureSession {
    return captureManager.session
  }

  func startSendingVideoToServer() throws {
    try videoEncoder.configureCompressSession()

    captureManager.setVideoOutputDelegate(with: videoEncoder)

    videoEncoder.naluHandling = { [weak self] data, pts in
      self?.sendFrame(data: data, pts: pts)
    }
  }

  func restartSession() {
    captureManager.startSessionIfPossible()
  }

  func stopSession() {
    captureManager.stopSession()
  }

  // MARK: Private

  // MARK: - Dependencies

  private lazy var captureManager = VideoCaptureManager()
  private lazy var videoEncoder = LiveVideoEncoder()
  private var index = 0

  private func sendFrame(data: Data, pts: Int) {
    guard let stream = txStream, txStream?.status == .COCO_MEDIA_CLIENT_STREAM_CREATED else {
      debugPrint("Error while sending a frame: \(txStream?.status ?? .COCO_MEDIA_CLIENT_STREAM_CREATED)")
      return
    }

    let packedFrame = PackedFrame(index: index,
                                  mime: .COCO_MEDIA_CLIENT_MIME_TYPE_VIDEO_H264,
                                  type: .COCO_MEDIA_CLIENT_FRAME_TYPE_KEY,
                                  duration: captureManager.frameRate,
                                  time: pts,
                                  data: data,
                                  size: data.count)

    try? stream.send(packedFrame)

    index += 1
  }
}
