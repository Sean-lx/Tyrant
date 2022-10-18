import Combine
import Foundation

public struct Tyrant {
    public private(set) var text = "Hello, World!"
    public private(set) var urlSesstion: URLSession = URLSession.shared

    public init() {
    }
}
