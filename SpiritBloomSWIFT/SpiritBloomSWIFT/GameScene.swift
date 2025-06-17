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
    }

    override func update(_ currentTime: TimeInterval) {
        print("Character y: \(character.position.y)")

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
        character.setScale(0.35)

        // Posisi Y karakter sedikit di atas ground (agar jatuh dan mendarat)
        character.position = CGPoint(
            x: 0,
            y: -self.size.height / 2 + 500 + character.size.height / 2
        )

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
        for i in 0...3 {
            let ground = SKSpriteNode(imageNamed: "ground")
            ground.name = "Ground"
            ground.size = CGSize(width: self.size.width, height: 510)
            ground.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            ground.position = CGPoint(x: CGFloat(i) * ground.size.width, y: -self.size.height / 2 + ground.size.height / 2)

            
            print("Ground \(i) position: \(ground.position)")
            
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
            node.position.x += toLeft ? -offset : offset

            if toLeft && node.position.x < -self.size.width {
                node.position.x += self.size.width * 3
            } else if !toLeft && node.position.x > self.size.width * 2 {
                node.position.x -= self.size.width * 3
            }
        }
    }
}


