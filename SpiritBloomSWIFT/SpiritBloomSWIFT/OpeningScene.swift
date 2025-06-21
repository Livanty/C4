//
//  OpeningScene.swift
//  SpiritBloomSWIFT
//
//  Created by Livanty Efatania Dendy on 20/06/25.
//

import Foundation
import SpriteKit

class OpeningScene: SKScene, SKPhysicsContactDelegate {
    
    struct PhysicsCategory {
        static let player: UInt32 = 0x1 << 0
        static let door: UInt32 = 0x1 << 1
        static let ground: UInt32 = 0x1 << 2
    }
    
    var character: SKSpriteNode!
    var doorNode: SKSpriteNode?
    var isMovingLeft = false
    var isMovingRight = false
    var activeLeftTouches = Set<UITouch>()
    var activeRightTouches = Set<UITouch>()
    var hasTouchedDoor = false
    
    override func didMove(to view: SKView) {
        backgroundColor = .black
        physicsWorld.contactDelegate = self
        
        // Ambil karakter
        guard let charNode = childNode(withName: "//character") as? SKSpriteNode else {
            fatalError("❌ character not found in scene!")
        }
        character = charNode
        character.physicsBody?.categoryBitMask = PhysicsCategory.player
        character.physicsBody?.contactTestBitMask = PhysicsCategory.door
        character.physicsBody?.collisionBitMask = PhysicsCategory.ground | PhysicsCategory.door
        
        // Simpan referensi pintu, tapi sembunyikan dulu
        if let door = childNode(withName: "//door") as? SKSpriteNode {
            doorNode = door
            door.alpha = 0
            door.isHidden = true
            door.physicsBody = nil  // hapus physics dulu, agar tak bisa disentuh
        }
        
        
        // Ground
        enumerateChildNodes(withName: "ground") { node, _ in
            if node.physicsBody == nil {
                node.physicsBody = SKPhysicsBody(rectangleOf: node.frame.size)
            }
            node.physicsBody?.isDynamic = false
            node.physicsBody?.affectedByGravity = false
            node.physicsBody?.categoryBitMask = PhysicsCategory.ground
            node.physicsBody?.collisionBitMask = PhysicsCategory.player
            node.physicsBody?.contactTestBitMask = PhysicsCategory.player
        }
        
        showOpeningText()
    }
    
    func showOpeningText() {
        let openingText = SKLabelNode(text: "I lost my spark")
        openingText.fontName = "AvenirNext-Bold"
        openingText.fontSize = 32
        openingText.fontColor = .white
        openingText.alpha = 0
        openingText.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(openingText)
        
        openingText.run(SKAction.sequence([
            SKAction.fadeIn(withDuration: 1.0),
            SKAction.wait(forDuration: 1.0),
            SKAction.fadeOut(withDuration: 1.0)
        ])) {
            self.showSecondText()
        }
    }
    
    func showSecondText() {
        let secondText = SKLabelNode(text: "Only you can help me.")
        secondText.fontName = "AvenirNext-Bold"
        secondText.fontSize = 28
        secondText.fontColor = .white
        secondText.alpha = 0
        secondText.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(secondText)
        
        secondText.run(SKAction.sequence([
            SKAction.fadeIn(withDuration: 1.0),
            SKAction.wait(forDuration: 1.0),
            SKAction.fadeOut(withDuration: 1.0)
        ])) {
            self.revealDoor()
        }
    }
    
    func revealDoor() {
        guard let door = doorNode else { return }
        
        door.isHidden = false
        door.alpha = 0
        
        // Tambahkan physics baru saat pintu muncul
        let body = SKPhysicsBody(rectangleOf: door.size)
        body.isDynamic = false
        body.categoryBitMask = PhysicsCategory.door
        body.contactTestBitMask = PhysicsCategory.player
        body.collisionBitMask = 0
        door.physicsBody = body
        
        // Efek fadeIn
        door.run(SKAction.fadeIn(withDuration: 1.0))
    }
    
    override func update(_ currentTime: TimeInterval) {
        guard let body = character.physicsBody else { return }
        let dx: CGFloat = isMovingRight ? 100 : isMovingLeft ? -100 : 0
        body.velocity = CGVector(dx: dx, dy: 0)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            let nodesAtPoint = nodes(at: location)
            
            for node in nodesAtPoint {
                switch node.name {
                case "leftButton":
                    activeLeftTouches.insert(touch)
                    isMovingLeft = true
                case "rightButton":
                    activeRightTouches.insert(touch)
                    isMovingRight = true
                default:
                    break
                }
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            if activeLeftTouches.contains(touch) {
                activeLeftTouches.remove(touch)
                isMovingLeft = !activeLeftTouches.isEmpty
            }
            if activeRightTouches.contains(touch) {
                activeRightTouches.remove(touch)
                isMovingRight = !activeRightTouches.isEmpty
            }
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesEnded(touches, with: event)
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        var playerBody: SKPhysicsBody
        var doorBody: SKPhysicsBody

        if contact.bodyA.categoryBitMask == PhysicsCategory.player {
            playerBody = contact.bodyA
            doorBody = contact.bodyB
        } else {
            playerBody = contact.bodyB
            doorBody = contact.bodyA
        }

        // Transisi hanya jika belum pernah terjadi sebelumnya
        if doorBody.categoryBitMask == PhysicsCategory.door && !hasTouchedDoor {
            hasTouchedDoor = true  // Set flag agar tidak berulang
            character.physicsBody?.velocity = .zero
            character.removeAllActions()

            run(SKAction.wait(forDuration: 0.3)) {
                self.goToOpening2()
            }
        }
    }
    
    
    func goToOpening2() {
        let transition = SKTransition.fade(withDuration: 1.0)
        if let opening2 = SKScene(fileNamed: "Opening2") {
            opening2.scaleMode = .aspectFill
            self.view?.presentScene(opening2, transition: transition)
        } else {
            print("❌ Opening2.sks not found!")
        }
    }
}
