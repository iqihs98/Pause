//
//  BreathingView.swift
//  Pause
//
//  Created by 施奇 on 2026/1/21.
//

import SwiftUI

struct WatchBreathingView: View {
    @StateObject private var session = BreathingSession(totalSeconds: 60, inhaleSeconds: 4, exhaleSeconds: 4)

    // 0~1 的呼吸进度：吸气从 0->1；呼气从 1->0
    @State private var breathProgress: CGFloat = 0

    var body: some View {
        VStack(spacing: 10) {
            MindfulBreathingOrb(
                phaseText: session.phase.rawValue,
                timeText: session.timeText,
                breathProgress: breathProgress
            )
            .frame(height: 195)
            .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
            .onAppear {
                // 初始对齐
                syncBreathProgress(animated: false)
            }
            .onChange(of: session.phase) { _, _ in
                // 阶段切换时启动一次“阶段时长”的动画
                animateToTargetForPhase()
            }
            .onChange(of: session.isRunning) { _, running in
                if running {
                    // 从暂停恢复：对齐当前相位并继续动画
                    animateToTargetForPhase()
                }
            }

            HStack(spacing: 10) {
                Button {
                    session.toggle()
                    if session.isRunning {
                        animateToTargetForPhase()
                    }
                } label: {
                    Image(systemName: session.isRunning ? "pause.fill" : "play.fill")
                }
                .buttonStyle(.borderedProminent)

                Button {
                    session.reset()
                    syncBreathProgress(animated: false)
                } label: {
                    Image(systemName: "arrow.counterclockwise")
                }
                .buttonStyle(.bordered)
            }
        }
        .padding(.horizontal, 8)
    }

    private func syncBreathProgress(animated: Bool) {
        let target: CGFloat = (session.phase == .inhale) ? 0 : 1
        if animated {
            breathProgress = target
        } else {
            withTransaction(Transaction(animation: nil)) {
                breathProgress = target
            }
        }
    }

    private func animateToTargetForPhase() {
        guard session.isRunning else { return }

        // 吸气：0 -> 1；呼气：1 -> 0
        let target: CGFloat = (session.phase == .inhale) ? 1 : 0
        let duration = (session.phase == .inhale) ? Double(session.inhaleSeconds) : Double(session.exhaleSeconds)

        withAnimation(.easeInOut(duration: duration)) {
            breathProgress = target
        }
    }
}

#Preview {
    WatchBreathingView()
}
