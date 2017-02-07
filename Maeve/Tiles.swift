//
//  Tiles.swift
//  Maeve
//
//  Created by Mac on 2017-02-07.
//  Copyright © 2017 Paddy Crab Games. All rights reserved.
//

import Foundation
import SpriteKit

enum tileType: String {
  case rock = "Rock"
  case boulder = "Boulder"
  case rough = "Rough"
  case finish = "Finish"
  case player = "Player"
  case hole = "Hole"
}

enum tileStops {
  case beside
  case onTopOf
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
    case .hole:
      return .onTopOf
    default:
      return .beside
    }
  }
}
