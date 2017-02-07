//
//  GameScene+UserInput.swift
//  Maeve
//
//  Created by Mac on 2017-02-07.
//  Copyright © 2017 Paddy Crab Games. All rights reserved.
//

import Foundation
import SpriteKit

extension GameScene {
  func addSwipeGestureRecognizers(view: UIView) {
    let swipeRight:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipedRight(sender:)))
    swipeRight.direction = .right
    view.addGestureRecognizer(swipeRight)
    
    let swipeLeft:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipedLeft(sender:)))
    swipeLeft.direction = .left
    view.addGestureRecognizer(swipeLeft)
    
    let swipeUp:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipedUp(sender:)))
    swipeUp.direction = .up
    view.addGestureRecognizer(swipeUp)
    
    let swipeDown:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipedDown(sender:)))
    swipeDown.direction = .down
    view.addGestureRecognizer(swipeDown)
  }
  
  func swipedRight(sender:UISwipeGestureRecognizer) {
    swipedInDirection(direction: .right)
  }
  
  func swipedLeft(sender:UISwipeGestureRecognizer) {
    swipedInDirection(direction: .left)
  }
  
  func swipedUp(sender:UISwipeGestureRecognizer) {
    swipedInDirection(direction: .up)
  }
  
  func swipedDown(sender:UISwipeGestureRecognizer) {
    swipedInDirection(direction: .down)
  }
}
