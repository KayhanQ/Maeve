//
//  GameScene.swift
//  Maeve
//
//  Created by Mac on 2017-02-01.
//  Copyright © 2017 Paddy Crab Games. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit

class GameScene: SKScene {
  
  private var player: Player!

  private var layer2:SKTileMapNode!
  private var layer3:SKTileMapNode!

  var gameState: GameState = GameState()
  
  var isUserInputAccepted: Bool {
    return !isMovingTile
  }
  
  private var isMovingTile: Bool = false
  
  private let tileSpeed: CGFloat = 0.08
  
  private let numRowsOnScreen: Int = 10
  private let tileWidth: CGFloat = 64
  private let numColumns = 64
  private let numRows = 64
  
  private var boulderTileGroup: SKTileGroup!
  private var playerTileGroup: SKTileGroup!
  private var finishTileGroup: SKTileGroup!

  private var lastSaveCoordinate: Coordinate!
  
  override func didMove(to view: SKView) {
    addSwipeGestureRecognizers(view: view)
    loadTileGroups()
    preprocessLevel()
    initializeCamera()
  }
  
  func loadTileGroups() {
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
    
    guard let finishTileGroup = tileGroups.first(where: {$0.name == "Finish"}) else {
      fatalError("No Finish tile definition found")
    }
    
    self.boulderTileGroup = boulderTileGroup
    self.playerTileGroup = playerTileGroup
    self.finishTileGroup = finishTileGroup
  }
  
  func preprocessLevel() {
    player = Player(imageNamed: "Player")
    player.anchorPoint = CGPoint(x: 0, y: 0)
    player.position = CGPoint(x: 64*2, y: 64)
    scene?.addChild(player)
    
    let physicsBody = SKPhysicsBody(rectangleOf: player.size)
    physicsBody.affectedByGravity = false
    player.physicsBody = physicsBody
    
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

    for column in 0..<numColumns {
      for row in 0..<numRows {
        let tile = layer3.tileGroup(atColumn: column, row: row)
        if tile == playerTileGroup {
          layer3.setTileGroup(nil, forColumn: column, row: row)
          let playerCoordinate = Coordinate(column: column, row: row)
          player.position = coordinateToPoint(coordinate: playerCoordinate)
          lastSaveCoordinate = playerCoordinate
        }
      }
    }
  }
  
  func initializeCamera() {
    let cameraNode = SKCameraNode()
    cameraNode.position = CGPoint(x: scene!.size.width / 2, y: scene!.size.height / 2)
    scene?.addChild(cameraNode)
    scene?.camera = cameraNode
    
    let numTiles = view!.frame.height / tileWidth
    let scale = CGFloat(numRowsOnScreen) / numTiles
    let zoomInAction = SKAction.scale(to: scale, duration: 1)
    cameraNode.run(zoomInAction)
    cameraNode.position = player.position
  }
  
  func swipedInDirection(direction: direction) {
    if isUserInputAccepted {
      moveTile(tile: player, inDirection: direction)
    }
  }
  
  func moveTile(tile: SKSpriteNode, inDirection direction: direction) {
    let tileCoordinate = coordinateForTile(tile: tile)
    var nextCoordinate = newCoordinateForCoordinate(coordinate: tileCoordinate, inDirection: direction)
    var obstacleBesideTile = obstacleAtCoordinate(coordinate: nextCoordinate)
    
    var newTileCoordinate = tileCoordinate
    while obstacleBesideTile == nil {
      newTileCoordinate = nextCoordinate
      nextCoordinate = newCoordinateForCoordinate(coordinate: nextCoordinate, inDirection: direction)
      obstacleBesideTile = obstacleAtCoordinate(coordinate: nextCoordinate)
    }

    if obstacleBesideTile?.tileStops == .onTopOf {
      newTileCoordinate = nextCoordinate
    }
    
    isMovingTile = true
    let actionTime = Double(tileCoordinate.distanceFrom(coordinate: newTileCoordinate)) * Double(tileSpeed)
    let point = coordinateToPoint(coordinate: newTileCoordinate)
    let action = SKAction.move(to: point, duration: actionTime)
    action.timingMode = SKActionTimingMode.easeInEaseOut
    tile.run(action, completion: { _ in
      self.endMovementForTile(tile: tile, inDirection: direction)
    })
    if tile is Player {
      camera?.run(action)
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
  
  func endMovementForTile(tile: SKSpriteNode, inDirection direction: direction) {
    isMovingTile = false
    let tileCoordinate = coordinateForTile(tile: tile)


    if let player = tile as? Player {
      if isReachedFinish() {
        lastSaveCoordinate = coordinateForTile(tile: player)
      }
      if let obstacleUnderTile = obstacleAtCoordinate(coordinate: tileCoordinate) {
        if obstacleUnderTile.tileType == .hole {
          respawn()
        }
      }
    }
    
    if let boulder = tile as? Boulder {
      let coordinate = coordinateForTile(tile: boulder)
      boulder.removeFromParent()
      layer3.setTileGroup(boulderTileGroup, forColumn: coordinate.column, row: coordinate.row)
    }
    
    let obstacleCoordinate = newCoordinateForCoordinate(coordinate: tileCoordinate, inDirection: direction)
    if let obstacle = obstacleAtCoordinate(coordinate: obstacleCoordinate) {
      if obstacle.tileType == .boulder {
        pushBoulderAtCoordinate(coordinate: obstacleCoordinate, inDirection: direction)
      }
    }
  }
  
  func isReachedFinish() -> Bool {
    let playerCoordinate = coordinateForTile(tile: player)
    let tile = layer2.tileGroup(atColumn: playerCoordinate.column, row: playerCoordinate.row)
    if tile == finishTileGroup {
      return true
    }
    return false
  }
  
  func endLevel() {
    let scene = MenuScene(size: (self.view?.bounds.size)!)
    scene.scaleMode = .aspectFill
    self.view?.presentScene(scene)    
  }
  
  func respawn() {
    player.position = coordinateToPoint(coordinate: lastSaveCoordinate)
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
    if let obstacle = layer3.tileDefinition(atColumn: coordinate.column, row: coordinate.row) {
      if let tileType = tileType(rawValue: obstacle.name!) {
        return Tile(tileType: tileType)
      }
    }
    
    if let obstacle = layer2.tileDefinition(atColumn: coordinate.column, row: coordinate.row) {
      if let tileType = tileType(rawValue: obstacle.name!) {
        return Tile(tileType: tileType)
      }
    }

    return nil
  }
  
  override func update(_ currentTime: TimeInterval) {
  }
}
