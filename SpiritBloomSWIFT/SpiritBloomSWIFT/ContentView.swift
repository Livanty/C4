//
//  ContentView.swift
//  SpiritBloomSWIFT
//
//  Created by Livanty Efatania Dendy on 09/06/25.
//

import SwiftUI
import SpriteKit

struct ContentView: View {
    @State private var isMovingLeft = false
    @State private var isMovingRight = false

    var scene: GameScene {
        guard let scene = SKScene(fileNamed: "MyScene.sks") as? GameScene else {
            fatalError("Couldn't load MyScene.sks")
        }
        scene.scaleMode = .resizeFill
        return scene
        
    }

    var body: some View {
        ZStack {
            GameView()
                .ignoresSafeArea()
        }
    }

}


#Preview {
    ContentView()
}


