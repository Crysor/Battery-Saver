//
//  GameboardView.swift
//  Battery Saver
//
//  Created by Jérémy Kerbidi on 03/10/2016.
//  Copyright © 2016 Jérémy Kerbidi. All rights reserved.
//

import UIKit

class GameboardView : UIView {
  var dimension: Int
  var tileWidth: CGFloat
  var tilePadding: CGFloat
  var cornerRadius: CGFloat
  var tiles: Dictionary<NSIndexPath, TileView>

  let provider = AppearanceProvider()

  let tilePopStartScale: CGFloat = 0.1
  let tilePopMaxScale: CGFloat = 1.1

  let tileMergeStartScale: CGFloat = 1.0

  init(dimension d: Int, tileWidth width: CGFloat, tilePadding padding: CGFloat, cornerRadius radius: CGFloat, backgroundColor: UIColor, foregroundColor: UIColor) {
    assert(d > 0)
    dimension = d
    tileWidth = width
    tilePadding = padding
    cornerRadius = radius
    tiles = Dictionary()
    let sideLength = padding + CGFloat(dimension)*(width + padding)
    super.init(frame: CGRect(x: 0, y: 0, width: sideLength, height: sideLength))
    layer.cornerRadius = radius
    setupBackground(backgroundColor: backgroundColor, tileColor: foregroundColor)
  }

  required init(coder: NSCoder) {
    fatalError("NSCoding not supported")
  }
  /// Reset the gameboard.
  func reset() {
    for (_, tile) in tiles {
      tile.removeFromSuperview()
    }
    tiles.removeAll(keepingCapacity: true)
  }

  /// Return whether a given position is valid. Used for bounds checking.
  func positionIsValid(pos: (Int, Int)) -> Bool {
    let (x, y) = pos
    return (x >= 0 && x < dimension && y >= 0 && y < dimension)
  }

  func setupBackground(backgroundColor bgColor: UIColor, tileColor: UIColor) {
    backgroundColor = bgColor
    var xCursor = tilePadding
    var yCursor: CGFloat
    let bgRadius = (cornerRadius >= 2) ? cornerRadius - 2 : 0
    for _ in 0..<dimension {
      yCursor = tilePadding
      for _ in 0..<dimension {
        // Draw each tile
        let background = UIView(frame: CGRect(x: xCursor, y: yCursor, width: tileWidth, height: tileWidth))//CGRectMake(xCursor, yCursor, tileWidth, tileWidth))
        background.layer.cornerRadius = bgRadius
        background.backgroundColor = tileColor
        addSubview(background)
        yCursor += tilePadding + tileWidth
      }
      xCursor += tilePadding + tileWidth
    }
  }

  /// Update the gameboard by inserting a tile in a given location. The tile will be inserted with a 'pop' animation.
  func insertTile(pos: (Int, Int), value: Int) {
    assert(positionIsValid(pos: pos))
    let (row, col) = pos
    let x = tilePadding + CGFloat(col)*(tileWidth + tilePadding)
    let y = tilePadding + CGFloat(row)*(tileWidth + tilePadding)
    let r = (cornerRadius >= 2) ? cornerRadius - 2 : 0
    
    let tile = TileView(position: CGPoint(x: x, y: y), width: tileWidth, value: value, radius: r, delegate: provider)
    tile.layer.setAffineTransform(CGAffineTransform(scaleX: tilePopStartScale, y: tilePopStartScale))

    addSubview(tile)
    bringSubview(toFront: tile)
    //tiles[NSIndexPath(forRow: row, inSection: col)] = tile
    //tiles[IndexPath.init(row: row, section: col)] = tile
    tiles[NSIndexPath.init(row: row, section: col)] = tile

    // Add to board
    UIView.animate(withDuration: 0.18, delay: 0.05, options: UIViewAnimationOptions.transitionCurlDown,
      animations: {
        // Make the tile 'pop'
        tile.layer.setAffineTransform(CGAffineTransform(scaleX: self.tilePopMaxScale, y: self.tilePopMaxScale))
      },
      completion: { finished in
        // Shrink the tile after it 'pops'
        UIView.animate(withDuration: 0.08, animations: { () -> Void in
          tile.layer.setAffineTransform(CGAffineTransform.identity)//CGAffineTransformIdentity)
        })
    })
  }

