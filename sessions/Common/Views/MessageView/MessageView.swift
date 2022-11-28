//
//  MessageView.swift
//  sessions
//
//  Created by Vladyslav Danyliak on 28.11.2022.
//

import UIKit

final class MessageView: UIView {
  // MARK: Lifecycle

  override init(frame: CGRect) {
    super.init(frame: frame)
    initialize()
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    initialize()
  }

  // MARK: Internal

  override func layoutSubviews() {
    super.layoutSubviews()
    containerView.layer.cornerRadius = 16
  }

  func show(message: String, node: Int, on view: UIView) {
    let modifiedText = "\(node): \(message)"
    label.text = modifiedText

    addToView(message: modifiedText, on: view)

    UIView.animate(withDuration: 0.3) {
      self.containerView.alpha = 1
    }

    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
      UIView.animate(withDuration: 0.3) {
        self.containerView.alpha = 0
      } completion: { _ in
        self.removeFromSuperview()
      }
    }
  }

  // MARK: Private

  @IBOutlet private var containerView: UIView!
  @IBOutlet private var containerWidth: NSLayoutConstraint!
  @IBOutlet private var label: UILabel!

  private func initialize() {
    addSelfNibUsingConstraints()
    isUserInteractionEnabled = false
    containerView.alpha = 0
    backgroundColor = .clear
  }

  private func addToView(message: String, on view: UIView) {
    view.addSubviewUsingConstraints(view: self)
    let maxWidth = view.bounds.width - 56
    let textWidth = min(message.width(withConstrainedHeight: 48, font: UIFont.systemFont(ofSize: 17)) + 24, maxWidth)

    containerWidth.constant = textWidth
    layoutIfNeeded()
  }
}
