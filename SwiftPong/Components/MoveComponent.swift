import GameplayKit
import SpriteKit

class MoveComponent: GKAgent2D, GKAgentDelegate {
    let entityManager: EntityManager
    
    init(
        maxSpeed: Float,
        maxAcceleration: Float,
        radius: Float,
        entityManager: EntityManager
    ) {
        self.entityManager = entityManager
        super.init()
        delegate = self
        self.maxSpeed = maxSpeed
        self.maxAcceleration = maxAcceleration
        self.radius = radius
        print(self.mass)
        self.mass = 0.01
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Updates
    func agentWillUpdate() {
        guard let spriteComponent = entity?.component(ofType: NodeComponent.self) else {
            return
        }

        position = SIMD2<Float>(
            x: Float(spriteComponent.position.x),
            y: Float(spriteComponent.position.y)
        )
    }

    // 5
    func agentDidUpdate() {
        guard let spriteComponent = entity?.component(ofType: NodeComponent.self) else {
            return
        }

        spriteComponent.position = CGPoint(
            x: CGFloat(position.x),
            y: CGFloat(position.y)
        )
    }
}

extension MoveComponent {
    enum Dir {
        case up, down
    }
}
