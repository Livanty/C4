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
        let scene = GameScene()
        scene.size = CGSize(width: 896, height: 414)
        scene.scaleMode = .aspectFill
        scene.externalMovementState = ExternalMovementState(
            isMovingLeft: $isMovingLeft,
            isMovingRight: $isMovingRight
        )
        return scene
    }

    var body: some View {
        ZStack {
            SpriteView(scene: scene)
                .ignoresSafeArea()

            // Joy-Con area
            HStack {
                // LEFT BUTTON
                Image(systemName: "arrow.left.circle.fill")
                    .resizable()
                    .frame(width: 60, height: 60)
                    .foregroundColor(isMovingLeft ? .green : .blue)
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { _ in isMovingLeft = true }
                            .onEnded { _ in isMovingLeft = false }
                    )

                Spacer()

                // RIGHT BUTTON
                Image(systemName: "arrow.right.circle.fill")
                    .resizable()
                    .frame(width: 60, height: 60)
                    .foregroundColor(isMovingRight ? .green : .blue)
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { _ in isMovingRight = true }
                            .onEnded { _ in isMovingRight = false }
                    )
            }
            .padding(.horizontal, 50)
            .padding(.bottom, 40)
            .frame(maxHeight: .infinity, alignment: .bottom)
        }
    }
}


#Preview {
    ContentView()
}


