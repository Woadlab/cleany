import AppKit

/// Multimodal feedback combining macOS trackpad haptics and native system sound cues.
public enum SoundHaptics {
    public static func tap() {
        NSHapticFeedbackManager.defaultPerformer.perform(.generic, performanceTime: .default)
    }

    public static func scanComplete() {
        NSHapticFeedbackManager.defaultPerformer.perform(.alignment, performanceTime: .default)
        NSSound(named: "Purr")?.play()
    }

    public static func cleanSuccess() {
        NSHapticFeedbackManager.defaultPerformer.perform(.levelChange, performanceTime: .default)
        NSSound(named: "Blow")?.play()
    }
}
