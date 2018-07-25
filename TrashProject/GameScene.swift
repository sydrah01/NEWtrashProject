//
//  GameScene.swift
//  TrashProject
//
//  Created by Sydrah Al-saegh on 7/23/18.
//  Copyright © 2018 Sydrah Al-saegh. All rights reserved.
//

import SpriteKit
import GameplayKit

// The type of a piece.
enum PieceType: String {
    case compost = "compost"
    case recycling = "recycling"
    case trash = "trash"
}

// An individual piece of trash
struct Piece {
    let name: String
    let type: PieceType
}

class GameScene: SKScene,  SKPhysicsContactDelegate {
    
    // Define collision cetegories
    private let pieceCategory  : UInt32 = 0x1 << 0
    private let bucketCategory : UInt32 = 0x1 << 1
    
    private var label : SKLabelNode?
    
    private var livesLabel : SKLabelNode!
    private var scoreLabel : SKLabelNode!
    
    private var lives : Int = 0 {
        didSet {
            livesLabel.text = "Lives: \(lives)"
        }
    }
    
    private var score: Int = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    private var caughtTrash : SKNode?
    
    var i : Int = 0
    
    var numCorrect: Int = 0
    var numIncorrect: Int = 0
    
    private let trashImageNames = ["diapers", "straw"]
    
    private let recycleImageNames = [
        "can", "car", "carpet", "drink", "etrash", "fluolight", "fridge", "mattress", "paintcans", "paper","tires"]
    
    
    private let compostImageNames = [
        "peanuts", "appleCore", "avacadoPits", "eggCarton", "eggShells", "foosWaste", "leaf", "muffinWrapper", "peanuts", "toothpick", "pizzaBox"
        ]
   
    private let allPieces = [
        // Trash
        Piece(name: "diapers", type:.trash),
        Piece(name: "straw", type:.trash),
        
        // Recycling
        Piece(name: "can", type:.recycling),
        
        // Compost
        Piece(name: "peanuts", type:.compost)
    ]
    
    override func didMove(to view: SKView) {
        
        if(numIncorrect < 3){
            setupGameWorld()
        
        
            //For testing purposes, add one of each kind of trash, later randomize it
            // dropAllTrash()
            
            
            // Start dropping piecese
            startDroppingPieces()

        
        
       
        var highScore: Int{
            get {
                return UserDefaults.standard.integer(forKey: "highScore")
            }
        set {
           UserDefaults.standard.set(newValue, forKey: "highScore")
            }
        }
        
    }
        else{
            
        }
    }
    
    func setupGameWorld() {
        
        setupLabels()
        
        lives = 3
        score = 0
        
        //this is (supposed to be) a wall to the garbage doesnt go past the trash cans
        // self.physicsBody = [SKPhysicsBody, bodyWithEdgeLoopFromRect,:self.frame];
        
        // Set self as the contact delegate. didBegin will be called when collisions occur.
        physicsWorld.contactDelegate = self
        
        
        // Slow down gravity
        physicsWorld.gravity = CGVector(dx: 0, dy: -1.5)
        
        
        //Adds three buckets
        addBucket(bucketName: "trashBucket", startingPosition: CGPoint(x: -300, y: -600), size: CGPoint(x: 200, y: 300))
        addBucket(bucketName: "recyclingBucket", startingPosition: CGPoint(x: -100, y: -600), size: CGPoint(x: 200, y: 300))
        addBucket(bucketName: "compostBucket", startingPosition: CGPoint(x: 100, y: -600), size: CGPoint(x: 200, y: 300))
    }
    
    func startDroppingPieces() {
        let wait = SKAction.wait(forDuration: 0.5) //change drop speed here
        let block = SKAction.run({
            [unowned self] in
            self.addRandomPiece()
        })
        let sequence = SKAction.sequence([wait,block])
        
        run(SKAction.repeatForever(sequence), withKey: "pieceDropper")
    }
    
    ///////////////////////////////////////////////////////////////CLASS BREAKS HERE
    
    func addRandomPiece() {
        // Pick a random piece
        let piece = allPieces[Int(arc4random_uniform(UInt32(allPieces.count)))]
        
        // Picks a random number between frame.minX and frame.maxX
        let x = CGFloat(arc4random_uniform(UInt32(frame.width))) + frame.minX
        
        addPiece(imageName: piece.name,
                 nodeName: piece.type.rawValue,
                      startingPosition: CGPoint(x:x, y: frame.maxY))

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
    
    func setupLabels() {
        livesLabel = SKLabelNode(fontNamed: "Chalkduster")
        livesLabel.fontSize = 65
        livesLabel.fontColor = .white
        livesLabel.position = CGPoint(x: frame.minX + 550, y: frame.maxY - 50)
        
        addChild(livesLabel)
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.fontSize = 65
        scoreLabel.fontColor = .green
        scoreLabel.position = CGPoint(x: frame.maxX - 550, y: frame.maxY - 50)
        
        addChild(scoreLabel)
    }
        
    /*    // Get label node from scene and store it for use later
        self.label = self.childNode(withName: "//titleLabel") as? SKLabelNode
        if let label = self.label {
            label.alpha = 0.0
            label.run(SKAction.fadeIn(withDuration: 2.0))
        }
    }*/
        
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
                score += 1 //adding one point
            }
            
        }
            
            
            //But Im still working on the randomizer so ill upload that later
      
    }
    
    func dropAllTrash(){
        var i = 0
        for trashImageName in trashImageNames {
            addPiece(imageName:trashImageName, nodeName: "trash", startingPosition: CGPoint(x:75 * i, y: 650))
            i += 1
        }
        //var i = 0
        for compostImageName in compostImageNames {
            addPiece(imageName:compostImageName, nodeName: "compost", startingPosition: CGPoint(x:35 * i, y: 600))
            i += 1
        }
        //   var i = 0
        for recyclingImageName in recycleImageNames {
            addPiece(imageName:recyclingImageName, nodeName: "recycling", startingPosition: CGPoint(x:35 * i, y: 600))
            i += 1
        }
    }
    //hello

    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
    

}



