import GameController
import Combine

extension Publisher where Output: GCKeyboardInput
{
    func isPressed (
        forKeyCode keyCode: GCKeyCode
    ) -> AnyPublisher<Bool, Failure>
    {
        self.compactMap { $0.button(forKeyCode: keyCode) }
            .flatMap(passThroughKey)
            .eraseToAnyPublisher()
    }
    
    private func passThroughKey(
        button: GCControllerButtonInput
    ) -> PassthroughSubject<Bool, Failure>
    {
        let publisher = PassthroughSubject<Bool, Failure>()
        button.pressedChangedHandler = { _, _, pressed in
            publisher.send(pressed)
        }
        return publisher
    }
}

extension Publisher where Output == Any
{
    func cast<T>(to: T.Type) -> AnyPublisher<T, Failure>
    {
        self.compactMap { $0 as? T }.eraseToAnyPublisher()
    }
}
