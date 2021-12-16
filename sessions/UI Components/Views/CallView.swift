//
//  CallView.swift
//  sessions
//
//  Created by Rohan S on 15/12/21.
//

import Foundation
import UIKit

class CallView: UIView {
  @IBOutlet weak var callerPreview: PreviewView!
  @IBOutlet weak var callPreview02: UIView!
  @IBOutlet weak var callPreview03: UIView!
  @IBOutlet weak var callPreview04: UIView!
  
  @IBOutlet weak var btnToggleCamera: UIButton!
  @IBOutlet weak var btnToggleVideo: UIButton!
  @IBOutlet weak var btnEndCall: UIButton!
  @IBOutlet weak var btnToggleMicrophone: UIButton!
  @IBOutlet weak var btnToggleSpeaker: UIButton!
  
  @IBAction private func didTouchUpInside(_ sender: UIButton) {
    
  }
  
}
