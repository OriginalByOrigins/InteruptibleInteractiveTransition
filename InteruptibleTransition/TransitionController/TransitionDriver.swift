//
//  TransitionDriver.swift
//  InteruptibleTransition
//
//  Created by Harry Cao on 29/7/17.
//  Copyright © 2017 Harry Cao. All rights reserved.
//

import UIKit

class TransitionDriver: NSObject {
  
  var transitionAnimator: UIViewPropertyAnimator!
  let transitionContext: UIViewControllerContextTransitioning
  var isInteractive: Bool { return transitionContext.isInteractive }
  
  private var operation: UINavigationControllerOperation
  private var panGestureRecognizer: UIPanGestureRecognizer
  
  private var itemView: UIImageView!
  private var itemAnimator: UIViewPropertyAnimator!
  private var initialFrame: CGRect!
  private var finalFrame: CGRect!
  
  init(operation: UINavigationControllerOperation, transitionContext: UIViewControllerContextTransitioning, panGestureRecognizer: UIPanGestureRecognizer) {
    self.operation = operation
    self.transitionContext = transitionContext
    self.panGestureRecognizer = panGestureRecognizer
    
    super.init()
    
    // Setup the transition "chrome"
    let fromViewController = transitionContext.viewController(forKey: .from)!
    let toViewController = transitionContext.viewController(forKey: .to)!
    let fromView = fromViewController.view!
    let toView = toViewController.view!
    let containerView = transitionContext.containerView
    
    // Add ourselves as a target of the pan gesture
    self.panGestureRecognizer.addTarget(self, action: #selector(updateInteraction(_:)))
    
    // Insert the toViewController's view into the transition container view
    let topView: UIView
    var topViewTargetAlpha: CGFloat = 0.0
    if operation == .push {
      topView = toView
      topViewTargetAlpha = 1.0
      toView.alpha = 0.0
      containerView.addSubview(toView)
    } else {
      topView = fromView
      topViewTargetAlpha = 0.0
      containerView.insertSubview(toView, at: 0)
    }
    
    let masterFrame = CGRect(x: 100, y: 200, width: 300, height: 300)
    let slaveFrame = CGRect(x: 0, y: 150, width: 834.0, height: 834.0)
    self.initialFrame = operation == .push ? masterFrame : slaveFrame
    self.finalFrame = operation == .pop ? masterFrame : slaveFrame
    
    let itemView = UIImageView(image: #imageLiteral(resourceName: "starboy"))
    itemView.frame = self.initialFrame
    itemView.isUserInteractionEnabled = true
    let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(press(_ :)))
    longPressGestureRecognizer.minimumPressDuration = 0.0
    itemView.addGestureRecognizer(longPressGestureRecognizer)
    self.itemView = itemView
    containerView.addSubview(self.itemView)
    
    (fromViewController as? MasterViewController)?.imageView.alpha = 0.0
    (fromViewController as? SlaveViewController)?.imageView.alpha = 0.0
    (toViewController as? MasterViewController)?.imageView.alpha = 0.0
    (toViewController as? SlaveViewController)?.imageView.alpha = 0.0
    
    transitionAnimator = UIViewPropertyAnimator(duration: customTransitionDuration, timingParameters: UICubicTimingParameters(animationCurve: .linear))
    transitionAnimator.addAnimations {
      topView.alpha = topViewTargetAlpha
    }
    transitionAnimator.addCompletion { position in
      
      (fromViewController as? MasterViewController)?.imageView.alpha = 1.0
      (fromViewController as? SlaveViewController)?.imageView.alpha = 1.0
      (toViewController as? MasterViewController)?.imageView.alpha = 1.0
      (toViewController as? SlaveViewController)?.imageView.alpha = 1.0
      
      self.itemView?.removeFromSuperview()
      
      let completed = (position == .end)
      transitionContext.completeTransition(completed)
    }
    
    if !transitionContext.isInteractive {
      animate(to: .end)
    }
  }
  
  
  
  
  
  
  
  
  
  private func progressStepFor(translation: CGPoint) -> CGFloat {
    return (operation == .push ? -1.0 : 1.0) * translation.y / transitionContext.containerView.bounds.midY
  }
  
  private func completionPosition() -> UIViewAnimatingPosition {
    let completionThreshold: CGFloat = 0.33
    let flickMagnitude: CGFloat = 1200 //pts/sec
    let velocity = panGestureRecognizer.velocity(in: transitionContext.containerView).vector
    let isFlick = (velocity.magnitude > flickMagnitude)
    let isFlickDown = isFlick && (velocity.dy > 0.0)
    let isFlickUp = isFlick && (velocity.dy < 0.0)
    
    if (operation == .push && isFlickUp) || (operation == .pop && isFlickDown) {
      return .end
    } else if (operation == .push && isFlickDown) || (operation == .pop && isFlickUp) {
      return .start
    } else if transitionAnimator.fractionComplete > completionThreshold {
      return .end
    } else {
      return .start
    }
  }
  
  
  
  
  
  
  
  
  @objc func press(_ longPressGesture: UILongPressGestureRecognizer) {
    switch longPressGesture.state {
    case .began:
      pauseAnimation()
//      updateInteractiveItemFor(longPressGesture.location(in: transitionContext.containerView))
    case .ended, .cancelled:
      endInteraction()
    default: break
    }
  }
  
  private func updateItemsForInteractive(translation: CGPoint) {
//    let progressStep = progressStepFor(translation: translation)
//    for item in items {
//      let initialSize = item.initialFrame.size
//      if let imageView = item.imageView, let finalSize = item.targetFrame?.size {
//        let currentSize = imageView.frame.size
//
//        let itemPercentComplete = clip(-0.05, 1.05, (currentSize.width - initialSize.width) / (finalSize.width - initialSize.width) + progressStep)
//        let itemWidth = lerp(initialSize.width, finalSize.width, itemPercentComplete)
//        let itemHeight = lerp(initialSize.height, finalSize.height, itemPercentComplete)
//        let scaleTransform = CGAffineTransform(scaleX: (itemWidth / currentSize.width), y: (itemHeight / currentSize.height))
//        let scaledOffset = item.touchOffset.apply(transform: scaleTransform)
//
//        imageView.center = (imageView.center + (translation + (item.touchOffset - scaledOffset))).point
//        imageView.bounds = CGRect(origin: CGPoint.zero, size: CGSize(width: itemWidth, height: itemHeight))
//        item.touchOffset = scaledOffset
//      }
//    }
    
    itemView.center = CGPoint(x: itemView.center.x, y: itemView.center.y + translation.y)
  }
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  @objc func updateInteraction(_ panGesture: UIPanGestureRecognizer) {
    switch panGesture.state {
    case .began, .changed:
      // Ask the gesture recognizer for it's translation
      let translation = panGesture.translation(in: transitionContext.containerView)
      
      // Calculate the percent complete
      let percentComplete = transitionAnimator.fractionComplete + progressStepFor(translation: translation)
      
      // transitionAnimor setup at line 104, animate the top frame to the wanted frame
      // Update the transition animator's fractionCompete to scrub it's animations
      transitionAnimator.fractionComplete = percentComplete
      
      // Inform the transition context of the updated percent complete
      transitionContext.updateInteractiveTransition(percentComplete)
      
      // Update each transition item for the
      updateItemsForInteractive(translation: translation)
      
      // Reset the gestures translation
      panGesture.setTranslation(CGPoint.zero, in: transitionContext.containerView)
    case .ended, .cancelled:
      // End the interactive phase of the transition
      endInteraction()
    default: break
    }
  }
  
  func endInteraction() {
    // Ensure the context is currently interactive
    guard transitionContext.isInteractive else { return }
    
    // Inform the transition context of whether we are finishing or cancelling the transition
    let completionPosition = self.completionPosition()
    if completionPosition == .end {
      transitionContext.finishInteractiveTransition()
    } else {
      transitionContext.cancelInteractiveTransition()
    }
    
    // Begin the animation phase of the transition to either the start or finsh position
    animate(to: completionPosition)
  }
  
  func animate(to position: UIViewAnimatingPosition) {
    // Create a property animator to animate each image's frame change
//    let itemAnimator = TransitionDriver.propertyAnimator(initialVelocity: timingCurveVelocity())
    let itemAnimator = UIViewPropertyAnimator(duration: customTransitionDuration, timingParameters: UICubicTimingParameters(animationCurve: .linear))
    itemAnimator.addAnimations {
      self.itemView.frame = position == .end ? self.finalFrame : self.initialFrame
    }
    
    // Start the property animator and keep track of it
    itemAnimator.startAnimation()
    self.itemAnimator = itemAnimator
    
    // Reverse the transition animator if we are returning to the start position
    transitionAnimator.isReversed = (position == .start)
    
    // Start or continue the transition animator (if it was previously paused)
    if transitionAnimator.state == .inactive {
      transitionAnimator.startAnimation()
    } else {
      // Calculate the duration factor for which to continue the animation.
      // This has been chosen to match the duration of the property animator created above
      let durationFactor = CGFloat(itemAnimator.duration / transitionAnimator.duration)
      transitionAnimator.continueAnimation(withTimingParameters: nil, durationFactor: durationFactor)
    }
  }
  
  
  func pauseAnimation() {
    // Stop (without finishing) the property animator used for transition item frame changes
    itemAnimator.stopAnimation(true)
    
    // Pause the transition animator
    transitionAnimator.pauseAnimation()
    
    // Inform the transition context that we have paused
    transitionContext.pauseInteractiveTransition()
  }
  
  
  
  
  
//  private func convert(_ velocity: CGPoint, for item: UIImageView?) -> CGVector {
//    guard let currentFrame = item?.frame, let targetFrame = finalFrame else {
//      return CGVector.zero
//    }
//
//    let dx = abs(targetFrame.midX - currentFrame.midX)
//    let dy = abs(targetFrame.midY - currentFrame.midY)
//
//    guard dx > 0.0 && dy > 0.0 else {
//      return CGVector.zero
//    }
//
//    let range = CGFloat(35.0)
//    let clippedVx = clip(-range, range, velocity.x / dx)
//    let clippedVy = clip(-range, range, velocity.y / dy)
//    return CGVector(dx: clippedVx, dy: clippedVy)
//  }
//
//  private func timingCurveVelocity() -> CGVector {
//    // Convert the gesture recognizer's velocity into the initial velocity for the animation curve
//    let gestureVelocity = panGestureRecognizer.velocity(in: transitionContext.containerView)
//    return convert(gestureVelocity, for: itemView)
//  }
  
  
  
  // MARK: Interesting Property Animator Stuff
  
//  class func animationDuration() -> TimeInterval {
//    return TransitionDriver.propertyAnimator().duration
//  }
//
//  class func propertyAnimator(initialVelocity: CGVector = .zero) -> UIViewPropertyAnimator {
//    let timingParameters = UISpringTimingParameters(mass: 4.5, stiffness: 1300, damping: 95, initialVelocity: initialVelocity)
//    return UIViewPropertyAnimator(duration: customTransitionDuration, timingParameters:timingParameters)
//  }
}








extension CGPoint {
  var vector: CGVector {
    return CGVector(dx: x, dy: y)
  }
}

extension CGVector {
  var magnitude: CGFloat {
    return sqrt(dx*dx + dy*dy)
  }
}

//func clip<T : Comparable>(_ x0: T, _ x1: T, _ v: T) -> T {
//  return max(x0, min(x1, v))
//}

