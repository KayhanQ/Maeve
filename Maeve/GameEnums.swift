//
//  GameEnums.swift
//  Maeve
//
//  Created by Mac on 2017-02-07.
//  Copyright © 2017 Paddy Crab Games. All rights reserved.
//

import Foundation
import SpriteKit

enum direction: Int {
  case up, right, down, left
}

enum playerState {
  case idle, moving
}

struct Coordinate {
  var column: Int
  var row: Int
  
  static func ==(lhs: Coordinate, rhs: Coordinate) -> Bool {
    return lhs.column == rhs.column && lhs.row == rhs.row
  }
  
  func distanceFrom(coordinate: Coordinate) -> Int {
    return abs(self.column - coordinate.column) + abs(self.row - coordinate.row)
  }
}

struct GameState {
  var playerState: playerState = .idle
  var playerDirection: direction = .right
}
