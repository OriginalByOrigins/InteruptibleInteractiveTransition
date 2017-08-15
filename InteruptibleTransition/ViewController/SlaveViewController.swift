//
//  SlaveViewController.swift
//  InteruptibleTransition
//
//  Created by Harry Cao on 29/7/17.
//  Copyright © 2017 Harry Cao. All rights reserved.
//

import UIKit

class SlaveViewController: UIViewController {
  let imageView: UIImageView = {
    let imageView = UIImageView()
    imageView.contentMode = .scaleAspectFill
    imageView.isUserInteractionEnabled = true
    imageView.image = #imageLiteral(resourceName: "starboy")
    return imageView
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.view.backgroundColor = .white
    
    self.view.addSubview(imageView)
    imageView.frame = CGRect(x: 0, y: 150, width: 834.0, height: 834.0)
  }
}

