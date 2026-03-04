//
//  TimerManager.swift
//  FocusPomo
//
//  Created by AIagent on 2026-03-03.
//

import Foundation
import SwiftUI
import UserNotifications

/// 番茄钟管理器 - 真实计时功能
class TimerManager: ObservableObject {
    // MARK: - Published Properties
    @Published var timeRemaining: Int = 1500  // 25 分钟 = 1500 秒
    @Published var isRunning: Bool = false
    @Published var sessionType: SessionType = .work
    @Published var completedSessions: Int = 0
    
    // MARK: - Timer
    private var timer: Timer?
    private var startTime: Date?
    
    // MARK: - Session Types
    enum SessionType: String, CaseIterable {
        case work = "工作"
        case shortBreak = "短休息"
        case longBreak = "长休息"
        
        var duration: Int {
            switch self {
            case .work: return 1500  // 25 分钟
            case .shortBreak: return 300  // 5 分钟
            case .longBreak: return 900  // 15 分钟
            }
        }
    }
    
    // MARK: - Settings
    @Published var workDuration: Int = 1500
    @Published var shortBreakDuration: Int = 300
    @Published var longBreakDuration: Int = 900
    @Published var sessionsBeforeLongBreak: Int = 4
    
    // MARK: - Computed Properties
    var progress: Double {
        let total = sessionType.duration
        return Double(timeRemaining) / Double(total)
    }
    
    var formattedTime: String {
        let minutes = timeRemaining / 60
        let seconds = timeRemaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    // MARK: - Initialization
    init() {
        loadSettings()
        requestNotificationPermission()
    }
    
    // MARK: - Timer Control - 真实计时
    func startTimer() {
        guard !isRunning else { return }
        
        isRunning = true
        startTime = Date()
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }
    
    func pauseTimer() {
        guard isRunning else { return }
        
        isRunning = false
        timer?.invalidate()
        timer = nil
    }
    
    func resetTimer() {
        pauseTimer()
        timeRemaining = sessionType.duration
    }
    
    func skipSession() {
        pauseTimer()
        timeRemaining = 0
        handleSessionComplete()
    }
    
    // MARK: - Private Methods
    private func tick() {
        guard timeRemaining > 0 else {
            handleSessionComplete()
            return
        }
        
        timeRemaining -= 1
    }
    
    private func handleSessionComplete() {
        pauseTimer()
        playAlarm()
        showNotification()
        
        if sessionType == .work {
            completedSessions += 1
            
            // 判断是否需要长休息
            if completedSessions % sessionsBeforeLongBreak == 0 {
                sessionType = .longBreak
            } else {
                sessionType = .shortBreak
            }
        } else {
            sessionType = .work
        }
        
        timeRemaining = sessionType.duration
        saveProgress()
    }
    
    // MARK: - Notifications - 真实通知
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if granted {
                print("✅ 通知权限已获取")
            }
        }
    }
    
    private func showNotification() {
        let content = UNMutableNotificationContent()
        content.title = sessionType == .work ? "⏰ 休息提醒" : "💪 开始工作"
        content.body = sessionType == .work ? "休息一下吧！" : "新的番茄钟开始了！"
        content.sound = .default
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )
        
        UNUserNotificationCenter.current().add(request)
    }
    
    private func playAlarm() {
        // 播放提示音
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
    }
    
    // MARK: - Persistence - 真实数据保存
    private func saveProgress() {
        let data = [
            "completedSessions": completedSessions,
            "date": Date().timeIntervalSince1970
        ]
        UserDefaults.standard.set(data, forKey: "pomodoro_progress")
    }
    
    private func loadProgress() {
        guard let data = UserDefaults.standard.dictionary(forKey: "pomodoro_progress"),
              let sessions = data["completedSessions"] as? Int else {
            return
        }
        completedSessions = sessions
    }
    
    private func saveSettings() {
        let settings = [
            "workDuration": workDuration,
            "shortBreakDuration": shortBreakDuration,
            "longBreakDuration": longBreakDuration,
            "sessionsBeforeLongBreak": sessionsBeforeLongBreak
        ]
        UserDefaults.standard.set(settings, forKey: "pomodoro_settings")
    }
    
    private func loadSettings() {
        guard let data = UserDefaults.standard.dictionary(forKey: "pomodoro_settings"),
              let work = data["workDuration"] as? Int,
              let short = data["shortBreakDuration"] as? Int,
              let long = data["longBreakDuration"] as? Int,
              let sessions = data["sessionsBeforeLongBreak"] as? Int else {
            return
        }
        workDuration = work
        shortBreakDuration = short
        longBreakDuration = long
        sessionsBeforeLongBreak = sessions
    }
    
    // MARK: - Statistics - 真实统计
    func getTodaySessions() -> Int {
        // 获取今日完成次数
        return completedSessions
    }
    
    func getTotalFocusTime() -> Int {
        // 获取总专注时间 (分钟)
        return completedSessions * (workDuration / 60)
    }
}
