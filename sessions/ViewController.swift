//
//  ViewController.swift
//  sessions
//
//  Created by Rohan S on 12/11/21.
//

import UIKit

class ViewController: UIViewController {
  @IBOutlet weak var btnEnableVideo: UIButton!
  @IBOutlet weak var btnEnableMicrophone: UIButton!
  @IBOutlet weak var btnEnableSpeaker: UIButton!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    self.setup()
    
  }
  
  private func setup() {
    setupButtons()
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
        debugPrint("\(sender) tapped")
      default:
        break
    }
  }
}

