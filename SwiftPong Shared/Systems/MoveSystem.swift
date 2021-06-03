import GameplayKit
import Combine
import GameController

extension Publishers.CompactMap where Output: GCKeyboardInput
{
    func isPressed (
        forKeyCode keyCode: GCKeyCode
    ) -> AnyPublisher<Bool, Upstream.Failure>
    {
        self.compactMap {
            $0.button(forKeyCode: keyCode)
        }.flatMap {
            $0.publisher(for: \.isPressed)
        }.eraseToAnyPublisher()
    }
}

class MoveSystem: GKComponent {
    let entityManager: EntityManager
    var directions: [TeamComponent.Team: MoveComponent.Dir] = [:]
    var cancels = [AnyCancellable]()
    
    let movementSpeed = 10
    
    init(entityManager: EntityManager) {
        self.entityManager = entityManager
        
        super.init()
        
        let keyboard = NotificationCenter.default
            .publisher(for: Notification.Name.GCKeyboardDidConnect)
            .compactMap { notification in
                (notification.object as? GCKeyboard)?.keyboardInput
            }
        
        keyboard.isPressed(forKeyCode: .keyW)
            .print("Up")
            .sink(receiveValue: reactTo(direction: .up, team: .left))
            .store(in: &cancels)
            
        keyboard.isPressed(forKeyCode: .keyS)
            .print("Down")
            .sink(receiveValue: reactTo(direction: .down, team: .left))
            .store(in: &cancels)
            
        keyboard.isPressed(forKeyCode: .upArrow)
            .sink (receiveValue: reactTo(direction: .up, team: .right))
            .store(in: &cancels)
            
        keyboard.isPressed(forKeyCode: .downArrow)
            .sink(receiveValue: reactTo(direction: .down, team: .right))
            .store(in: &cancels)
        
    }
    
    func reactTo(direction: MoveComponent.Dir, team: TeamComponent.Team) -> (_ pressed: Bool) -> ()
    {
        return { pressed in
            if pressed { self.directions[team] = direction }
            else if self.directions[team] == direction { self.directions[team] = nil }
        }
    }
    
    deinit {
        cancels.forEach { $0.cancel() }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        entityManager.entities.forEach { entity in
            
            
            guard let team = entity.component(ofType: TeamComponent.self)?.team,
                  let movement = entity.component(ofType: MoveComponent.self) else {
                return
            }
            
            movement.agentWillUpdate()
            
            let dir = directions[team]
            
            switch dir {
            case .up:
                print("Moving up")
                movement.position.y += Float(movementSpeed)
                break
            case .down:
                movement.position.y -= Float(movementSpeed)
                break
            case .none:
                break
            }
            
            movement.agentDidUpdate()
        }
    }
}

/*
class MovementSystem: System {
    var query: Query {
        MoveComponent.self
        TeamComponent.self
    }
    
    var directions: [TeamComponent.Team: MoveComponent.Dir] = [:]
    
    func update(deltaTime: TimeInterval, entities: [GKEntity]) {
        <#code#>
    }
    
    
}
*/
