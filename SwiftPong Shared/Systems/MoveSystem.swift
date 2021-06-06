import GameplayKit
import Combine
import GameController

class MoveSystem: GKComponent {
    unowned let entityManager: EntityManager
    
    private var dir: (left: Int8, right: Int8) = (0, 0)
    
    private var cancels = [AnyCancellable]()
    
    let movementSpeed = 4
    
    // MARK: - Setup
    init(entityManager: EntityManager) {
        self.entityManager = entityManager
        
        super.init()
        
        let keyboard = NotificationCenter.default
            .publisher (for: .GCKeyboardDidConnect)
            .compactMap (\.object)
            .cast(to: GCKeyboard.self)
            .compactMap (\.keyboardInput)
        
        keyboard.isPressed (forKeyCode: .keyW)
            .map { $0 ? +1 : -1 }
            .sink { [unowned self] in self.dir.left += $0 }
            .store (in: &cancels)
            
        keyboard.isPressed (forKeyCode: .keyS)
            .map { $0 ? -1 : +1 }
            .sink { [unowned self] in self.dir.left += $0 }
            .store (in: &cancels)
            
        keyboard.isPressed(forKeyCode: .upArrow)
            .map { $0 ? +1 : -1 }
            .sink { [unowned self] in self.dir.right += $0 }
            .store (in: &cancels)
            
        keyboard.isPressed(forKeyCode: .downArrow)
            .map { $0 ? -1 : +1 }
            .sink { [unowned self] in self.dir.right += $0 } 
            .store (in: &cancels)
        
    }
    
    deinit {
        cancels.forEach { $0.cancel() }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Frame updates
    override func update(deltaTime seconds: TimeInterval) {
        let (retainLeft, retainRight) = self.dir
        
        entityManager.entities
            .forEach { entity in
                guard let team = entity.component(ofType: TeamComponent.self)?.team,
                      let movement = entity.component(ofType: MoveComponent.self) else {
                    return
                }
                movement.agentWillUpdate()
                
                let dir = team == .left ? retainLeft : retainRight
                
                movement.position.y += Float(Int(dir) * movementSpeed)
                
                movement.agentDidUpdate()
            }
        
    }
}
