//
//  MasterViewController.swift
//  InteruptibleTransition
//
//  Created by Harry Cao on 29/7/17.
//  Copyright © 2017 Harry Cao. All rights reserved.
//

import UIKit

class MasterViewController: UIViewController {

  let imageView: UIImageView = {
    let imageView = UIImageView()
    imageView.contentMode = .scaleAspectFill
    imageView.isUserInteractionEnabled = true
    imageView.image = #imageLiteral(resourceName: "starboy")
    return imageView
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.navigationItem.title = "Starboy"
    self.view.backgroundColor = .white
    
    self.view.addSubview(imageView)
    imageView.frame = CGRect(x: 100, y: 200, width: 300, height: 300)
    
    imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
    //    imageView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handlePan)))
  }
  
  @objc func handleTap(_ gesture: UITapGestureRecognizer) {
    let slaveVC = SlaveViewController()
    self.navigationController?.pushViewController(slaveVC, animated: true)
  }
  
  /*
   @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
   switch gesture.state {
   case .began:
   let slaveVC = SlaveViewController()
   self.navigationController?.pushViewController(slaveVC, animated: true)
   default:
   break
   }
   }*/
}

