//
//  NumberTileGame.swift
//  Battery Saver
//
//  Created by Jérémy Kerbidi on 03/10/2016.
//  Copyright © 2016 Jérémy Kerbidi. All rights reserved.
//



import UIKit

/// A view controller representing the swift-2048 game. It serves mostly to tie a GameModel and a GameboardView
/// together. Data flow works as follows: user input reaches the view controller and is forwarded to the model. Move
/// orders calculated by the model are returned to the view controller and forwarded to the gameboard view, which
/// performs any animations to update its state.
class NumberTileGameViewController : UIViewController, GameModelProtocol {
  // How many tiles in both directions the gameboard contains
  var dimension: Int
  // The value of the winning tile
  var threshold: Int

  var board: GameboardView? // contrainte
  var cView: ControlView? // contrainte
  var model: GameModel?

  var scoreView: ScoreViewProtocol?
  var scoreLabel: Int
  // Width of the gameboard
  var boardWidth: CGFloat!
  // How much padding to place between the tiles
  let thinPadding: CGFloat = 3.0
  let thickPadding: CGFloat = 6.0

  // Amount of space to place between the different component views (gameboard, score view, etc)
  let viewPadding: CGFloat = 10.0

  // Amount that the vertical alignment of the component views should differ from if they were centered
  let verticalViewOffset: CGFloat = 0.0
    var gtracker: TrackerGoogle!
    
 init(dimension d: Int, threshold t: Int) {
    
    self.gtracker = TrackerGoogle()
    self.gtracker.setScreenName(name: "2048")
    self.scoreLabel = 0
    dimension = d > 2 ? d : 2
    threshold = t > 8 ? t : 8
    super.init(nibName: nil, bundle: nil)
    model = GameModel(dimension: dimension, threshold: threshold, delegate: self)
    self.view.backgroundColor = UIColor.init(red: 251/255, green: 248/255, blue: 239/255, alpha: 1)
    setupSwipeControls()
  }

  required init(coder aDecoder: NSCoder) {
    fatalError("NSCoding not supported")
  }

  func setupSwipeControls() {
    let upSwipe = UISwipeGestureRecognizer(target: self, action: #selector(NumberTileGameViewController.upCommand(r:)))
    upSwipe.numberOfTouchesRequired = 1
    upSwipe.direction = UISwipeGestureRecognizerDirection.up
    view.addGestureRecognizer(upSwipe)

    let downSwipe = UISwipeGestureRecognizer(target: self, action: #selector(NumberTileGameViewController.downCommand(r:)))
    downSwipe.numberOfTouchesRequired = 1
    downSwipe.direction = UISwipeGestureRecognizerDirection.down
    view.addGestureRecognizer(downSwipe)

    let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(NumberTileGameViewController.leftCommand(r:)))
    leftSwipe.numberOfTouchesRequired = 1
    leftSwipe.direction = UISwipeGestureRecognizerDirection.left
    view.addGestureRecognizer(leftSwipe)

    let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(NumberTileGameViewController.rightCommand(r:)))
    rightSwipe.numberOfTouchesRequired = 1
    rightSwipe.direction = UISwipeGestureRecognizerDirection.right
    view.addGestureRecognizer(rightSwipe)
  }


  // View Controller
  override func viewDidLoad()  {
    super.viewDidLoad()
    
    self.boardWidth = self.view.bounds.width - 45

    setupGame()
  }

    func reset() {
        
        assert(self.board != nil && self.model != nil)
        let b = self.board!
        let m = self.model!
        let c = self.cView!
        b.reset()
        m.reset()
        c.reset()
        m.insertTileAtRandomLocation(value: 2)
        m.insertTileAtRandomLocation(value: 2)
    }
    
  func restart() {
    
    let alert = UIAlertController(title: "gameTitltrestart".localized, message: "gameTextRestart".localized, preferredStyle: .alert)
    let yes = UIAlertAction(title: "yes".localized, style: .default, handler: { Void in
        let def = UserDefaults.standard
        
        self.gtracker.setEvent(category: "2048", action: "restart_yes", label: "click")

        if let val: Int = def.value(forKey: "best") as! Int? {
            if (self.scoreLabel > val) {
                def.set(self.scoreLabel, forKey: "best")
                def.synchronize()
            }
        }
        else {
            def.set(self.scoreLabel, forKey: "best")
            def.synchronize()
        }
        self.reset()
        })
        let no = UIAlertAction(title: "no".localized, style: .cancel, handler: { Void in
            self.gtracker.setEvent(category: "2048", action: "restart_no", label: "click")
        })
        alert.addAction(yes)
        alert.addAction(no)
        present(alert, animated: true, completion: nil)
    }

