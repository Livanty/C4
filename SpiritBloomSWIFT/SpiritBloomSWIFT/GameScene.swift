//
//  GameScene.swift
//  SpiritBloomSWIFT
//
//  Created by Livanty Efatania Dendy on 17/06/25.
//

import SpriteKit


class GameScene: SKScene {
    var externalMovementState: ExternalMovementState?
    var character: SKSpriteNode!
    
    override func didMove(to view: SKView) {
        print("GameScene loaded")
        self.size = view.bounds.size
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        physicsWorld.gravity = CGVector(dx: 0, dy: -9.8) // gravitasi bumi standar

        createGrounds()
        createCharacter()
        
        let cameraNode = SKCameraNode()
        self.camera = cameraNode
        addChild(cameraNode)
    }

    override func update(_ currentTime: TimeInterval) {
        print("Character y: \(character.position.y)")
        camera?.position = CGPoint(x: character.position.x, y: 0)


        guard let state = externalMovementState else { return }

        if state.isMovingRight.wrappedValue {
                character.physicsBody?.velocity.dx = 150
                moveGrounds(toLeft: true)
            } else if state.isMovingLeft.wrappedValue {
                character.physicsBody?.velocity.dx = -150
                moveGrounds(toLeft: false)
            } else {
                character.physicsBody?.velocity.dx = 0
            }
    }
    
    func createCharacter() {
        character = SKSpriteNode(imageNamed: "character")
        

      

        character.physicsBody = SKPhysicsBody(rectangleOf: character.size)
        character.physicsBody?.affectedByGravity = true
        character.physicsBody?.allowsRotation = false
        character.physicsBody?.restitution = 0
        character.physicsBody?.friction = 1.0
        character.physicsBody?.categoryBitMask = 1
        character.physicsBody?.collisionBitMask = 2

        addChild(character)
    }


    func createGrounds() {
        let groundWidth: CGFloat = 932.67
        let groundHeight: CGFloat = 82.67
        let numberOfGrounds = Int(ceil(3000 / groundWidth)) + 1

        for i in 0..<numberOfGrounds {
            let ground = SKSpriteNode(imageNamed: "ground")
            ground.name = "Ground"
            ground.size = CGSize(width: groundWidth, height: groundHeight)
            ground.anchorPoint = CGPoint(x: 0.5, y: 0.0)

            ground.position = CGPoint(
                x: CGFloat(i) * groundWidth,
                y: -self.size.height / 2 - 2
            )

            ground.physicsBody = SKPhysicsBody(rectangleOf: ground.size)
            ground.physicsBody?.isDynamic = false
            ground.physicsBody?.affectedByGravity = false
            ground.physicsBody?.categoryBitMask = 2
            ground.physicsBody?.collisionBitMask = 1

            addChild(ground)
        }
    }


    func moveGrounds(toLeft: Bool) {
        enumerateChildNodes(withName: "Ground") { (node, _) in
            let offset: CGFloat = 2
            let newX = node.position.x + (toLeft ? -offset : offset)

            // Hanya izinkan geser jika dalam batas kiri-kanan
           
        }
    }
}


