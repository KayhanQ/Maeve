//
//  GameScene.swift
//  Maeve
//
//  Created by Mac on 2017-02-01.
//  Copyright © 2017 Paddy Crab Games. All rights reserved.
//

import SpriteKit
import GameplayKit

enum direction: Int {
  case up, right, down, left
}

enum playerState {
  case idle, moving
}

struct Tile {
  let tileType: tileType
  var tileStops: tileStops {
    switch tileType {
    case .rock:
      return .beside
    case .boulder:
      return .beside
    case .rough:
      return .onTopOf
    case .finish:
      return .onTopOf
    default:
      return .beside
    }
  }
}

enum tileType: String {
  case rock = "Rock"
  case boulder = "Boulder"
  case rough = "Rough"
  case finish = "Finish"
  case player = "Player"
}

enum tileStops {
  case beside
  case onTopOf
}

struct Coordinate {
  var column: Int
  var row: Int
}

struct GameState {
  var playerState: playerState = .idle
  var playerDirection: direction = .right
}

class GameScene: SKScene {
  
  private var label : SKLabelNode?
  private var spinnyNode : SKShapeNode?
  private var player: Player!

  var layer2:SKTileMapNode!
  var layer3:SKTileMapNode!

  var gameState: GameState = GameState()
  var isUserInputAccepted: Bool {
    return !isMovingTile
  }
  
  var isMovingTile: Bool = false
  var tileSpeed: Double = 1/15
  
  let tileWidth: CGFloat = 64
  let numColumns = 25
  let numRows = 14
  
  var boulderTileGroup: SKTileGroup!
  var playerTileGroup: SKTileGroup!

  override func didMove(to view: SKView) {
    
    self.scaleMode = .aspectFit
    scene?.scaleMode = .aspectFit
    // Get label node from scene and store it for use later
    self.label = self.childNode(withName: "//helloLabel") as? SKLabelNode
    if let label = self.label {
      label.alpha = 0.0
      label.run(SKAction.fadeIn(withDuration: 2.0))
    }
    
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
    
    loadSceneNodes()
    
    player = Player(imageNamed: "Player")
    player.anchorPoint = CGPoint(x: 0, y: 0)
    player.position = CGPoint(x: 64*2, y: 64)
    scene?.addChild(player)
    
    guard let tileSet = SKTileSet(named: "Game Tiles") else {
      fatalError("Object Tiles Tile Set not found")
    }
    let tileGroups = tileSet.tileGroups
    
    guard let boulderTileGroup = tileGroups.first(where: {$0.name == "Boulder"}) else {
      fatalError("No Boulder tile definition found")
    }

    guard let playerTileGroup = tileGroups.first(where: {$0.name == "Player"}) else {
      fatalError("No Player tile definition found")
    }
    
    self.boulderTileGroup = boulderTileGroup
    self.playerTileGroup = playerTileGroup
    
    preprocessLevel()
  }
  
  func preprocessLevel() {
    for column in 0..<numColumns {
      for row in 0..<numRows {
        let tile = layer3.tileGroup(atColumn: column, row: row)
        if tile == playerTileGroup {
          layer3.setTileGroup(nil, forColumn: column, row: row)
          player.position = coordinateToPoint(coordinate: Coordinate(column: column, row: row))
        }
      }
    }
  }
  
  func loadSceneNodes() {
    guard let layer3 = childNode(withName: "Layer3")
      as? SKTileMapNode else {
        fatalError("Layer3 node not loaded")
    }
    self.layer3 = layer3
    
    guard let layer2 = childNode(withName: "Layer2")
      as? SKTileMapNode else {
        fatalError("Layer2 node not loaded")
    }
    self.layer2 = layer2
  }
  
  func swipedRight(sender:UISwipeGestureRecognizer) {
    print("swiped right")
    swipedInDirection(direction: .right)
  }
  
  func swipedLeft(sender:UISwipeGestureRecognizer) {
    print("swiped left")
    swipedInDirection(direction: .left)
  }
  
  func swipedUp(sender:UISwipeGestureRecognizer) {
    print("swiped up")
    swipedInDirection(direction: .up)
  }
  