    func quitGame() {
        
        let alert = UIAlertController(title: "leavetitle".localized, message: "leaveText".localized, preferredStyle: .alert)
        let yes = UIAlertAction(title: "gameQuitButton".localized, style: .default, handler: { Void in
            
            self.gtracker.setEvent(category: "2048", action: "quit_yes", label: "click")

            let def = UserDefaults.standard
            
            if let val: Int = def.value(forKey: "best") as! Int? {
                if (self.scoreLabel > val) {
                    def.set(self.scoreLabel, forKey: "best")
                    def.synchronize()
                }
            }
            else {
                def.set(self.scoreLabel, forKey: "best")
                def.synchronize()
            }
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "MainCtrl")
            self.present(controller, animated: true, completion: nil)
            //self.dismiss(animated: true, completion: nil)
        })
        let no = UIAlertAction(title: "gameContinueButton".localized, style: .cancel, handler: { Void in
            self.gtracker.setEvent(category: "2048", action: "quit_no", label: "click")
        })
        
        alert.addAction(yes)
        alert.addAction(no)
        present(alert, animated: true, completion: nil)
    }
    
  func setupGame() {
    let vcHeight = view.bounds.size.height
    let vcWidth = view.bounds.size.width

    // This nested function provides the x-position for a component view
    func xPositionToCenterView(v: UIView) -> CGFloat {
      let viewWidth = v.bounds.size.width
      let tentativeX = 0.5*(vcWidth - viewWidth)
      return tentativeX >= 0 ? tentativeX : 0
    }
    // This nested function provides the y-position for a component view
    func yPositionForViewAtPosition(order: Int, views: [UIView]) -> CGFloat {
      assert(views.count > 0)
      assert(order >= 0 && order < views.count)
      let totalHeight = CGFloat(views.count - 1)*viewPadding + views.map({ $0.bounds.size.height }).reduce(verticalViewOffset, { $0 + $1 })
      let viewsTop = 0.5*(vcHeight - totalHeight) >= 0 ? 0.5*(vcHeight - totalHeight) : 0

      // Not sure how to slice an array yet
      var acc: CGFloat = 0
      for i in 0..<order {
        acc += viewPadding + views[i].bounds.size.height
      }
      return viewsTop + acc
    }

    // Create controlls view
    //let controllView = ControlView(backgroundColor: UIColor.init(red: 191/255, green: 176/255, blue: 157/255, alpha: 1), radius: 6, width: self.view.frame.size.width, height: self.view.frame.size.height)
    let controllView = ControlView(backgroundColor: UIColor.init(red: 191/255, green: 176/255, blue: 157/255, alpha: 1), radius: 6, width: self.view.bounds.width, height: self.view.bounds.height)
    controllView.quitGame.addTarget(self, action: #selector(NumberTileGameViewController.quitGame), for: .touchUpInside)
    controllView.resetGame.addTarget(self, action: #selector(NumberTileGameViewController.restart), for: .touchUpInside)
    
    // Create the score view
    let scoreView = ScoreView(backgroundColor: UIColor.black,
      textColor: UIColor.white,
      font: UIFont(name: "HelveticaNeue-Bold", size: 16.0) ?? UIFont.systemFont(ofSize: 16.0),
      radius: 6)
    scoreView.score = 0

    // Create the gameboard
    let padding: CGFloat = dimension > 5 ? thinPadding : thickPadding
    let v1 = boardWidth - padding*(CGFloat(dimension + 1))
    let width: CGFloat = CGFloat(floorf(CFloat(v1)))/CGFloat(dimension)
    let gameboard = GameboardView(dimension: dimension,
      tileWidth: width,
      tilePadding: padding,
      cornerRadius: 6,
      backgroundColor: UIColor.init(red: 191/255, green: 176/255, blue: 157/255, alpha: 1),
      foregroundColor: UIColor.darkGray)

    // Set up the frames
    let views = [controllView, scoreView, gameboard]
    
   
    
    var f = scoreView.frame
    f.origin.x = xPositionToCenterView(v: scoreView)
    f.origin.y = yPositionForViewAtPosition(order: 1, views: views)
    scoreView.frame = f

    f = gameboard.frame
    f.origin.x = xPositionToCenterView(v: gameboard)
    f.origin.y = yPositionForViewAtPosition(order: 2, views: views)
    gameboard.frame = f
    
    f = controllView.frame
    f.origin.x = xPositionToCenterView(v: controllView)
    f.origin.y = yPositionForViewAtPosition(order: 0, views: views)
    controllView.frame = f
    

    // Add to game state
    view.addSubview(controllView)
    view.addSubview(gameboard)
    self.board = gameboard
    self.cView = controllView
    view.addSubview(scoreView)
    self.scoreView = scoreView
    
    
    
    assert(model != nil)
    let m = model!
    m.insertTileAtRandomLocation(value: 2)
    m.insertTileAtRandomLocation(value: 2)
  }
    
  // Misc
  func followUp() {
    assert(model != nil)
    let m = model!
    let (userWon, _) = m.userHasWon()
    if userWon {
      // TODO: alert delegate we won
        let alert = UIAlertController(title: "2048VictoryTitle".localized, message: "2048VictoryBody".localized, preferredStyle: .actionSheet)
        let res = UIAlertAction(title: "gameContinueButton".localized, style: .cancel, handler: { Void in
            self.gtracker.setEvent(category: "2048", action: "victory_continue", label: "click")
        })
        let quit = UIAlertAction(title: "gameQuitButton".localized, style: .destructive, handler: { Void in
            self.gtracker.setEvent(category: "2048", action: "victory_quit", label: "click")
            
            let def = UserDefaults.standard
            
            if let val: Int = def.value(forKey: "best") as! Int? {
                if (self.scoreLabel > val) {
                    def.set(self.scoreLabel, forKey: "best")
                    def.synchronize()
                }
            }
            else {
                def.set(self.scoreLabel, forKey: "best")
                def.synchronize()
            }
            self.gtracker.setEvent(category: "2048", action: "defeat_quit", label: "click")
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "MainCtrl")
            self.present(controller, animated: true, completion: nil)
            //self.dismiss(animated: true, completion: nil)
        })
        alert.addAction(res)
        alert.addAction(quit)
        present(alert, animated: true, completion: nil)
      // TODO: At this point we should stall the game until the user taps 'New Game' (which hasn't been implemented yet)
      return
    }

    // Now, insert more tiles
    let randomVal = Int(arc4random_uniform(10))
    m.insertTileAtRandomLocation(value: randomVal == 1 ? 4 : 2)

    // At this point, the user may lose
    if m.userHasLost() {
        
        let def = UserDefaults.standard
        
        if let val: Int = def.value(forKey: "best") as! Int? {
            if (self.scoreLabel > val) {
                def.set(self.scoreLabel, forKey: "best")
                def.synchronize()
            }
        }
        else {
            def.set(self.scoreLabel, forKey: "best")
            def.synchronize()
        }
        
        
        let alert = UIAlertController(title: "2048DefeatTitle".localized, message: "2048DefeatBody".localized, preferredStyle: .actionSheet)
        let res = UIAlertAction(title: "gameTitltrestart".localized, style: .default, handler: { Void in
            self.gtracker.setEvent(category: "2048", action: "defeat_restart", label: "click")
            self.reset()
        })
        let quit = UIAlertAction(title: "gameQuitButton".localized, style: .destructive, handler: { Void in
            self.gtracker.setEvent(category: "2048", action: "defeat_quit", label: "click")
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "MainCtrl")
            self.present(controller, animated: true, completion: nil)
            //self.dismiss(animated: true, completion: nil)
            //self.ctrl.present(controller, animated: true, completion: nil)
            //self.dismiss(animated: true, completion: nil)
        })
        alert.addAction(res)
        alert.addAction(quit)
        present(alert, animated: true, completion: nil)
    }
  }

  // Commands
  @objc(up:)
  func upCommand(r: UIGestureRecognizer!) {
    assert(model != nil)
    let m = model!
    m.queueMove(direction: MoveDirection.Up,
      completion: { (changed: Bool) -> () in
        if changed {
          self.followUp()
        }
      })
  }

  @objc(down:)
  func downCommand(r: UIGestureRecognizer!) {
    assert(model != nil)
    let m = model!
    m.queueMove(direction: MoveDirection.Down,
      completion: { (changed: Bool) -> () in
        if changed {
          self.followUp()
        }
      })
  }

  @objc(left:)
  func leftCommand(r: UIGestureRecognizer!) {
    assert(model != nil)
    let m = model!
    m.queueMove(direction: MoveDirection.Left,
      completion: { (changed: Bool) -> () in
        if changed {
          self.followUp()
        }
      })
  }

  @objc(right:)
  func rightCommand(r: UIGestureRecognizer!) {
    assert(model != nil)
    let m = model!
    m.queueMove(direction: MoveDirection.Right,
      completion: { (changed: Bool) -> () in
        if changed {
          self.followUp()
        }
      })
  }
    
  // Protocol
  func scoreChanged(score: Int) {
    if scoreView == nil {
      return
    }
    let s = scoreView!
    self.scoreLabel = score
    s.scoreChanged(newScore: score)
  }

  func moveOneTile(from: (Int, Int), to: (Int, Int), value: Int) {
    assert(board != nil)
    let b = board!
    b.moveOneTile(from: from, to: to, value: value)
  }

  func moveTwoTiles(from: ((Int, Int), (Int, Int)), to: (Int, Int), value: Int) {
    assert(board != nil)
    let b = board!
    b.moveTwoTiles(from: from, to: to, value: value)
  }

  func insertTile(location: (Int, Int), value: Int) {
    assert(board != nil)
    let b = board!
    b.insertTile(pos: location, value: value)
  }
}
