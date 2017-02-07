//
//  GameScene+Helpers.swift
//  Maeve
//
//  Created by Mac on 2017-02-07.
//  Copyright © 2017 Paddy Crab Games. All rights reserved.
//

import Foundation
import SpriteKit

extension GameScene {
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
  
}
