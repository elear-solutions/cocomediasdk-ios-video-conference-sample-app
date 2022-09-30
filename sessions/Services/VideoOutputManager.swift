//
//  VideoOutputManager.swift
//  sessions
//
//  Created by Vladyslav Danyliak on 27.09.2022.
//

import AVFoundation
import Foundation

final class VideoCaptureManager {
  // MARK: Lifecycle

  // MARK: - Init

  init() {
    sessionQueue.async {
      self.requestCameraAuthorizationIfNeeded()
    }

    sessionQueue.async {
      self.configureSession()
    }

    startSessionIfPossible()
  }

  // MARK: Internal

  // MARK: - Dependencies

  let session = AVCaptureSession()
  private(set) var frameRate = 0

  // MARK: - Delegate

  func setVideoOutputDelegate(with delegate: AVCaptureVideoDataOutputSampleBufferDelegate) {
    videoOutput.setSampleBufferDelegate(delegate, queue: videoOutputQueue)
  }

  func startSessionIfPossible() {
    sessionQueue.async {
      switch self.setupResult {
      case .success:
        self.session.startRunning()
      case .notAuthorized:
        debugPrint("Camera usage not authorized")
      case .configurationFailed:
        debugPrint("Configuration failed")
      }
    }
  }

  func stopSession() {
    sessionQueue.async {
      self.session.stopRunning()
    }
  }

  // MARK: Private

  private enum SessionSetupResult {
    case success
    case notAuthorized
    case configurationFailed
  }

  private enum ConfigurationError: Error {
    case cannotAddInput
    case cannotAddOutput
    case defaultDeviceNotExist
    case cannotSetMaxFrameRate
  }

  private let videoOutput = AVCaptureVideoDataOutput()

  // MARK: - DispatchQueues

  private let sessionQueue = DispatchQueue(label: "session.queue")
  private let videoOutputQueue = DispatchQueue(label: "video.output.queue")

  private var setupResult: SessionSetupResult = .success

  // MARK: - Session

  private func requestCameraAuthorizationIfNeeded() {
    switch AVCaptureDevice.authorizationStatus(for: .video) {
    case .authorized:
      break
    case .notDetermined:
      sessionQueue.suspend()
      AVCaptureDevice.requestAccess(for: .video, completionHandler: { granted in
        if !granted {
          self.setupResult = .notAuthorized
        }
        self.sessionQueue.resume()
      })
    default:
      setupResult = .notAuthorized
    }
  }

  private func addVideoDeviceInputToSession() throws {
    do {
      var defaultVideoDevice: AVCaptureDevice?

      if let frontCameraDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) {
        defaultVideoDevice = frontCameraDevice
      } else if let dualCameraDevice = AVCaptureDevice.default(.builtInDualCamera, for: .video, position: .back) {
        defaultVideoDevice = dualCameraDevice
      } else if let dualWideCameraDevice = AVCaptureDevice.default(.builtInDualWideCamera, for: .video, position: .back) {
        defaultVideoDevice = dualWideCameraDevice
      } else if let backCameraDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
        defaultVideoDevice = backCameraDevice
      }

      guard let videoDevice = defaultVideoDevice else {
        debugPrint("Default video device is unavailable.")
        setupResult = .configurationFailed
        session.commitConfiguration()

        throw ConfigurationError.defaultDeviceNotExist
      }

      let videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)

      if session.canAddInput(videoDeviceInput) {
        session.addInput(videoDeviceInput)
        try configureCameraForHighestFrameRate(device: videoDevice)
      } else {
        setupResult = .configurationFailed
        session.commitConfiguration()

        throw ConfigurationError.cannotAddInput
      }
    } catch {
      setupResult = .configurationFailed
      session.commitConfiguration()

      throw error
    }
  }

  private func addVideoOutputToSession() throws {
    if session.canAddOutput(videoOutput) {
      session.addOutput(videoOutput)
    } else {
      setupResult = .configurationFailed
      session.commitConfiguration()

      throw ConfigurationError.cannotAddOutput
    }
  }

  private func configureSession() {
    if setupResult != .success {
      return
    }

    session.beginConfiguration()

    if session.canSetSessionPreset(.iFrame960x540) {
      session.sessionPreset = .iFrame960x540
    }

    do {
      try addVideoDeviceInputToSession()
      try addVideoOutputToSession()
    } catch {
      debugPrint("error ocurred : \(error.localizedDescription)")
      return
    }

    session.commitConfiguration()
  }

  /* Set maximum frame rate */
  private func configureCameraForHighestFrameRate(device: AVCaptureDevice) throws {
    var bestFrameRateRange: AVFrameRateRange?

    for range in device.activeFormat.videoSupportedFrameRateRanges {
      if range.maxFrameRate > bestFrameRateRange?.maxFrameRate ?? 0 {
        bestFrameRateRange = range
      }
    }

    if let bestFrameRateRange = bestFrameRateRange {
      do {
        try device.lockForConfiguration()

        let duration = bestFrameRateRange.minFrameDuration
        device.activeVideoMinFrameDuration = duration
        device.activeVideoMaxFrameDuration = duration
        frameRate = Int(duration.timescale)

        device.unlockForConfiguration()
      } catch {
        debugPrint("error ocurred : \(error.localizedDescription)")
        throw ConfigurationError.cannotSetMaxFrameRate
      }
    }
  }
}
