import SwiftUI

/// DynamicProperty wrapper providing local reactive view state without relying on missing SwiftUIMacros plugins.
@propertyWrapper
@MainActor
public struct LocalVar<T>: DynamicProperty {
    @StateObject private var storage: Box<T>

    public init(wrappedValue: T) {
        _storage = StateObject(wrappedValue: Box(wrappedValue))
    }

    public var wrappedValue: T {
        get { storage.value }
        nonmutating set { storage.value = newValue }
    }

    public var projectedValue: Binding<T> {
        let box = storage
        return Binding(
            get: { box.value },
            set: { box.value = $0 }
        )
    }

    private final class Box<V>: ObservableObject {
        @Published var value: V
        init(_ value: V) { self.value = value }
    }
}
