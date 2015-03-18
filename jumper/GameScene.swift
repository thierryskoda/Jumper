//
//  GameScene.swift
//  jumper
//
//  Created by Thierry Skoda on 2015-02-28.
//  Copyright (c) 2015 thierry skoda. All rights reserved.
//

import SpriteKit

let playerName = "jumpy"
let backgroundName = "woodTexture"


class GameScene: SKScene, SKPhysicsContactDelegate {
    
    let player = SKSpriteNode(imageNamed: "jumpy.png")
    let background = SKSpriteNode(imageNamed: backgroundName)
    let background2 = SKSpriteNode(imageNamed: backgroundName)
    
    struct lineProperties {
        static let lineName = "line"
        static let lineImageName = "lineClip"
        static let scaleX : CGFloat = 0.2
        static let scaleY : CGFloat = 0.2
    }
    
    struct birdProperties {
        static let birdName = "bird"
        static let birdImageName = "smallBird"
        static let scaleX : CGFloat = 0.250
        static let scaleY : CGFloat = 0.120
        static let mass : CGFloat = 0.005
    }
    
    struct PhysicsCategory {
        static let None      : UInt32 = 0
        static let All       : UInt32 = UInt32.max
        static let Bird      : UInt32 = 0b1
        static let Player    : UInt32 = 0b10
        static let Line      : UInt32 = 0b100
        static let Wall      : UInt32 = 0b1000
    }
    
