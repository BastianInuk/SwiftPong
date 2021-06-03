//
//  GameScene.swift
//  SwiftPong Shared
//
//  Created by Bastian Inuk Christensen on 18/05/2021.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    var entityManager: EntityManager!
    private var lastTime: TimeInterval?
    
    override func update(_ currentTime: TimeInterval) {
        let deltaTime = (lastTime ?? currentTime) - currentTime
        entityManager.update(deltaTime)
    }
    
    
    func makeBall() {
        let ball = SKShapeNode.init(circleOfRadius: 10)
        
        //ball.physicsBody = .init(circleOfRadius: 10)
        //ball.physicsBody?.affectedByGravity = false
        ball.fillColor = .white
        ball.lineWidth = 0
        ball.position = .init(x: self.size.width / 2, y: self.size.height / 2)
        //ball.run(.applyForce(.init(dx: -95, dy: -95), duration: 0.05))
        
        let ballEntity = GKEntity()
        ballEntity.addComponent(NodeComponent(node: ball))
        entityManager.add(entity: ballEntity)
    }
    
    func makeBat(team: TeamComponent.Team) {
        let bat = SKShapeNode.init(rectOf: .init(width: 10, height: 100))
        
        bat.fillColor = .white
        bat.lineWidth = 0
        bat.position = .init(x: (self.size.width / 6) * (team == .right ? 5 : 1) , y: self.size.height / 2)
        
        let entt = GKEntity()
        entt.addComponent(NodeComponent(node: bat))
        entt.addComponent(MoveComponent(
            maxSpeed: 150,
            maxAcceleration: 5,
            radius: Float(bat.fillTexture?.size().width ?? 0 * 0.3),
            entityManager: entityManager
        ))
        entt.addComponent(TeamComponent(team: .right))
        
        entityManager.add(entity: entt)
    }
    
}
