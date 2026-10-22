import AppKit

/// Calibrated subtle audio feedback for major actions, without intrusive trackpad thump on simple taps.
public enum SoundHaptics {
    public static func tap() {
        // No-op for standard taps: allows natural trackpad actuation without artificial double-thumping
    }

    public static func scanComplete() {
        NSSound(named: "Purr")?.play()
    }

    public static func cleanSuccess() {
        NSSound(named: "Blow")?.play()
    }

    public static func clean() {
        cleanSuccess()
    }
}