    override init(size: CGSize) {

        super.init(size: size)
        
        println("init the scene with size : \(size.width) - \(size.height)")
        
        self.anchorPoint = CGPointMake(0.5, 0.5)
        initBackground()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToView(view: SKView) {
        println("DidMoveToView of GameScene")
        super.didMoveToView(view)
        
        //self.physicsBody = SKPhysicsBody(edgeFromPoint: CGPointMake(-self.size.width/2, self.size.height/2),toPoint: CGPointMake(-self.size.width/2, -self.size.height/2))
        
        println("Size of the scene : \(self.frame.width) - \(self.frame.height)")
        
        setWorldPhysics()
        
        createPlayer()
        
        runAction(SKAction.repeatActionForever(
            SKAction.sequence([
                SKAction.runBlock({ self.addBird() }),
                SKAction.waitForDuration(2.0)
                ])
            ))

    }
    
    /* INIT THE SCENE */
    
    func setWorldPhysics() {
        println("Setting the world physics");
        
        // les contours fond rebondir
        self.physicsBody = SKPhysicsBody(edgeLoopFromRect: CGRectMake(-self.size.width/2, -self.size.height/2, self.size.width, self.size.height*2))

        self.name = "wall"
        self.physicsBody?.categoryBitMask = PhysicsCategory.Wall
        self.physicsBody?.collisionBitMask = PhysicsCategory.All
        self.physicsBody?.contactTestBitMask = PhysicsCategory.Player | PhysicsCategory.Bird
        self.physicsWorld.gravity = CGVectorMake(0, -5);
        self.physicsWorld.contactDelegate = self;
    }
    
    func initBackground() {
        
        background.position = CGPointMake(0, 0)
        background.zPosition = -20;
        addChild(background)
        
        background2.position = CGPointMake(0, background.size.height - 1)
        background2.zPosition = -20;
        addChild(background2)
    }
    
    func createPlayer() {
        player.position = CGPointMake(0, 0)
        player.name = playerName
        
        player.physicsBody = SKPhysicsBody(circleOfRadius: player.frame.size.width/2)
        player.physicsBody!.angularDamping = 0.3
        player.physicsBody!.restitution = 1.0
        player.physicsBody!.friction = 0.0
        player.physicsBody!.linearDamping = 0.3
        player.physicsBody!.dynamic = true
        player.physicsBody!.allowsRotation = true
        player.physicsBody!.affectedByGravity = true
        
        // Contact
        player.physicsBody?.categoryBitMask = PhysicsCategory.Player
        player.physicsBody?.contactTestBitMask = PhysicsCategory.Line
        player.physicsBody?.collisionBitMask = PhysicsCategory.Line | PhysicsCategory.Bird | PhysicsCategory.Wall
        
        addChild(player)
        
        player.physicsBody?.applyImpulse(CGVectorMake(5, 0))
    }
    
    /* AUTOMATIC METHOD CALL BY THE SCENE */
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        /* Called when a touch begins */
        
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            
            if( childNodeWithName("line") == nil) {
                // On crée la ligne
                createLine(location)
            }
        }
    }
   
    var lastPlayerPosY : CGFloat = 0.0
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        
//        background.position.y += -player.position.y/60
//        
//        println("background Y : \(background.position.y)")
//        background.position.x = player.position.x/10
//        
//        if(background.position.y <= (-background.size.height/2 + 300)) {
//            println("We replace the background")
//            background.position = CGPointMake(background.position.x, background.position.y + (background.size.height/2))
//        }
//
        var movementSpeed : CGFloat = fabs(lastPlayerPosY) - fabs(player.position.y)
        
        background.position = CGPointMake(background.position.x, background.position.y - 1)
        background2.position = CGPointMake(background2.position.x, background2.position.y - 1)
    
        
        if(background.position.y < -background.size.height)
        {
            background.position = CGPointMake(background2.position.x, background.position.y + background2.size.height )
        }
        
        if(background2.position.y < -background2.size.height)
        {
            background2.position = CGPointMake(background.position.x, background2.position.y + background.size.height)
            
        }
        
        lastPlayerPosY = player.position.y
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        let firstNode : SKSpriteNode = firstBody.node as SKSpriteNode
        var secondNode : SKNode = secondBody.node!
        
        if(secondBody.node?.name == "wall") {
            if(firstBody.node?.name == birdProperties.birdName) {
                if(firstNode.position.y <= -self.frame.size.height/3) {
                    firstNode.removeFromParent()
                }
            }
        } else {
            
            secondNode = secondBody.node as SKSpriteNode
            
            println("Contact between a \(firstNode.name) and \(secondNode.name)")
            println("Contact between a \(firstBody.categoryBitMask) and \(secondBody.categoryBitMask)")
            
            if((firstBody.categoryBitMask == PhysicsCategory.Player && secondBody.categoryBitMask == PhysicsCategory.Line) ||
            (firstBody.categoryBitMask == PhysicsCategory.Line && secondBody.categoryBitMask == PhysicsCategory.Player)) {
                playerAndThisLineCollision(secondBody.node as SKSpriteNode)
            }
        }
    }
    
    /* GAME FUNCTION */
    
    
    func createLine(location:CGPoint) {
        
        // On crée la ligne (trempoline)
        let line = SKSpriteNode(imageNamed: lineProperties.lineImageName)

        line.name = lineProperties.lineName
        line.xScale = lineProperties.scaleX
        line.yScale = lineProperties.scaleY
        line.position = location
        
        // Physics
        line.physicsBody = SKPhysicsBody(rectangleOfSize: line.frame.size)
        line.physicsBody?.dynamic = false
        
        // Contact
        line.physicsBody?.categoryBitMask = PhysicsCategory.Line
        line.physicsBody?.contactTestBitMask = PhysicsCategory.Player
        line.physicsBody?.collisionBitMask = PhysicsCategory.Player | PhysicsCategory.Wall
        
        addChild(line)
        
        // Actions
        line.runAction(SKAction.sequence([SKAction.waitForDuration(2), SKAction.removeFromParent()]))

    }
    
    func addBird() {
        let bird = SKSpriteNode(imageNamed: birdProperties.birdImageName)
        
        bird.xScale = birdProperties.scaleX
        bird.yScale = birdProperties.scaleY
        bird.name = birdProperties.birdName
        bird.position = CGPointMake(random(min: -self.frame.size.width/2, max: self.frame.size.width/2), self.frame.size.height/2)
        
        bird.physicsBody = SKPhysicsBody(rectangleOfSize: bird.frame.size)
        bird.physicsBody?.mass = birdProperties.mass
        bird.physicsBody?.applyImpulse(CGVectorMake(0, 0))
        
        // Contact 
        bird.physicsBody?.categoryBitMask = PhysicsCategory.Bird
        bird.physicsBody?.contactTestBitMask = PhysicsCategory.Player
        bird.physicsBody?.collisionBitMask = PhysicsCategory.Player | PhysicsCategory.Wall
        
        addChild(bird)
    }
    
    func playerAndThisLineCollision(line :SKSpriteNode) {
        
        // Add the emitterSpark
        let sparkEmmitterPath:NSString = NSBundle.mainBundle().pathForResource("spark", ofType: "sks")!
        let sparkEmmiter = NSKeyedUnarchiver.unarchiveObjectWithFile(sparkEmmitterPath) as SKEmitterNode
        
        sparkEmmiter.position = player.position
        sparkEmmiter.name = "spark"
        sparkEmmiter.zPosition = 1
        sparkEmmiter.targetNode = self
        
        addChild(sparkEmmiter)
        sparkEmmiter.runAction(SKAction.sequence([SKAction.waitForDuration(1),SKAction.removeFromParent()]))
        
        // Apply the jump of the line
        player.physicsBody?.applyImpulse(CGVectorMake(0, 35))
        
        // Remove the line
        line.removeFromParent()
    }
    
    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    func random(#min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max - min) + min
    }
    
    func showThisNumber(number: CGFloat) {
        println("the number : \(number)")
    }
    
    func showThoseTwoNumber(one: CGFloat, two: CGFloat) {
        println("the first and the second number : \(one) - \(two)")
    }
}
