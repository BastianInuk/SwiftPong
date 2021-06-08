//
//  ContentView.swift
//  SwiftPong
//
//  Created by Bastian Inuk Christensen on 18/05/2021.
//

import SwiftUI
import SpriteKit

struct GameView: View {
    var scene: SKScene {
        let scene = GameScene()
        
        scene.entityManager = EntityManager(scene: scene)
        
        scene.size = CGSize(width: 1920, height: 1080)
        
        scene.scaleMode = .aspectFill
        
        scene.makeBall()
        scene.makeBat(team: .right)
        scene.makeBat(team: .left)
        
        return scene
        
    }
    
    var body: some View {
        SpriteView(
            scene: scene,
            options: [
                .allowsTransparency,
                .ignoresSiblingOrder
            ]
        )
    }
    
}

struct ContentView: View {
    var body: some View {
        GameView()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
        }
    }
}
