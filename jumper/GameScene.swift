//
//  GameScene.swift
//  jumper
//
//  Created by Thierry Skoda on 2015-02-28.
//  Copyright (c) 2015 thierry skoda. All rights reserved.
//

import SpriteKit

let ballName = "jumpy"

class GameScene: SKScene {
    override func didMoveToView(view: SKView) {
        
        super.didMoveToView(view);
        
        /* Setup your scene here */
        let myLabel = SKLabelNode(fontNamed:"Chalkduster")
        myLabel.text = "Hello, World!";
        myLabel.fontSize = 65;
        myLabel.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame));
        
        self.setWorldPhysics();
        
        self.addChild(myLabel)
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        /* Called when a touch begins */
        
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            
            let sprite = SKSpriteNode(imageNamed:"Spaceship")
            
            sprite.xScale = 0.5
            sprite.yScale = 0.5
            sprite.position = location
            
            let action = SKAction.rotateByAngle(CGFloat(M_PI), duration:1)
            
            sprite.runAction(SKAction.repeatActionForever(action))
            
            self.addChild(sprite)
        }
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
    
    func setWorldPhysics() {
        println("Setting the world physics");
        
        self.physicsWorld.gravity = CGVectorMake(0, 0);
    }
}
