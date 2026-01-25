//
//  WatchHeartRateManager.swift
//  Pause
//
//  Created by 施奇 on 2026/1/24.
//

import Foundation
import HealthKit
import Combine

@MainActor
final class WatchHeartRateManager: NSObject, ObservableObject {
    @Published var bpm: Double? = nil
    @Published var isRunning = false
    @Published var errorText: String? = nil

    private let healthStore = HKHealthStore()
    private var session: HKWorkoutSession?
    private var builder: HKLiveWorkoutBuilder?

    func requestAuthorization() async {
        guard HKHealthStore.isHealthDataAvailable() else {
            errorText = "Health 数据不可用"
            return
        }

        guard let hrType = HKObjectType.quantityType(forIdentifier: .heartRate) else {
            errorText = "无法获取心率类型"
            return
        }

        do {
            try await healthStore.requestAuthorization(toShare: [], read: [hrType, HKObjectType.workoutType()])
            errorText = nil
        } catch {
            errorText = "授权失败：\(error.localizedDescription)"
        }
    }

    func start() {
        if isRunning { return }

        let config = HKWorkoutConfiguration()
        config.activityType = .mindAndBody
        config.locationType = .unknown

        do {
            let session = try HKWorkoutSession(healthStore: healthStore, configuration: config)
            let builder = session.associatedWorkoutBuilder()

            self.session = session
            self.builder = builder

            session.delegate = self
            builder.delegate = self

            builder.dataSource = HKLiveWorkoutDataSource(healthStore: healthStore,
                                                        workoutConfiguration: config)

            let startDate = Date()
            session.startActivity(with: startDate)
            builder.beginCollection(withStart: startDate) { [weak self] success, error in
                Task { @MainActor in
                    if let error = error { self?.errorText = "开始采集失败：\(error.localizedDescription)" }
                }
            }

            isRunning = true
            errorText = nil
        } catch {
            errorText = "无法启动Workout：\(error.localizedDescription)"
        }
    }

    func stop() {
        guard isRunning else { return }
        isRunning = false

        session?.end()
        builder?.endCollection(withEnd: Date()) { _, _ in }
        builder?.finishWorkout { _, _ in }

        session = nil
        builder = nil
    }
}

extension WatchHeartRateManager: HKWorkoutSessionDelegate, HKLiveWorkoutBuilderDelegate {
    func workoutSession(_ workoutSession: HKWorkoutSession,
                        didChangeTo toState: HKWorkoutSessionState,
                        from fromState: HKWorkoutSessionState,
                        date: Date) { }

    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
        Task { @MainActor in
            self.errorText = "Workout错误：\(error.localizedDescription)"
            self.isRunning = false
        }
    }

    func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) { }

    func workoutBuilder(_ workoutBuilder: HKLiveWorkoutBuilder,
                        didCollectDataOf collectedTypes: Set<HKSampleType>) {
        guard let hrType = HKQuantityType.quantityType(forIdentifier: .heartRate),
              collectedTypes.contains(hrType),
              let stats = workoutBuilder.statistics(for: hrType),
              let quantity = stats.mostRecentQuantity()
        else { return }

        let unit = HKUnit.count().unitDivided(by: .minute())
        let value = quantity.doubleValue(for: unit)

        Task { @MainActor in
            self.bpm = value
        }
    }
}
