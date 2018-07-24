//
//  GameScene.swift
//  TrashProject
//
//  Created by Sydrah Al-saegh on 7/23/18.
//  Copyright © 2018 Sydrah Al-saegh. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // Define collision cetegories
    private let pieceCategory  : UInt32 = 0x1 << 0
    private let bucketCategory : UInt32 = 0x1 << 1
    
    private var label : SKLabelNode?
    
    private var caughtTrash : SKNode?
    
    private let trashImageNames = [
        "diapers",
        "straw"
        
        
        
        //add more types of trash, also add recycling and compost image names, corrosponds to assets/pics
    ] 
    
    private let recycleImageNames = [
        "can",
        "car",
        "carpet",
        "drink",
        "etrash",
        "fluolight",
        "fridge",
        "mattress",
        "paintcans",
        "paper",
        "tires"
        
        //add more types of trash, also add recycling and compost image names, corrosponds to assets/pics
    ]
    
    
    override func didMove(to view: SKView) {
        // Set self as the contact delegate. didBegin will be called when collisions occur.
        physicsWorld.contactDelegate = self
        
        // Slow down gravity
        physicsWorld.gravity = CGVector(dx: 0, dy: -1.5)
        
        //Adds three buckets
        addBucket(bucketName: "trashBucket", startingPosition: CGPoint(x: -300, y: -600), size: CGPoint(x: 200, y: 300))
        addBucket(bucketName: "recyclingBucket", startingPosition: CGPoint(x: -100, y: -600), size: CGPoint(x: 200, y: 300))
        addBucket(bucketName: "compostBucket", startingPosition: CGPoint(x: 100, y: -600), size: CGPoint(x: 200, y: 300))
        
        //For testing purposes, add one of each kind of trash, later randomize it
        var i = 0
        for trashImageName in trashImageNames {
            addPiece(imageName:trashImageName, nodeName: "trash", startingPosition: CGPoint(x:75 * i, y: 600))
            i += 1
        }
        
        // Get label node from scene and store it for use later
        self.label = self.childNode(withName: "//titleLabel") as? SKLabelNode
        if let label = self.label {
            label.alpha = 0.0
            label.run(SKAction.fadeIn(withDuration: 2.0))
        }
    }
    //Adds a piece of trash/recycling/compost to scene. Image name is the Asset picture name.
    // Node name should be "trash" or "recycling" or "compost"
    func addPiece(imageName: String, nodeName: String, startingPosition: CGPoint) {
        let piece = SKSpriteNode(imageNamed: imageName)
        piece.name = nodeName
        piece.position = startingPosition
        piece.physicsBody = SKPhysicsBody(texture: piece.texture!,
                                          size: piece.texture!.size())
        piece.physicsBody?.categoryBitMask = pieceCategory
        piece.physicsBody?.contactTestBitMask = pieceCategory | bucketCategory
        addChild(piece)
    }
    
    //Bucket name should be "recyclingBucket" "trashBucket" "compostBucket"
    //Add bucket
    func addBucket(bucketName: String, startingPosition: CGPoint, size: CGPoint) {
        var splinePoints = [CGPoint(x: 0, y: size.y),
                            CGPoint(x: 0.20 * size.x, y: 0),
                            CGPoint(x: 0.80 * size.x, y: 0),
                            CGPoint(x: size.x, y: size.y)]
        let bucket = SKShapeNode(splinePoints: &splinePoints,
                                 count: splinePoints.count)
        bucket.name = bucketName
        bucket.position = startingPosition
        bucket.lineWidth = 5
        bucket.strokeColor = .white
        bucket.physicsBody = SKPhysicsBody(edgeChainFrom: bucket.path!)
        bucket.physicsBody?.restitution = 0.25
        bucket.physicsBody?.isDynamic = false
        bucket.physicsBody?.categoryBitMask = bucketCategory
        addChild(bucket)
    }
    
    // called when drag begins
    func touchBegin(atPoint pos : CGPoint) {
        let node = atPoint(pos)
        let nodeName = node.name
        //don't pick up buckets
        if nodeName == "trash" || nodeName == "recycling" || nodeName == "compost" {
            caughtTrash = node
        }
    }
    
    // called when finger moves during drag
    func touchMoved(toPoint pos : CGPoint) {
        if let haveCaughtTrash = caughtTrash {
            haveCaughtTrash.position = pos
        }
    }
    
    // called when drag ends
    func touchEnd(atPoint pos : CGPoint) {
        caughtTrash = nil
    }
    
    // called by system when drag begins
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            touchBegin(atPoint:touch.location(in: self))
        }
    }
    
    // called by system when drag moves
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            touchMoved(toPoint:touch.location(in: self))
        }
    }
    
    // called by system when drag ends
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            touchEnd(atPoint:touch.location(in: self))
        }
    }
    
    // called by system when drag is cancelled like when a phone call is recived
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            touchEnd(atPoint:touch.location(in: self))
        }
    }
    
    // collision handeler
    func didBegin(_ contact: SKPhysicsContact) {
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        //if a piece hits its corrosponding bucket, it will disapear.
        if firstBody.categoryBitMask == pieceCategory &&
            secondBody.categoryBitMask == bucketCategory {
            let pieceName = firstBody.node!.name!
            let bucketName = secondBody.node!.name!
            let isCorrectBucket = pieceName + "Bucket" == bucketName
            if isCorrectBucket {
                firstBody.node!.removeFromParent()
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}

