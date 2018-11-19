//
//  GameScene.swift
//  NextURacing
//
//  Created by Alejocram on 24/05/16.
//  Copyright (c) 2016 NextU. All rights reserved.
//

import SpriteKit
import Flurry_iOS_SDK

struct PhysicsCategory {
    static let None:  UInt32 = 0
    static let Car:   UInt32 = 0b1
    static let CheckPoint: UInt32 = 0b10
    static let Bounds: UInt32 = 0b100
}

class GameScene: SKScene, AdColonyAdDelegate {
    let car = SKSpriteNode(imageNamed: "car")
    var lastUpdateTimeInterval: NSTimeInterval = 0
    var deltaTime: NSTimeInterval = 0
    let carMovePointsPerSec: CGFloat = 400.0
    var velocity = CGPoint.init(x: -1, y: 0)
    let playableRect: CGRect
    var check1 = false, check2 = false, check3 = false
    var firstTime = true
    var laps = 0
    var customZone = "vz5b43de9e320e493181"
    var recordLaps: Int!
    
    let defaults = NSUserDefaults.standardUserDefaults()
    
    var viewController: GameViewController!
    
    var crash = 0 {
        didSet {
            if crash == 6 {
                restartCar()
                lives -= 1
                livesLabel.text = "Vidas \(lives)"
                crash = 0
            }
        
        }
    }
    
    var lives = 1 {
        didSet {
            if lives == 0 {
                endGame()
            }
        }
    }
    
    let lapsLabel = SKLabelNode(fontNamed: "Avenir-Heavy")
    let crashLabel = SKLabelNode(fontNamed: "Avenir-Heavy")
    let livesLabel = SKLabelNode(fontNamed: "Avenir-Heavy")
    
