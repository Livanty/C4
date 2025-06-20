//
//  OpeningScene.swift
//  SpiritBloomSWIFT
//
//  Created by Livanty Efatania Dendy on 20/06/25.
//

import Foundation
import SpriteKit

class OpeningScene: SKScene {

    override func didMove(to view: SKView) {
        backgroundColor = .black
        showOpeningText()
    }

    func showOpeningText() {
        let openingText = SKLabelNode(text: "A Musician Has Been Found Dead...")
        openingText.fontName = "AvenirNext-Bold"
        openingText.fontSize = 32
        openingText.fontColor = .white
        openingText.alpha = 0
        openingText.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(openingText)

        openingText.run(SKAction.sequence([
            SKAction.fadeIn(withDuration: 2.0),
            SKAction.wait(forDuration: 2.0),
            SKAction.fadeOut(withDuration: 1.5)
        ])) {
            self.showSecondText()
        }
    }

    func showSecondText() {
        let secondText = SKLabelNode(text: "Only You Can Solve the Mystery.")
        secondText.fontName = "AvenirNext-Bold"
        secondText.fontSize = 28
        secondText.fontColor = .white
        secondText.alpha = 0
        secondText.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(secondText)

        secondText.run(SKAction.sequence([
            SKAction.fadeIn(withDuration: 2.0),
            SKAction.wait(forDuration: 2.0),
            SKAction.fadeOut(withDuration: 1.5)
        ])) {
            self.showDoorTransition()
        }
    }

    func showDoorTransition() {
        let leftDoor = SKSpriteNode(color: .black, size: CGSize(width: size.width / 2, height: size.height))
        leftDoor.anchorPoint = CGPoint(x: 1, y: 0.5)
        leftDoor.position = CGPoint(x: frame.midX, y: frame.midY)
        leftDoor.zPosition = 100

        let rightDoor = SKSpriteNode(color: .black, size: CGSize(width: size.width / 2, height: size.height))
        rightDoor.anchorPoint = CGPoint(x: 0, y: 0.5)
        rightDoor.position = CGPoint(x: frame.midX, y: frame.midY)
        rightDoor.zPosition = 100

        addChild(leftDoor)
        addChild(rightDoor)

        let leftMove = SKAction.moveBy(x: -frame.width / 2, y: 0, duration: 1.0)
        let rightMove = SKAction.moveBy(x: frame.width / 2, y: 0, duration: 1.0)

        leftDoor.run(leftMove)
        rightDoor.run(rightMove) {
            self.goToGameScene()
        }
    }

    func goToGameScene() {
        let transition = SKTransition.fade(withDuration: 0.5)
        if let gameScene = SKScene(fileNamed: "MyScene") {
            gameScene.scaleMode = .aspectFill
            self.view?.presentScene(gameScene, transition: transition)
        }
    }
}
