import AVFoundation
import Foundation
import SlurpAndBurpCore

/// Original one-shot sounds, synthesized when they play. Nothing is sampled from another game.
@MainActor
final class SoundSynth {
    private let engine = AVAudioEngine()
    private let sfx = AVAudioPlayerNode()
    private let burpPlayer = AVAudioPlayerNode()
    private let format: AVAudioFormat
    private var started = false

    init() {
        format = AVAudioFormat(standardFormatWithSampleRate: 44_100, channels: 1)!
        engine.attach(sfx)
        engine.attach(burpPlayer)
        engine.connect(sfx, to: engine.mainMixerNode, format: format)
        engine.connect(burpPlayer, to: engine.mainMixerNode, format: format)
        engine.mainMixerNode.outputVolume = 0.9
    }

    func warmUp() {
        guard !started else { return }
        #if os(iOS)
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.ambient, mode: .default, options: [.mixWithOthers])
        try? session.setActive(true)
        #endif
        started = (try? engine.start()) != nil
        if started {
            sfx.play()
            burpPlayer.play()
        }
    }

    func playSlurp() {
        warmUp()
        let samples = SoundSynth.slurp()
        schedule(samples, on: sfx, interrupt: true)
    }

    func playBurp(_ tier: BurpTier) {
        warmUp()
        schedule(SoundSynth.burp(tier), on: burpPlayer, interrupt: true)
    }

    private func schedule(_ samples: [Float], on player: AVAudioPlayerNode, interrupt: Bool) {
        guard started, let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: AVAudioFrameCount(samples.count)) else {
            return
        }
        buffer.frameLength = AVAudioFrameCount(samples.count)
        guard let channel = buffer.floatChannelData?[0] else { return }
        for index in samples.indices {
            channel[index] = samples[index]
        }
        let options: AVAudioPlayerNodeBufferOptions = interrupt ? .interrupts : []
        player.scheduleBuffer(buffer, at: nil, options: options, completionHandler: nil)
        if !player.isPlaying { player.play() }
    }

    private static func slurp() -> [Float] {
        render(duration: 0.22) { time, duration in
            let envelope = sin(.pi * time / duration)
            let frequency = 640 * pow(0.22, time / duration)
            let tone = sin(2 * .pi * frequency * time)
            let noise = hashNoise(time) * (1 - time / duration)
            return Float((tone * 0.7 + noise * 0.3) * envelope * 0.55)
        }
    }

    private static func burp(_ tier: BurpTier) -> [Float] {
        let duration = tier.duration
        let start = tier.fundamentalHz
        return render(duration: duration) { time, length in
            let progress = time / length
            let envelope: Double
            switch tier {
            case .hic:
                let first = blip(time, center: 0.04, width: 0.035)
                let second = blip(time, center: 0.11, width: 0.03) * 0.55
                envelope = first + second
            case .polite:
                envelope = sin(.pi * min(1, progress)) * (progress < 0.15 ? progress / 0.15 : 1)
            default:
                let attack = min(1, progress / 0.12)
                let release = min(1, (1 - progress) / 0.28)
                envelope = attack * release
            }
            let wobble = sin(2 * .pi * (3 + Double(tier.rawValue)) * time)
            let frequency = start * (1 + 0.07 * wobble) * (1 - 0.35 * progress)
            var sample = sin(2 * .pi * frequency * time)
            sample += 0.45 * sin(2 * .pi * frequency * 2 * time)
            sample += 0.18 * sin(2 * .pi * frequency * 3.02 * time)
            if tier >= .hearty {
                sample += hashNoise(time) * 0.22 * (0.5 + 0.5 * sin(2 * .pi * 9 * time))
            }
            if tier >= .rumbling {
                sample += sin(2 * .pi * frequency * 0.5 * time) * 0.55
            }
            return Float(max(-1, min(1, sample * envelope * 0.8)))
        }
    }

    private static func render(duration: TimeInterval, _ sample: (Double, Double) -> Float) -> [Float] {
        let rate = 44_100.0
        let count = max(1, Int(rate * duration))
        var output = [Float](repeating: 0, count: count)
        for index in 0..<count {
            let time = Double(index) / rate
            output[index] = sample(time, duration)
        }
        return output
    }

    private static func blip(_ time: Double, center: Double, width: Double) -> Double {
        let delta = (time - center) / width
        return exp(-delta * delta)
    }

    private static func hashNoise(_ time: Double) -> Double {
        let bucket = Int(time * 44_100) &* 1103515245 &+ 12345
        let unit = Double(bucket & 0xFFFF) / 65535
        return unit * 2 - 1
    }
}
