import GameplayKit
import SpriteKit

@resultBuilder
struct SystemBuilder {
    static func buildBlock(_ components: GKComponent.Type...) -> [GKComponentSystem<GKComponent>] {
        components.map { GKComponentSystem(componentClass: $0) }
    }
    
    static func buildBlock(_ components: GKComponent...) -> [GKComponentSystem<GKComponent>] {
        components.map {
            let cs = GKComponentSystem(componentClass: type(of: $0))
            cs.addComponent($0)
            return cs
        }
    }
}

extension Array where Element: GKComponentSystem<GKComponent>
{
    init(@SystemBuilder components: () -> [Element]) {
        self = components()
    }
}

class EntityManager {
    
    var entities = Set<GKEntity>()
    lazy var toRemove = Set<GKEntity>()
    
    let scene: SKScene
    
    // MARK: - Systems
    lazy var components: [GKComponentSystem<GKComponent>] = .init {
        NodeComponent.self
        MoveComponent.self
        VelocityComponent.self
    }
    
    lazy var systems: [GKComponentSystem<GKComponent>] = .init {
        MoveSystem(entityManager: self)
    }
    
    
    init(scene: SKScene)
    {
        self.scene = scene
    }
    
    // MARK: - Entity Management
    func add(entity: GKEntity)
    {
        entities.insert(entity)
        
        entity.component(ofType: NodeComponent.self).map { component in
            self.scene.addChild(component.node)
        }
        
        for componentSystem in components {
          componentSystem.addComponent(foundIn: entity)
        }
    }
    
    func remove(entity: GKEntity)
    {
        entity.component(ofType: NodeComponent.self).map { component in
            component.node.removeFromParent()
        }
        
        entities.remove(entity)
    
        toRemove.insert(entity)
    }
    
    func update(_ deltaTime: CFTimeInterval)
    {
        for componentSystem in components {
            componentSystem.update(deltaTime: deltaTime)
        }
        
        for system in systems {
            system.update(deltaTime: deltaTime)
        }
        
        for removing in toRemove {
            components.forEach {
                $0.removeComponent(foundIn: removing)
            }
        }
        
        toRemove.removeAll()
        
    }
    
    // MARK: - Entity queries
    func moveComponents() -> [MoveComponent] {
        entities.compactMap {
            $0.component(ofType: MoveComponent.self)
        }
    }
    
    
}
