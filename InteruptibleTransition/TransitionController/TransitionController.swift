//
//  TransitionController.swift
//  InteruptibleTransition
//
//  Created by Harry Cao on 29/7/17.
//  Copyright © 2017 Harry Cao. All rights reserved.
//

import UIKit

let customTransitionDuration: TimeInterval = 3.0

class TransitionController: NSObject {
  weak var navigationController: UINavigationController?
  var operation: UINavigationControllerOperation = .none
  var transitionDriver: TransitionDriver?
  var initiallyInteractive = false
  var panGestureRecognizer: UIPanGestureRecognizer = UIPanGestureRecognizer()
  
  init(_ navigationController: UINavigationController) {
    super.init()
    
    self.navigationController = navigationController
    navigationController.delegate = self
    
    configurePanGestureRecognizer()
  }
  
  func configurePanGestureRecognizer() {
    panGestureRecognizer.delegate = self
    panGestureRecognizer.maximumNumberOfTouches = 1
    panGestureRecognizer.addTarget(self, action: #selector(initiateTransitionInteractively(_:)))
    navigationController?.view.addGestureRecognizer(panGestureRecognizer)
    
    guard let interactivePopGestureRecognizer = navigationController?.interactivePopGestureRecognizer else { return }
    panGestureRecognizer.require(toFail: interactivePopGestureRecognizer)
  }
  
  @objc func initiateTransitionInteractively(_ panGesture: UIPanGestureRecognizer) {
    if panGesture.state == .began && transitionDriver == nil {
      initiallyInteractive = true
      let _ = navigationController?.popViewController(animated: true)
    }
  }
}




extension TransitionController: UIGestureRecognizerDelegate {
  func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    return true
  }
  
  func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
    guard let transitionDriver = self.transitionDriver else {
      let translation = panGestureRecognizer.translation(in: panGestureRecognizer.view)
//      let translationIsVertical = (translation.y > 0) && (abs(translation.y) > abs(translation.x))
      let translationIsVertical = abs(translation.y) > abs(translation.x)
      return translationIsVertical && (navigationController?.viewControllers.count ?? 0 > 1)
    }
    
    return transitionDriver.isInteractive
  }
}




extension TransitionController: UINavigationControllerDelegate {
  func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    
    self.operation = operation
    
    return self
  }
  
  func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
    return self
  }
}




extension TransitionController: UIViewControllerAnimatedTransitioning {
  func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
    return customTransitionDuration
  }
  
  func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
    // Will be ignored
  }
  
  func animationEnded(_ transitionCompleted: Bool) {
    // Clean up our helper object and any additional state
    transitionDriver = nil
    initiallyInteractive = false
    operation = .none
  }
  
  func interruptibleAnimator(using transitionContext: UIViewControllerContextTransitioning) -> UIViewImplicitlyAnimating {
    return (transitionDriver?.transitionAnimator)!
  }
}



extension TransitionController: UIViewControllerInteractiveTransitioning {
  func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
    transitionDriver = TransitionDriver(operation: operation, transitionContext: transitionContext, panGestureRecognizer: panGestureRecognizer)
  }
  
  var wantsInteractiveStart: Bool {
    return self.initiallyInteractive
  }
}
