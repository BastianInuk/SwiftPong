import GameplayKit

class TeamComponent : GKComponent {
    enum Team {
        case left, right
    }
    
    let team: Team
    
    init(team: Team) {
        self.team = team
        
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
