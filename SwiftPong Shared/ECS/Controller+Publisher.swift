import GameController
import Combine

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
