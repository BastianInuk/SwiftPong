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
    
    private func passThroughKey(button: GCControllerButtonInput) -> PassthroughSubject<Bool, Upstream.Failure>
    {
        let publisher = PassthroughSubject<Bool, Upstream.Failure>()
        button.pressedChangedHandler = { _, _, pressed in
            publisher.send(pressed)
        }
        return publisher
    }
}

class MoveSystem: GKComponent {
    let entityManager: EntityManager
    
    @Published
    var leftDir = 0
    @Published
    var rightDir = 0
    
    var cancels = [AnyCancellable]()
    
    let movementSpeed = 10
    
    // MARK: - Setup
    init(entityManager: EntityManager) {
        self.entityManager = entityManager
        
        super.init()
        
        let keyboard = NotificationCenter.default
            .publisher (for: .GCKeyboardDidConnect)
            .map (\.object)
            .map { $0 as! GCKeyboard }
            .compactMap (\.keyboardInput)
        
        keyboard.isPressed(forKeyCode: .keyW)
            .map { $0 ? +1 : -1 }
            .sink { self.leftDir += $0 }
            .store(in: &cancels)
            
        keyboard.isPressed(forKeyCode: .keyS)
            .map { $0 ? -1 : +1 }
            .sink { self.leftDir += $0 }
            .store(in: &cancels)
            
        keyboard.isPressed(forKeyCode: .upArrow)
            .map { $0 ? +1 : -1 }
            .sink { self.rightDir += $0 }
            .store(in: &cancels)
            
        keyboard.isPressed(forKeyCode: .downArrow)
            .map { $0 ? -1 : +1 }
            .sink { self.rightDir += $0 }
            .store(in: &cancels)
        
    }
    
    deinit {
        cancels.forEach { $0.cancel() }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Frame updates
    override func update(deltaTime seconds: TimeInterval) {
        let (retainLeft, retainRight) = (self.leftDir, self.rightDir)
        
        entityManager.entities.forEach { entity in
            guard let team = entity.component(ofType: TeamComponent.self)?.team,
                  let movement = entity.component(ofType: MoveComponent.self) else {
                return
            }
            
            movement.agentWillUpdate()
            
            let dir = team == .left ? retainLeft : retainRight
            
            if (dir != 0) {
                print(dir)
            }
            movement.position.y += Float(dir)
            
            
            movement.agentDidUpdate()
        }
    }
}
