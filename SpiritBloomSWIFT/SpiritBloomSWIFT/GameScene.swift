//
//  GameScene.swift
//  SpiritBloomSWIFT
//
//  Created by Livanty Efatania Dendy on 17/06/25.
//
import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    var character: SKSpriteNode!
    var isMovingLeft = false
    var isMovingRight = false
    var isJumping = false
    var isOnGround = false
    var groundContactCount = 0
    
    var activeLeftTouches = Set<UITouch>()
    var activeRightTouches = Set<UITouch>()
    var activeJumpTouches = Set<UITouch>()
    var lastHitTime: TimeInterval = 0
    
    var hearts: [SKSpriteNode] = []
    var lives = 3
    
    override func didMove(to view: SKView) {
        view.isMultipleTouchEnabled = true
        physicsWorld.contactDelegate = self
        
        guard let charNode = childNode(withName: "character") as? SKSpriteNode else {
            fatalError("❌ character node not found!")
        }
        character = charNode
        
        if character.physicsBody == nil {
            character.physicsBody = SKPhysicsBody(rectangleOf: character.size)
        }
        
        // 🧠 Konfigurasi physics karakter
        character.physicsBody?.isDynamic = true
        character.physicsBody?.allowsRotation = false
        character.physicsBody?.restitution = 0
        character.physicsBody?.friction = 1.0
        character.physicsBody?.categoryBitMask = 1
        character.physicsBody?.collisionBitMask = 2
        character.physicsBody?.contactTestBitMask = 2 | 4  // ⬅️ ground dan obstacle
        
        
        // 🧱 Ground
        enumerateChildNodes(withName: "ground") { node, _ in
            if node.physicsBody == nil {
                node.physicsBody = SKPhysicsBody(rectangleOf: node.frame.size)
            }
            node.physicsBody?.isDynamic = false
            node.physicsBody?.affectedByGravity = false
            node.physicsBody?.categoryBitMask = 2
            node.physicsBody?.collisionBitMask = 1
            node.physicsBody?.contactTestBitMask = 1
        }
        
        // 🚧 Obstacle
        enumerateChildNodes(withName: "obstacle") { node, _ in
            if let sprite = node as? SKSpriteNode {
                sprite.physicsBody = SKPhysicsBody(rectangleOf: sprite.size)
                sprite.physicsBody?.isDynamic = false
                sprite.physicsBody?.categoryBitMask = 4
                sprite.physicsBody?.collisionBitMask = 1
                sprite.physicsBody?.contactTestBitMask = 1
                
                // Tambahkan aksi bergerak otomatis
                let moveRight = SKAction.moveBy(x: 200, y: 0, duration: 1.5)
                let moveLeft = SKAction.moveBy(x: -200, y: 0, duration: 1.5)
                let sequence = SKAction.sequence([moveRight, moveLeft])
                let loop = SKAction.repeatForever(sequence)
                
                sprite.run(loop)
            }
        }
        
        // bubble
        enumerateChildNodes(withName: "bubble") { node, _ in
            // Efek naik-turun
            let moveUp = SKAction.moveBy(x: 0, y: 30, duration: 1)
            let moveDown = SKAction.moveBy(x: 0, y: -30, duration: 1)
            let float = SKAction.sequence([moveUp, moveDown])
            node.run(SKAction.repeatForever(float))
            
            // Setup physics
            if let bubble = node as? SKSpriteNode {
                bubble.physicsBody = SKPhysicsBody(circleOfRadius: bubble.size.width / 2)
                bubble.physicsBody?.isDynamic = false
                bubble.physicsBody?.categoryBitMask = 8
                bubble.physicsBody?.contactTestBitMask = 1
                bubble.physicsBody?.collisionBitMask = 0
            }
        }
        
        
        
        // ❤️ Nyawa
        if let h1 = childNode(withName: "//nyawa1") as? SKSpriteNode,
           let h2 = childNode(withName: "//nyawa2") as? SKSpriteNode,
           let h3 = childNode(withName: "//nyawa3") as? SKSpriteNode {
            hearts = [h1, h2, h3]
        }
        
        // 📷 Kamera
        if let cam = childNode(withName: "cameraNode") as? SKCameraNode {
            self.camera = cam
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        guard let physicsBody = character.physicsBody else { return }
        
        let dx: CGFloat = isMovingRight ? 150 : isMovingLeft ? -150 : 0
        let dy = physicsBody.velocity.dy
        physicsBody.velocity = CGVector(dx: dx, dy: dy)
        
        camera?.position.x = character.position.x
    }
    
    // MARK: - TOUCH HANDLING
    
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
                case "jumpButton":
                    activeJumpTouches.insert(touch)
                    if isOnGround {
                        character.physicsBody?.applyImpulse(CGVector(dx: 50, dy: 800))
                        isJumping = true
                        isOnGround = false
                        
                        // ⬇️ Tambahkan efek sparkle di bawah kaki karakter
                        if let sparkle = SKEmitterNode(fileNamed: "JumpSpark") {
                            let offset = CGPoint(x: 0, y: -character.size.height / 2)
                            sparkle.position = CGPoint(x: character.position.x + offset.x,
                                                       y: character.position.y + offset.y)
                            sparkle.zPosition = 10
                            sparkle.numParticlesToEmit = 15
                            addChild(sparkle)
                            
                            sparkle.run(SKAction.sequence([
                                SKAction.wait(forDuration: 0.5),
                                SKAction.removeFromParent()
                            ]))
                        }
                    }
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
            if activeJumpTouches.contains(touch) {
                activeJumpTouches.remove(touch)
            }
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesEnded(touches, with: event)
    }
    
    // MARK: - PHYSICS CONTACT
    
    func didBegin(_ contact: SKPhysicsContact) {
        let contactA = contact.bodyA
        let contactB = contact.bodyB
        
        let maskA = contactA.categoryBitMask
        let maskB = contactB.categoryBitMask
        
        // Kontak dengan tanah
        if (maskA == 1 && maskB == 2) || (maskA == 2 && maskB == 1) {
            groundContactCount += 1
            isOnGround = true
            print("✅ Contacted ground, count: \(groundContactCount)")
        }
        
        // Kontak dengan obstacle
        if (maskA == 1 && maskB == 4) || (maskA == 4 && maskB == 1) {
            let currentTime = CACurrentMediaTime()
            if currentTime - lastHitTime > 1.0 { // ⏱️ hanya boleh hit lagi setelah 1 detik
                print("💥 Character hit obstacle!")
                lastHitTime = currentTime
                
                if lives > 0 {
                    lives -= 1
                    if let heartToRemove = hearts.popLast() {
                        heartToRemove.removeFromParent()
                    }
                    
                    print("❤️ Remaining lives: \(lives)")
                    
                    if lives == 0 {
                        print("☠️ Game Over")
                        character.removeFromParent()
                    }
                }
            }
        }
        
        
        // Bubble memiliki categoryBitMask = 8
        if (maskA == 1 && maskB == 8) || (maskA == 8 && maskB == 1) {
            print("🫧 Bubble claimed!")
            
            guard let bubble = (maskA == 8 ? contactA.node : contactB.node) as? SKSpriteNode else { return }
            
            // 💨 Efek hilang dari tempat awal (fade out + scale down)
            let fadeOut = SKAction.fadeOut(withDuration: 0.2)
            let scaleDown = SKAction.scale(to: 0.1, duration: 0.2)
            let disappear = SKAction.group([fadeOut, scaleDown])
            
            // ✅ Efek pindah ke sudut kanan atas kamera
            let wait = SKAction.wait(forDuration: 0.2)
            let reappear = SKAction.run {
                guard let cam = self.camera else {
                    print("⚠️ Camera not found.")
                    return
                }
                
                // Buat salinan baru berbasis texture
                let collected = SKSpriteNode(texture: bubble.texture)
                collected.size = CGSize(width: bubble.size.width * 0.5, height: bubble.size.height * 0.5)
                collected.alpha = 0
                collected.position = CGPoint(x: cam.position.x + 300, y: cam.position.y + 120)
                collected.zPosition = 999
                
                cam.addChild(collected)
                collected.position = CGPoint(x: 300, y: 120)
                
                
                // Animasi muncul
                collected.run(SKAction.group([
                    SKAction.fadeIn(withDuration: 0.4),
                    SKAction.scale(to: 1.0, duration: 0.4)
                ]))
                
                
            }
            
            bubble.run(SKAction.sequence([disappear, SKAction.removeFromParent(), wait, reappear]))
        }
        
    }
    
    
    func didEnd(_ contact: SKPhysicsContact) {
        let categoryA = contact.bodyA.categoryBitMask
        let categoryB = contact.bodyB.categoryBitMask
        
        if (categoryA == 1 && categoryB == 2) || (categoryA == 2 && categoryB == 1) {
            groundContactCount -= 1
            if groundContactCount <= 0 {
                isOnGround = false
                groundContactCount = 0
            }
        }
    }
}