    override init(size: CGSize) {
        let maxAspectRatio:CGFloat = 16.0/9.0
        let playableHeight = size.width / maxAspectRatio
        let playableMargin = (size.height-playableHeight)/2.0
        playableRect = CGRect(x: 240, y: playableMargin,
                              width: size.width - 520,
                              height: playableHeight)
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToView(view: SKView) {
        setBackground()
        setCar()
        let record = defaults.stringForKey("laps")
        recordLaps = record != nil ? Int(record!) : 0
        
        setupPhysicsBodies()
        setCheckPoints()
        
        physicsWorld.contactDelegate = self
        
        setLabels()
        
        addObserverGeneric(#selector(self.addObservers), name: UIApplicationWillEnterForegroundNotification)
        addObserverGeneric(#selector(self.removeObservers), name: UIApplicationDidEnterBackgroundNotification)
        self.addObservers()
    }
   
    override func update(currentTime: CFTimeInterval) {
        if lastUpdateTimeInterval > 0 {
            deltaTime = currentTime - lastUpdateTimeInterval
        } else {
            deltaTime = 0
        }
        lastUpdateTimeInterval = currentTime
//        print("\(deltaTime) segundos")
        
        moveSprite(car, velocity: velocity)
        rotateSprite(car, direction: velocity)
    }
    
    func setBackground(){
        backgroundColor = SKColor.blackColor()
        
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: size.width/2, y: size.height/2)
        background.anchorPoint = CGPoint(x: 0.5, y: 0.5) // default
        background.zPosition = -1
        addChild(background)
    }
    
    func setCar() {
        car.position = CGPoint(x: 900, y:800)
        car.anchorPoint = CGPoint(x: 0.5, y: 0.5) // default
        
        car.physicsBody = SKPhysicsBody(rectangleOfSize: car.frame.size)
        car.physicsBody!.dynamic = true
        car.physicsBody?.affectedByGravity = false
        
        car.physicsBody?.categoryBitMask = PhysicsCategory.Car
        car.physicsBody?.collisionBitMask = PhysicsCategory.Bounds
        car.physicsBody?.contactTestBitMask = PhysicsCategory.CheckPoint | PhysicsCategory.Bounds
        addChild(car)
    }
    
    func setLabels() {
        lapsLabel.text = "Vuelta: 0"
        lapsLabel.fontColor = SKColor.blackColor()
        lapsLabel.fontSize = 100
        lapsLabel.zPosition = 100
        lapsLabel.horizontalAlignmentMode = .Left
        lapsLabel.verticalAlignmentMode = .Top
        lapsLabel.position = CGPoint(x: 255, y:playableRect.maxY-100)
        addChild(lapsLabel)
        
        crashLabel.text = "Golpes: 0"
        crashLabel.fontColor = SKColor.blackColor()
        crashLabel.fontSize = 100
        crashLabel.zPosition = 100
        crashLabel.horizontalAlignmentMode = .Left
        crashLabel.verticalAlignmentMode = .Top
        crashLabel.position = CGPoint(x: 255, y:playableRect.maxY-200)
        addChild(crashLabel)
        
        livesLabel.text = "Vidas: \(lives)"
        livesLabel.fontColor = SKColor.blackColor()
        livesLabel.fontSize = 100
        livesLabel.zPosition = 100
        livesLabel.horizontalAlignmentMode = .Left
        livesLabel.verticalAlignmentMode = .Top
        livesLabel.position = CGPoint(x: 255, y:playableRect.maxY-300)
        addChild(livesLabel)
    }
    
    //MARK: Move Car
    
    func moveSprite(sprite: SKSpriteNode, velocity: CGPoint) {
        let amountToMove = CGPoint(x: velocity.x * CGFloat(deltaTime),
                                   y: velocity.y * CGFloat(deltaTime))
        
        sprite.position = CGPoint(
            x: sprite.position.x + amountToMove.x,
            y: sprite.position.y + amountToMove.y)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        let touchLocation = touch.locationInNode(self)
        moveCar(touchLocation)
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        let touchLocation = touch.locationInNode(self)
        moveCar(touchLocation)
    }
    
    func moveCar(location: CGPoint) {
        let offset = CGPoint(x: location.x - car.position.x,y: location.y - car.position.y)
        let length = sqrt(Double(offset.x * offset.x + offset.y * offset.y))
        let direction = CGPoint(x: offset.x / CGFloat(length), y: offset.y / CGFloat(length))
        velocity = CGPoint(x: direction.x * carMovePointsPerSec, y: direction.y * carMovePointsPerSec)
    }
    
    func rotateSprite(sprite: SKSpriteNode, direction: CGPoint) {
        sprite.zRotation = CGFloat(atan2(Double(direction.y), Double(direction.x)))
    }
    
    func addRecord() {
        if laps > recordLaps {
            defaults.setValue("\(laps)", forKey: "laps")
            let user = defaults.stringForKey("username")
            if Flurry.activeSessionExists() {
                Flurry.logEvent("Best User Laps", withParameters: ["Username": user != nil ? user! : "usuario1", "Laps": laps])
            }
        }
    }
    
    func restartCar() {
        velocity = CGPoint(x: 0, y: 0)
        removeChildrenInArray([car])
        setCar()
        firstTime = true
        check1 = false
        check2 = false
        check3 = false
    }
    
    //MARK: TRACK'S BOUNDS
    
    func setupPhysicsBodies() {
        physicsBody = SKPhysicsBody(edgeLoopFromRect: playableRect)
        physicsBody?.categoryBitMask = PhysicsCategory.Bounds
        physicsBody?.collisionBitMask = PhysicsCategory.Car
        
        let scoreBoundary = SKNode()
        scoreBoundary.position = CGPoint(x: 530, y:1090)
        addChild(scoreBoundary)
        scoreBoundary.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(570,480))
        scoreBoundary.physicsBody!.dynamic = false
        scoreBoundary.physicsBody?.categoryBitMask = PhysicsCategory.Bounds
        
        let innerBoundary1 = SKNode()
        innerBoundary1.position = CGPoint(x: 770, y:525)
        addChild(innerBoundary1)
        innerBoundary1.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(700, 330))
        innerBoundary1.physicsBody!.dynamic = false
        innerBoundary1.physicsBody?.categoryBitMask = PhysicsCategory.Bounds
        
        let innerBoundary2 = SKNode()
        innerBoundary2.position = CGPoint(x: 1290, y:765)
        addChild(innerBoundary2)
        innerBoundary2.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(570, 810))
        innerBoundary2.physicsBody!.dynamic = false
        innerBoundary2.physicsBody?.categoryBitMask = PhysicsCategory.Bounds
    }
    
    func setCheckPoints(){
        let checkpoint1 = SKNode()
        checkpoint1.position = CGPoint(x: 610, y:770)
        addChild(checkpoint1)
        checkpoint1.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(60,200))
        checkpoint1.physicsBody!.dynamic = false
        checkpoint1.physicsBody?.affectedByGravity = false
        checkpoint1.physicsBody?.categoryBitMask = PhysicsCategory.CheckPoint
        checkpoint1.name = "check1"
        
        let checkpoint2 = SKNode()
        checkpoint2.position = CGPoint(x: 320, y:530)
        addChild(checkpoint2)
        checkpoint2.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(200,30))
        checkpoint2.physicsBody!.dynamic = false
        checkpoint2.physicsBody?.affectedByGravity = false
        checkpoint2.physicsBody?.categoryBitMask = PhysicsCategory.CheckPoint
        checkpoint2.name = "check2"
        
        let checkpoint3 = SKNode()
        checkpoint3.position = CGPoint(x: 1680, y:840)
        addChild(checkpoint3)
        checkpoint3.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(200,30))
        checkpoint3.physicsBody!.dynamic = false
        checkpoint3.physicsBody?.affectedByGravity = false
        checkpoint3.physicsBody?.categoryBitMask = PhysicsCategory.CheckPoint
        checkpoint3.name = "check3"
    }
    
    func endGame() {
        AdColony.playVideoAdForZone(customZone, withDelegate: self, withV4VCPrePopup: true, andV4VCPostPopup: true)
    }
    
    func onAdColonyAdAttemptFinished(shown: Bool, inZone zoneID: String) {
        if !shown {
            viewController.performSegueWithIdentifier("backToMenuSegue", sender: self)
        }
    }
    
    func setReward(notification: NSNotification) {
        let reward = notification.object
        lives += reward as! Int
    }
    
    func addObserverGeneric(selector: Selector, name: String) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: selector, name: name, object: nil)
    }
    
    func removeObserverGeneric(name: String) {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: name, object: nil)
    }
    
    func addObservers() {
        addObserverGeneric(#selector(self.setReward(_:)), name: "setReward")
    }
    
    func removeObservers() {
        removeObserverGeneric("setReward")
    }
}

extension GameScene: SKPhysicsContactDelegate {
    func didBeginContact(contact: SKPhysicsContact) {
        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        if collision == PhysicsCategory.Car | PhysicsCategory.CheckPoint {
            let other = contact.bodyA.categoryBitMask == PhysicsCategory.Car ? contact.bodyB.node : contact.bodyA.node
            if other!.name == "check1" {
                if firstTime {
                    firstTime = false
                } else {
                    check1 = true
                }
            } else if other!.name == "check2" {
                check2 = true
            } else if other!.name == "check3"{
                check3 = true
            }
            
            if check1 && check2 && check3{
                laps += 1
                addRecord()
                lapsLabel.text = "Vueltas: \(laps)"
                check1 = false
                check2 = false
                check3 = false
            }
        } else if collision == PhysicsCategory.Car | PhysicsCategory.Bounds {
            crash = crash + 1
            crashLabel.text = "Golpes: \(crash)"
        }
    }
}