  /// Update the gameboard by moving a single tile from one location to another. If the move is going to collapse two
  /// tiles into a new tile, the tile will 'pop' after moving to its new location.
  func moveOneTile(from: (Int, Int), to: (Int, Int), value: Int) {
    assert(positionIsValid(pos: from) && positionIsValid(pos: to))
    let (fromRow, fromCol) = from
    let (toRow, toCol) = to
    let fromKey = NSIndexPath(row: fromRow, section: fromCol)//NSIndexPath(forRow: fromRow, inSection: fromCol)
    let toKey = NSIndexPath(row: toRow, section: toCol)//NSIndexPath(forRow: toRow, inSection: toCol)

    // Get the tiles
    guard let tile = tiles[fromKey] else {
      assert(false, "placeholder error")
        return
    }
    let endTile = tiles[toKey]

    // Make the frame
    var finalFrame = tile.frame
    finalFrame.origin.x = tilePadding + CGFloat(toCol)*(tileWidth + tilePadding)
    finalFrame.origin.y = tilePadding + CGFloat(toRow)*(tileWidth + tilePadding)

    // Update board state
    tiles.removeValue(forKey: fromKey)
    tiles[toKey] = tile

    // Animate
    let shouldPop = endTile != nil
    UIView.animate(withDuration: 0.08,
      delay: 0.0,
      options: UIViewAnimationOptions.beginFromCurrentState,
      animations: {
        // Slide tile
        tile.frame = finalFrame
      },
      completion: { (finished: Bool) -> Void in
        tile.value = value
        endTile?.removeFromSuperview()
        if !shouldPop || !finished {
          return
        }
        tile.layer.setAffineTransform(CGAffineTransform(scaleX: self.tileMergeStartScale, y: self.tileMergeStartScale))
        // Pop tile
        UIView.animate(withDuration: 0.08,
          animations: {
            tile.layer.setAffineTransform(CGAffineTransform(scaleX: self.tilePopMaxScale, y: self.tilePopMaxScale))
          },
          completion: { finished in
            // Contract tile to original size
            UIView.animate(withDuration: 0.08) {
              tile.layer.setAffineTransform(CGAffineTransform.identity)
            }
        })
    })
  }

  /// Update the gameboard by moving two tiles from their original locations to a common destination. This action always
  /// represents tile collapse, and the combined tile 'pops' after both tiles move into position.
  func moveTwoTiles(from: ((Int, Int), (Int, Int)), to: (Int, Int), value: Int) {
    assert(positionIsValid(pos: from.0) && positionIsValid(pos: from.1) && positionIsValid(pos: to))
    let (fromRowA, fromColA) = from.0
    let (fromRowB, fromColB) = from.1
    let (toRow, toCol) = to
    let fromKeyA = NSIndexPath(row: fromRowA, section: fromColA)//NSIndexPath(forRow: fromRowA, inSection: fromColA)
    let fromKeyB = NSIndexPath(row: fromRowB, section: fromColB)//NSIndexPath(forRow: fromRowB, inSection: fromColB)
    let toKey = NSIndexPath(row: toRow, section: toCol)//NSIndexPath(forRow: toRow, inSection: toCol)

    guard let tileA = tiles[fromKeyA] else {
      assert(false, "placeholder error")
        return
    }
    guard let tileB = tiles[fromKeyB] else {
      assert(false, "placeholder error")
        return
    }

    // Make the frame
    var finalFrame = tileA.frame
    finalFrame.origin.x = tilePadding + CGFloat(toCol)*(tileWidth + tilePadding)
    finalFrame.origin.y = tilePadding + CGFloat(toRow)*(tileWidth + tilePadding)

    // Update the state
    let oldTile = tiles[toKey]  // TODO: make sure this doesn't cause issues
    oldTile?.removeFromSuperview()
    tiles.removeValue(forKey: fromKeyA)
    tiles.removeValue(forKey: fromKeyB)
    tiles[toKey] = tileA

    UIView.animate(withDuration: 0.08,
      delay: 0.0,
      options: UIViewAnimationOptions.beginFromCurrentState,
      animations: {
        // Slide tiles
        tileA.frame = finalFrame
        tileB.frame = finalFrame
      },
      completion: { finished in
        tileA.value = value
        tileB.removeFromSuperview()
        if !finished {
          return
        }
        tileA.layer.setAffineTransform(CGAffineTransform(scaleX: self.tileMergeStartScale, y: self.tileMergeStartScale))
        // Pop tile
        UIView.animate(withDuration: 0.08,
          animations: {
            tileA.layer.setAffineTransform(CGAffineTransform(scaleX: self.tilePopMaxScale, y: self.tilePopMaxScale))
          },
          completion: { finished in
            // Contract tile to original size
            UIView.animate(withDuration: 0.08) {
              tileA.layer.setAffineTransform(CGAffineTransform.identity)
            }
        })
    })
  }
}