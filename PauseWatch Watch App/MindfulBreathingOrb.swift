//
//  MindfulBreathingOrb.swift
//  Pause
//
//  Created by 施奇 on 2026/1/21.
//

import SwiftUI

/// Apple Watch 正念风格的“发光呼吸球”
/// - 通过 phase + progress(0~1) 控制扩张/收缩
struct MindfulBreathingOrb: View {
    let phaseText: String
    let timeText: String

    /// 0...1，0=最小，1=最大
    let breathProgress: CGFloat

    @State private var shimmer = false

    var body: some View {
        ZStack {
            // 背景微微发光（暗底 + 柔光）
            Color.black
                .ignoresSafeArea()

            // 外层呼吸光晕：随 breathProgress 扩张/收缩
            ZStack {
                // 远光晕（更模糊更大）
                Circle()
                    .fill(AngularGradient(
                        gradient: Gradient(colors: [
                            .mint, .cyan, .blue, .purple, .pink, .mint
                        ]),
                        center: .center
                    ))
                    .opacity(0.18)
                    .blur(radius: 18)
                    .scaleEffect(0.95 + 0.45 * breathProgress)
                    .blendMode(.screen)

                // 近光晕（更清晰一点）
                Circle()
                    .fill(RadialGradient(
                        gradient: Gradient(colors: [
                            Color.white.opacity(0.35),
                            Color.white.opacity(0.05),
                            Color.clear
                        ]),
                        center: .center,
                        startRadius: 0,
                        endRadius: 120
                    ))
                    .opacity(0.35)
                    .blur(radius: 6)
                    .scaleEffect(0.85 + 0.35 * breathProgress)
                    .blendMode(.screen)

                // 核心球体（“正念”那种凝聚感）
                Circle()
                    .fill(LinearGradient(
                        gradient: Gradient(colors: [
                            Color.white.opacity(0.25),
                            Color.white.opacity(0.05),
                            Color.clear
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .overlay(
                        Circle()
                            .strokeBorder(Color.white.opacity(0.18), lineWidth: 2)
                    )
                    .background(
                        Circle()
                            .fill(Color.white.opacity(0.06))
                            .blur(radius: 2)
                    )
                    .scaleEffect(0.72 + 0.22 * breathProgress)
            }
            .frame(width: 170, height: 170)
            .rotationEffect(.degrees(shimmer ? 8 : -8))
            .animation(.easeInOut(duration: 3).repeatForever(autoreverses: true), value: shimmer)
            .onAppear { shimmer = true }

            // 文案层（尽量简洁：阶段 + 倒计时）
            VStack(spacing: 4) {
                Text(phaseText)
                    .font(.headline)
                    .foregroundStyle(.white.opacity(0.9))

                Text(timeText)
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(.white.opacity(0.95))
            }
        }
    }
}
