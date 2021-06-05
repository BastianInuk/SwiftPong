import GameplayKit
import Combine
import GameController

extension Publishers.CompactMap where Output: GCKeyboardInput
{
    func isPressed (
        forKeyCode keyCode: GCKeyCode
    ) -> AnyPublisher<Bool, Upstream.Failure>
    {
        self.compactMap { $0.button(forKeyCode: keyCode) }
            .flatMap(passThroughKey)
            .eraseToAnyPublisher()
    }
    
    private func passThroughKey(button: GCControllerButtonInput) -> PassthroughSubject<Bool, Never>
    {
        let publisher = PassthroughSubject<Bool, Never>()
        button.pressedChangedHandler = { _, _, pressed in
            publisher.send(pressed)
        }
        return publisher
    }
}

class MoveSystem: GKComponent {
    let entityManager: EntityManager
    
    @Published
    var leftDir = Optional<MoveComponent.Dir>.none
    @Published
    var rightDir = Optional<MoveComponent.Dir>.none
    
    var cancels = [AnyCancellable]()
    
    let movementSpeed = 10
    
    init(entityManager: EntityManager) {
        self.entityManager = entityManager
        
        super.init()
        
        let keyboard = NotificationCenter.default
            .publisher (for: .GCKeyboardDidConnect)
            .map (\.object)
            .map { $0 as! GCKeyboard }
            .compactMap (\.keyboardInput)
        
        keyboard.isPressed(forKeyCode: .keyW)
            .print("Up")
            .map { $0 ? .up : .none }
            .assign(to: &$leftDir)
            
            
        keyboard.isPressed(forKeyCode: .keyS)
            .print("Down")
            .map { $0 ? .down : .none }
            .assign(to: &$leftDir)
            
        keyboard.isPressed(forKeyCode: .upArrow)
            .map { $0 ? .up : .none }
            .assign(to: &$rightDir)
            
        keyboard.isPressed(forKeyCode: .downArrow)
            .map { $0 ? .down : .none }
            .assign(to: &$rightDir)
        
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
            
            let dir = team == .left ? self.leftDir : self.rightDir
            
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
