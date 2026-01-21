//
//  BreathingView.swift
//  Pause
//
//  Created by 施奇 on 2026/1/21.
//

import SwiftUI

struct BreathingView: View {
    @StateObject private var session = BreathingSession(totalSeconds: 60, inhaleSeconds: 4, exhaleSeconds: 4)

    // 圆形“呼吸”缩放
    @State private var circleScale: CGFloat = 0.75

    var body: some View {
        VStack(spacing: 24) {

            Spacer()

            ZStack {
                // 外圈淡淡的环
                Circle()
                    .stroke(lineWidth: 8)
                    .opacity(0.12)

                // 内圈呼吸圆
                Circle()
                    .fill(.tint)
                    .opacity(0.25)
                    .scaleEffect(circleScale)
                    .animation(animationForCurrentPhase, value: circleScale)

                VStack(spacing: 8) {
                    Text(session.phase.rawValue)
                        .font(.title2)
                        .fontWeight(.semibold)

                    Text(session.timeText)
                        .font(.system(size: 44, weight: .bold, design: .rounded))
                        .monospacedDigit()
                        .opacity(0.9)
                }
            }
            .frame(width: 260, height: 260)
            .onAppear {
                updateCircleScaleForCurrentPhase(animated: false)
            }
            .onChange(of: session.phase) { _, _ in
                updateCircleScaleForCurrentPhase(animated: true)
            }
            .onChange(of: session.isRunning) { _, running in
                // 暂停时停止在当前形态；开始时对齐一次阶段动画
                if running {
                    updateCircleScaleForCurrentPhase(animated: true)
                }
            }

            HStack(spacing: 16) {
                Button {
                    session.toggle()
                } label: {
                    Label(session.isRunning ? "暂停" : "开始",
                          systemImage: session.isRunning ? "pause.fill" : "play.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)

                Button {
                    session.reset()
                    updateCircleScaleForCurrentPhase(animated: false)
                } label: {
                    Label("重置", systemImage: "arrow.counterclockwise")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            }
            .padding(.horizontal)

            Spacer()
        }
        .padding()
    }

    private var animationForCurrentPhase: Animation {
        // 呼吸动画时长 = 当前阶段秒数，线性就够做 MVP
        let duration = session.phase == .inhale ? Double(session.inhaleSeconds) : Double(session.exhaleSeconds)
        return .linear(duration: duration)
    }

    private func updateCircleScaleForCurrentPhase(animated: Bool) {
        // 吸气放大，呼气缩小
        let target: CGFloat = (session.phase == .inhale) ? 1.05 : 0.75
        if animated {
            circleScale = target
        } else {
            // 关闭隐式动画，直接跳到目标值
            withTransaction(Transaction(animation: nil)) {
                circleScale = target
            }
        }
    }
}

#Preview {
    BreathingView()
}
