//
//  MenuScene.swift
//  NextURacing
//
//  Created by fernando rossetti on 4/4/17.
//  Copyright © 2017 NextU. All rights reserved.
//

import SpriteKit
import GoogleMobileAds

class MenuScene: SKScene, GADInterstitialDelegate {
    
    var button: SKSpriteNode!
    var car: SKSpriteNode!
    
    var banner: GADBannerView!
    var intersitial: GADInterstitial!
    
    var viewController: MenuViewController!
    
    override func didMoveToView(view: SKView) {
        setLabels()
        setButton()
        addBanner()
        loadRequest()
        loadIntersitial()
        setCar()
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            
            if button.containsPoint(location) {
                showIntersitial()
            }
        }
    }
    
    func setLabels() {
        createLabel("Next Racing", position: CGPoint(x: 155, y: 1200), horizontal: .Left)
        let defaults = NSUserDefaults.standardUserDefaults()
        let name = defaults.stringForKey("username")
        let laps = defaults.stringForKey("laps")
        createLabel(name != nil ? name! : "user1", fontSize: 50.0, position: CGPoint(x: 1355, y: 1300), horizontal: .Left)
        createLabel(laps != nil ? "Mejor puntaje: \(laps!)" : "Mejor puntaje: 0", position: CGPoint(x: 1055, y: 950), horizontal: .Left)
    }
    
    func createLabel(text: String, fontSize: CGFloat = 100, position: CGPoint, horizontal: SKLabelHorizontalAlignmentMode) {
        let label = SKLabelNode(fontNamed: "Avenir-Heavy")
        label.text = text
        label.fontColor = UIColor.whiteColor()
        label.fontSize = fontSize
        label.zPosition = 100
        label.horizontalAlignmentMode = horizontal
        label.verticalAlignmentMode = .Top
        label.position = position
        addChild(label)
    }
    
    func setButton() {
        button = SKSpriteNode(imageNamed: "play")
        button.size = CGSize(width: 400.0, height: 150.0)
        button.position = CGPoint(x: 355, y: 900)
        addChild(button)
    }
    
    func setCar() {
        car = SKSpriteNode(imageNamed: "car")
        car.position = CGPoint(x: 1000, y: 1150)
        addChild(car)
    }
    
    func loadRequest() {
        let request = GADRequest()
        request.testDevices = [kGADSimulatorID]
        banner.loadRequest(request)
    }
    
    func addBanner() {
        banner = GADBannerView(adSize: kGADAdSizeFullBanner)
        let center = (view!.bounds.width / 2) - (banner.frame.size.width / 2)
        banner.frame = CGRectMake(center, view!.bounds.height - banner.frame.size.height, banner.frame.size.width, banner.frame.size.height)
        banner.adUnitID = "ca-app-pub-2747210660047763/8164035536"
        banner.rootViewController = viewController
        view!.addSubview(banner)
    }
    
    func showIntersitial() {
        let move = SKAction.moveToX(2150, duration: 2.5)
        car.runAction(SKAction.sequence([move, SKAction.runBlock({ 
            if self.intersitial.isReady {
                self.intersitial.presentFromRootViewController(self.viewController)
            } else {
                print("fallo la carga")
            }
        })]))
    }
    
    func loadIntersitial() {
        let requestIntersitial = GADRequest()
        intersitial = GADInterstitial(adUnitID: "ca-app-pub-2747210660047763/7884833935")
        requestIntersitial.testDevices = [kGADSimulatorID]
        intersitial.delegate = self
        intersitial.loadRequest(requestIntersitial)
    }
    
    override func update(currentTime: CFTimeInterval) {
    }
    
    func interstitialDidDismissScreen(ad: GADInterstitial!) {
        car.position = CGPoint(x: 1000, y: 1150)
        loadIntersitial()
        self.viewController.performSegueWithIdentifier("showGameSceneSegue", sender: self)
    }
}
