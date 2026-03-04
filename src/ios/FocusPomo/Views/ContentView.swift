//
//  ContentView.swift
//  FocusPomo
//
//  Created by AIagent on 2026-03-03.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            TimerView()
                .tabItem {
                    Image(systemName: "timer")
                    Text("专注")
                }
                .tag(0)
            
            StatisticsView()
                .tabItem {
                    Image(systemName: "chart.bar.fill")
                    Text("统计")
                }
                .tag(1)
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("设置")
                }
                .tag(2)
        }
        .accentColor(Color(hex: "#FF6B6B"))
    }
}

struct TimerView: View {
    @State private var timeRemaining: Int = 1500 // 25 分钟
    @State private var isRunning: Bool = false
    
    var body: some View {
        VStack(spacing: 40) {
            Text("专注时间")
                .font(.title2)
                .foregroundColor(.secondary)
            
            Text(String(format: "%02d:%02d", timeRemaining / 60, timeRemaining % 60))
                .font(.system(size: 72, weight: .bold))
                .foregroundColor(Color(hex: "#FF6B6B"))
            
            HStack(spacing: 40) {
                Button(action: {
                    if isRunning {
                        timeRemaining = max(0, timeRemaining - 60)
                    } else {
                        timeRemaining = min(1500, timeRemaining + 60)
                    }
                }) {
                    Image(systemName: isRunning ? "minus.circle.fill" : "plus.circle.fill")
                        .font(.system(size: 40))
                        .foregroundColor(Color(hex: "#FF6B6B"))
                }
                
                Button(action: {
                    isRunning.toggle()
                }) {
                    Image(systemName: isRunning ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(Color(hex: "#FF6B6B"))
                }
                
                Button(action: {
                    timeRemaining = 1500
                    isRunning = false
                }) {
                    Image(systemName: "arrow.counterclockwise.circle.fill")
                        .font(.system(size: 40))
                        .foregroundColor(Color(hex: "#FF6B6B"))
                }
            }
            
            Spacer()
        }
        .padding()
        .navigationTitle("番茄钟")
    }
}

struct StatisticsView: View {
    var body: some View {
        VStack(spacing: 20) {
            StatCard(title: "今日专注", value: "0", unit: "分钟")
            StatCard(title: "本周专注", value: "0", unit: "分钟")
            StatCard(title: "连续打卡", value: "0", unit: "天")
            
            Spacer()
        }
        .padding()
        .navigationTitle("统计")
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let unit: String
    
    var body: some View {
        VStack(spacing: 10) {
            Text(title)
                .font(.system(size: 16))
                .foregroundColor(.secondary)
            
            HStack(baselineOffset: 5) {
                Text(value)
                    .font(.system(size: 36, weight: .bold))
                
                Text(unit)
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

struct SettingsView: View {
    var body: some View {
        Form {
            Section(header: Text("关于")) {
                HStack {
                    Text("版本")
                    Spacer()
                    Text("1.0.0")
                        .foregroundColor(.secondary)
                }
            }
        }
        .navigationTitle("设置")
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview {
    ContentView()
}
