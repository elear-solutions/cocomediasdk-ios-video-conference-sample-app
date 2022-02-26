//
//  AudioRecordingService.swift
//  sessions
//
//  Created by Rohan S on 18/02/22.
//

import AVFoundation
import CocoMediaPlayer
import Foundation
import OSLog

protocol AudioRecordingServiceDelegate: AnyObject {
  func didProcess(data: Data)
}

class AudioRecordingService {
  // MARK: Lifecycle

  init() {
    audioEngine = .init()
    audioSession = .sharedInstance()
    try? audioSession.setPreferredIOBufferDuration(IO_BUFFER_DURATION)
  }

  // MARK: Internal

  var audioEngine: AVAudioEngine
  var audioSession: AVAudioSession

  weak var delegate: AudioRecordingServiceDelegate?

  func start() {
    os_log("%s started", log: logger, type: .debug, #function)
    let mic = AVCaptureDevice.default(.builtInMicrophone,
                                      for: .audio, position: .unspecified)
    let sampleRate = audioEngine.inputNode.outputFormat(forBus: 0).sampleRate
    let format = AVAudioFormat(commonFormat: AVAudioCommonFormat.pcmFormatInt16,
                               sampleRate: sampleRate,
                               channels: CHANNELS,
                               interleaved: false)
    audioEngine.inputNode.removeTap(onBus: 0)
    audioEngine.inputNode.installTap(onBus: 0,
                                     bufferSize: AVAudioFrameCount(sampleRate),
                                     format: format,
                                     block: { buffer, when in
                                       debugPrint("[DBG] \(#function) buffer: \(buffer)")
                                       debugPrint("[DBG] \(#function) when: \(when)")
                                     })

    do {
      try audioEngine.start()
    } catch {
      os_log("%s failed: %s ", log: logger, type: .error,
             #function, error.localizedDescription)
    }
    os_log("%s completed", log: logger, type: .debug, #function)
  }

  func stop() {
    audioEngine.stop()
    audioEngine.inputNode.removeTap(onBus: 0)
  }

  // MARK: Private

  private var BUFFER_SIZE = 160
  private var SAMPLE_RATE = 8000.0
  private var IO_BUFFER_DURATION: TimeInterval = 0.4
  private var CHANNELS: UInt32 = 1

  private let logger = OSLog(AudioRecordingService.self)

  private func isGrantedPermission() -> Bool {
    switch audioSession.recordPermission {
    case AVAudioSession.RecordPermission.granted:
      return true
    default:
      return false
    }
  }

  private func linear2alaw(buffer: AVAudioPCMBuffer) {
    os_log("%s started", log: logger, type: .error, #function)

    let inputFormat = audioEngine.inputNode.outputFormat(forBus: 0)
    let outputFormat = AudioMediaFrame.ALawFormatHelper()
    let converter = AVAudioConverter(from: inputFormat, to: outputFormat)
    let frameCount = AVAudioFrameCount(
      outputFormat.sampleRate * IO_BUFFER_DURATION
    )
    let newbuffer = AVAudioPCMBuffer(pcmFormat: outputFormat,
                                     frameCapacity: frameCount)!

    let inputBlock: AVAudioConverterInputBlock = { _, outStatus -> AVAudioBuffer? in
      outStatus.pointee = AVAudioConverterInputStatus.haveData
      let audioBuffer: AVAudioBuffer = buffer
      return audioBuffer
    }

    var error: NSError?

    converter?.convert(to: newbuffer,
                       error: &error,
                       withInputFrom: inputBlock)

    let audioData = newbuffer.audioBufferList.pointee.mBuffers
    if let mData = audioData.mData {
      let length = Int(audioData.mDataByteSize)
      let data = Data(bytes: mData, count: length)
      os_log("%s data: %d bytes", log: logger, type: .debug,
             #function, length)
      delegate?.didProcess(data: data)
    }

    os_log("%s completed", log: logger, type: .debug, #function)
  }
}
