//
//  GameScene.swift
//  SpiritBloomSWIFT
//
//  Created by Livanty Efatania Dendy on 17/06/25.
//
import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    var character: SKSpriteNode!
    var cameraNode: SKCameraNode!
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
    var bubbleCount = 0
    
    var door: SKSpriteNode?
    let targetBubbles = 1
    
    
    func transformEnemyToFriendly(_ enemy: SKSpriteNode) {
        enemy.texture = SKTexture(imageNamed: "enemy 2") // ganti dengan nama sprite musuh hijau
        enemy.userData?.setValue(true, forKey: "isFriendly")
        print("✨ Musuh berubah jadi baik!")
    }
    
    
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
        character.physicsBody?.contactTestBitMask = 2 | 4  // ⬅️ ground dan enemy
        
        
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
        
        // 🚧 enemy
        
        enumerateChildNodes(withName: "enemy") { node, _ in
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
                
                sprite.userData = NSMutableDictionary()
                sprite.userData?.setValue(false, forKey: "isFriendly") // default: jahat
                
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
        // pintu
        
        if let hiddenDoor = self.childNode(withName: "door") as? SKSpriteNode {
            hiddenDoor.isHidden = true
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
        self.triggerSparkHitTest()

    }
    
    func triggerSparkHitTest() {
        enumerateChildNodes(withName: "enemy") { node, _ in
            if let enemy = node as? SKSpriteNode {
                let distance = hypot(enemy.position.x - self.character.position.x,
                                     enemy.position.y - self.character.position.y)
                let isFriendly = enemy.userData?.value(forKey: "isFriendly") as? Bool ?? false
                if distance < 100 && !isFriendly {
                    self.transformEnemyToFriendly(enemy)
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
        
        // Kontak dengan enemy
        
        if (maskA == 1 && maskB == 4) || (maskA == 4 && maskB == 1) {
            let enemyNode = (maskA == 4 ? contactA.node : contactB.node) as? SKSpriteNode
            let isFriendly = enemyNode?.userData?.value(forKey: "isFriendly") as? Bool ?? false
            if isFriendly {
                print("🟢 Menyentuh musuh baik, tidak terjadi apa-apa")
                return
            }
            
            // Lanjutkan seperti biasa kalau masih jahat
            let currentTime = CACurrentMediaTime()
            if currentTime - lastHitTime > 1.0 {
                print("💥 Character hit enemy!")
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
            
            print("Showing Bubble on top right")
            
            // 💨 Bubble hilang dari tempat awal
            let fadeOut = SKAction.fadeOut(withDuration: 0.2)
            let scaleDown = SKAction.scale(to: 0.1, duration: 0.2)
            let disappear = SKAction.group([fadeOut, scaleDown])
            
            // ✅ Munculkan kembali di pojok kanan atas kamera
            let wait = SKAction.wait(forDuration: 0.2)
            let reappear = SKAction.run {
                guard let cam = self.camera else {
                    print("⚠️ Camera not found.")
                    return
                }
                
                
                let collected = SKSpriteNode(texture: bubble.texture)
                collected.size = CGSize(width: bubble.size.width * 1, height: bubble.size.height * 1)
                collected.alpha = 1
                collected.zPosition = 999
                
                // Koordinat relatif terhadap kamera (misalnya pojok kanan atas)
                let spacing: CGFloat = 60
                let offsetX: CGFloat = 200 - CGFloat(self.bubbleCount) * spacing
                let offsetY: CGFloat = 120  // Jarak dari atas kamera
                
                collected.position = CGPoint(x: offsetX, y: offsetY)
                cam.addChild(collected)
                
                
                print("✅ Collected bubble placed at \(collected.position) in camera")
                
            }
            bubble.run(SKAction.sequence([reappear, disappear, SKAction.removeFromParent(), wait]))
            
            self.bubbleCount += 1
            
            if self.bubbleCount == self.targetBubbles {
                print("🔓 All bubbles collected! Showing the door.")
                
                // Munculkan node pintu (pastikan sudah ada di scene dengan name "door", tapi hidden dulu)
                if let doorNode = self.childNode(withName: "door") as? SKSpriteNode {
                    doorNode.isHidden = false
                    self.door = doorNode
                    
                    // Tambahkan physics untuk deteksi tabrakan
                    if doorNode.physicsBody == nil {
                        doorNode.physicsBody = SKPhysicsBody(rectangleOf: doorNode.size)
                        doorNode.physicsBody?.isDynamic = false
                        doorNode.physicsBody?.categoryBitMask = 16
                        doorNode.physicsBody?.contactTestBitMask = 1
                        doorNode.physicsBody?.collisionBitMask = 0
                    }
                    
                    
                }
            }
            
            
            
        }
        if (maskA == 1 && maskB == 16) || (maskA == 16 && maskB == 1) {
            print("🚪 Character reached the door! Transitioning...")
            
            // Ganti ke scene lain (pastikan kamu punya file scene baru bernama NextLevelScene.swift)
            if let nextScene = SKScene(fileNamed: "LastScene") {
                nextScene.scaleMode = .aspectFill
                let transition = SKTransition.fade(withDuration: 1.0)
                self.view?.presentScene(nextScene, transition: transition)
            }
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
