//
//  WatchConnectivityManager.swift
//  Pause
//
//  Created by 施奇 on 2026/1/24.
//

import Foundation
import WatchConnectivity
import Combine

@MainActor
final class WatchConnectivityManager: NSObject, ObservableObject, WCSessionDelegate {
    static let shared = WatchConnectivityManager()

    private override init() {
        super.init()
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }

    func sendHeartRate(bpm: Double) {
        guard WCSession.default.isReachable else { return }
        WCSession.default.sendMessage(["bpm": bpm], replyHandler: nil, errorHandler: nil)
    }

    // Required delegate stubs
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {}
}
