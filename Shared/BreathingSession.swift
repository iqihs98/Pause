//
//  BreathingSession.swift
//  Pause
//
//  Created by 施奇 on 2026/1/21.
//

import Foundation
import SwiftUI
import Combine

/// 简单呼吸阶段：吸气 / 呼气
public enum BreathPhase: String {
    case inhale = "吸气"
    case exhale = "呼气"
}

/// 一个最小可用的呼吸会话：负责倒计时 + 阶段切换
@MainActor
public final class BreathingSession: ObservableObject {

    // 可配置
    public let totalSeconds: Int
    public let inhaleSeconds: Int
    public let exhaleSeconds: Int

    // 状态
    @Published public private(set) var isRunning: Bool = false
    @Published public private(set) var remainingSeconds: Int
    @Published public private(set) var phase: BreathPhase = .inhale
    @Published public private(set) var phaseRemainingSeconds: Int

    private var timer: Timer?

    public init(totalSeconds: Int = 60, inhaleSeconds: Int = 4, exhaleSeconds: Int = 4) {
        self.totalSeconds = totalSeconds
        self.inhaleSeconds = inhaleSeconds
        self.exhaleSeconds = exhaleSeconds

        self.remainingSeconds = totalSeconds
        self.phaseRemainingSeconds = inhaleSeconds
        self.phase = .inhale
    }

    public func toggle() {
        isRunning ? pause() : start()
    }

    public func start() {
        guard !isRunning else { return }
        isRunning = true

        // 立即对齐一次阶段剩余时间（防止从暂停恢复时不一致）
        if phaseRemainingSeconds <= 0 {
            switchPhase()
        }

        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }

    public func pause() {
        guard isRunning else { return }
        isRunning = false
        timer?.invalidate()
        timer = nil
    }

    public func reset() {
        pause()
        remainingSeconds = totalSeconds
        phase = .inhale
        phaseRemainingSeconds = inhaleSeconds
    }

    private func tick() {
        guard isRunning else { return }

        if remainingSeconds > 0 {
            remainingSeconds -= 1
        }

        if phaseRemainingSeconds > 0 {
            phaseRemainingSeconds -= 1
        }

        // 总时长到 0 就结束
        if remainingSeconds <= 0 {
            remainingSeconds = 0
            pause()
            return
        }

        // 阶段到 0 就切换阶段
        if phaseRemainingSeconds <= 0 {
            switchPhase()
        }
    }

    private func switchPhase() {
        if phase == .inhale {
            phase = .exhale
            phaseRemainingSeconds = exhaleSeconds
        } else {
            phase = .inhale
            phaseRemainingSeconds = inhaleSeconds
        }
    }

    public var timeText: String {
        let m = remainingSeconds / 60
        let s = remainingSeconds % 60
        return String(format: "%02d:%02d", m, s)
    }
}