  func swipedDown(sender:UISwipeGestureRecognizer) {
    print("swiped down")
    swipedInDirection(direction: .down)
  }
  
  func swipedInDirection(direction: direction) {
    if isUserInputAccepted {
      moveTile(tile: player, inDirection: direction)
    }
  }
  
  func moveTile(tile: SKSpriteNode, inDirection direction: direction) {
    let tileCoordinate = coordinateForTile(tile: tile)
    let nextCoordinate = newCoordinateForCoordinate(coordinate: tileCoordinate, inDirection: direction)
    
    let obstacleUnderTile = obstacleAtCoordinate(coordinate: tileCoordinate)
    let obstacleBesideTile = obstacleAtCoordinate(coordinate: nextCoordinate)
    
    if isMovingTile {
      if obstacleUnderTile?.tileStops == .onTopOf {
        endMovementForTile(tile: tile)
        return
      }
    }
    
    if obstacleBesideTile?.tileType == .rock {
      endMovementForTile(tile: tile)
      return
    }
    
    if obstacleBesideTile?.tileType == .boulder {
      endMovementForTile(tile: tile)
      pushBoulderAtCoordinate(coordinate: nextCoordinate, inDirection: direction)
      return
    }
    
    if obstacleBesideTile == nil || obstacleBesideTile?.tileStops == .onTopOf {
      isMovingTile = true
      let point = coordinateToPoint(coordinate: nextCoordinate)
      let action = SKAction.move(to: point, duration: self.tileSpeed)
      tile.run(action, completion: { _ in
        self.moveTile(tile: tile, inDirection: direction)
      })
    }
  }
  
  func pushBoulderAtCoordinate(coordinate: Coordinate, inDirection direction: direction) {
    layer3.setTileGroup(nil, forColumn: coordinate.column, row: coordinate.row)
    let boulder = Boulder(imageNamed: "Boulder")
    boulder.anchorPoint = CGPoint(x: 0, y: 0)
    boulder.position = coordinateToPoint(coordinate: coordinate)
    scene?.addChild(boulder)
    
    moveTile(tile: boulder, inDirection: direction)
  }
  
  func endMovementForTile(tile: SKSpriteNode) {
    isMovingTile = false
    
    if let player = tile as? Player {
      
    }
    if let boulder = tile as? Boulder {
      let coordinate = coordinateForTile(tile: boulder)
      boulder.removeFromParent()
      layer3.setTileGroup(boulderTileGroup, forColumn: coordinate.column, row: coordinate.row)
    }
  }
  
  func newCoordinateForCoordinate(coordinate: Coordinate, inDirection direction: direction) -> Coordinate {
    var columnDelta = 0
    var rowDelta = 0
    
    switch direction {
    case .up:
      rowDelta += 1
    case .right:
      columnDelta += 1
    case .down:
      rowDelta -= 1
    case .left:
      columnDelta -= 1
    }
    
    let newCoor = Coordinate(column: coordinate.column + columnDelta, row: coordinate.row + rowDelta)
    return newCoor
  }
  
  func coordinateToPoint(coordinate: Coordinate) -> CGPoint {
    return CGPoint(x: CGFloat(coordinate.column)*tileWidth, y: CGFloat(coordinate.row)*tileWidth)
  }
  
  func coordinateForTile(tile: SKSpriteNode) -> Coordinate {
    let column = Int(tile.position.x / tileWidth)
    let row = Int(tile.position.y / tileWidth)
    return Coordinate(column: column, row: row)
  }
  
  func obstacleAtCoordinate(coordinate: Coordinate) -> Tile? {
    if let obstacle = layer2.tileDefinition(atColumn: coordinate.column, row: coordinate.row) {
      if let tileType = tileType.init(rawValue: obstacle.name!) {
        return Tile(tileType: tileType)
      }
    }
    if let obstacle = layer3.tileDefinition(atColumn: coordinate.column, row: coordinate.row) {
      if let tileType = tileType.init(rawValue: obstacle.name!) {
        return Tile(tileType: tileType)
      }
    }

    return nil
  }
  
  override func update(_ currentTime: TimeInterval) {
    // Called before each frame is rendered
  }
}
