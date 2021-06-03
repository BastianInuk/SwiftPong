import GameplayKit

@resultBuilder
struct QueryBuilder {
    static func buildBlock(_ components: GKComponent.Type...) -> [GKComponent.Type] {
        components
    }
}

protocol System: AnyObject {
    associatedtype Query = [GKComponent.Type]
    
    @QueryBuilder
    var query: Query { get }
    
    func update (deltaTime: TimeInterval, entities: [GKEntity])
}
