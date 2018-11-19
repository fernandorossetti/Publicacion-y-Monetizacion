//
//  MenuViewController.swift
//  NextURacing
//
//  Created by fernando rossetti on 4/4/17.
//  Copyright © 2017 NextU. All rights reserved.
//

import UIKit
import SpriteKit

class MenuViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let scene = MenuScene(size:CGSize(width: 2048, height: 1536))
        
        scene.viewController = self
        
        // Configure the view.
        let skView = self.view as! SKView
        skView.showsFPS = true
        skView.showsNodeCount = true
        
        /* Sprite Kit applies additional optimizations to improve rendering performance */
        skView.ignoresSiblingOrder = true
        
        /* Set the scale mode to scale to fit the window */
        scene.scaleMode = .AspectFill
        
        skView.presentScene(scene)
        
        //        skView.showsPhysics = true
    }
    
    override func viewDidAppear(animated: Bool) {
        let defaults = NSUserDefaults.standardUserDefaults()
        let name = defaults.stringForKey("username")
        
        if name == nil {
            let alert = UIAlertController(title: "Next U Racing", message: "Ingresa tu nombre", preferredStyle: .Alert)
            alert.addTextFieldWithConfigurationHandler { (textField) in
                textField.placeholder = "Username"
            }
            
            let okAction = UIAlertAction(title: "Guardar", style: .Default) { (action) in
                if let text = alert.textFields![0].text {
                    if !text.isEmpty {
                        let defaults = NSUserDefaults.standardUserDefaults()
                        defaults.setValue(text, forKey: "username")
                    }
                }
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
            
            alert.addAction(okAction)
            alert.addAction(cancelAction)
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    override func shouldAutorotate() -> Bool {
        return true
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return .AllButUpsideDown
        } else {
            return .All
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    @IBAction func unwindToMenu(segue: UIStoryboardSegue) {}
}