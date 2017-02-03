//
//  GameViewController.swift
//  Maeve
//
//  Created by Mac on 2017-02-01.
//  Copyright © 2017 Paddy Crab Games. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
          
          let scene = MenuScene(size: view.bounds.size)
          scene.scaleMode = .aspectFill
          view.presentScene(scene)
          view.ignoresSiblingOrder = true
          
          view.showsFPS = true
          view.showsNodeCount = true
        }
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
