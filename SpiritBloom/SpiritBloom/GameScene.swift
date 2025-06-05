//
//  GameScene.swift
//  SpiritBloom
//
//  Created by Livanty Efatania Dendy on 05/06/25.
//
import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var player: SKSpriteNode!
    var isJumping = false

    override func didMove(to view: SKView) {
        // Ambil node dari scene
        player = self.childNode(withName: "player") as? SKSpriteNode
        
        // Atur physics world
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        self.physicsWorld.gravity = CGVector(dx: 0, dy: -9.8)
        self.physicsWorld.contactDelegate = self
        
        // Debug physics body
        self.view?.showsPhysics = true
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        let screenMidX = self.frame.midX
        let screenHeight = self.frame.maxY

        if location.y > screenHeight * 0.6 {
            // 👉 Bagian atas layar = LOMPAT
            if !isJumping {
                player.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 300))
                isJumping = true
            }
        } else {
            // 👉 Bagian bawah layar = JALAN KIRI/KANAN
            if location.x < screenMidX {
                // Kiri → jalan ke kiri
                player.physicsBody?.applyImpulse(CGVector(dx: -30, dy: 0))
            } else {
                // Kanan → jalan ke kanan
                player.physicsBody?.applyImpulse(CGVector(dx: 30, dy: 0))
            }
        }
    }

    func didBegin(_ contact: SKPhysicsContact) {
        // Reset lompat kalau menyentuh tanah
        if contact.bodyA.node?.name == "ground" || contact.bodyB.node?.name == "ground" {
            isJumping = false
        }
    }

    override func update(_ currentTime: TimeInterval) {
        // Di sini bisa tambahkan logika animasi atau pembatasan posisi
    }
}
