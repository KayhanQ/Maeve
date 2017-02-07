//
//  MenuScene.swift
//  Maeve
//
//  Created by Mac on 2017-02-03.
//  Copyright © 2017 Paddy Crab Games. All rights reserved.
//

import Foundation
import SpriteKit

class MenuScene: SKScene {
  
  let levels = ["Level1", "Level-1"]
  
  override func didMove(to view: SKView) {
    //scene?.backgroundColor = UIColor.lightGray
    addButtons()
  }
  
  private func addButtons() {
    let x: CGFloat = (self.view?.frame.width)! / 2
    var y: CGFloat = (self.view?.frame.height)! - 100
    for level in levels {
      let label = SKLabelNode(text: level)
      label.fontName = "AvenirNext-Bold"
      label.color = UIColor.darkText
      label.position = CGPoint(x: x, y: y)
      label.fontSize = 20
      label.name = level

      self.addChild(label)
      y -= 40
    }
  }
  
  private func startGame() {
    let gameScene = GameScene(size: view!.bounds.size)
    let transition = SKTransition.fade(withDuration: 0.15)
    view!.presentScene(gameScene, transition: transition)
  }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    if let touch = touches.first {
      let pos = touch.location(in: self)
      let node = self.atPoint(pos)
      
      guard let levelName = node.name else {
        return
      }
      
      guard let view = self.view else {
        return
      }
      
      if let scene = GameScene(fileNamed: levelName) {
        // scene.scaleMode = .aspectFill
        // Present the scene
        view.presentScene(scene)
      }
      view.ignoresSiblingOrder = true
      view.showsFPS = true
      view.showsNodeCount = true
      
//      let transition:SKTransition = SKTransition.fade(withDuration: 1)
//      let scene:SKScene = GameScene(size: self.size)
//      self.view?.presentScene(scene, transition: transition)
    }
  }
}
