import GameplayKit
import SpriteKit

@dynamicMemberLookup
class NodeComponent: GKComponent {
    private(set) var node: SKNode
    
    init(texture: SKTexture)
    {
        self.node = SKSpriteNode(
            texture: texture,
            color: .white,
            size: texture.size()
        )
        
        super.init()
    }
    
    init(node: SKNode)
    {
        self.node = node
        
        super.init()
    }
    
    subscript<T>(dynamicMember member: WritableKeyPath<SKNode, T>) -> T
    {
        get { node[keyPath: member] }
        set { node[keyPath: member] = newValue }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
