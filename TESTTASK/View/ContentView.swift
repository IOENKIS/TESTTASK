//
//  ContentView.swift
//  TESTTASK
//
//  Created by Ivan Kisilov on 14.05.2025.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab: Tab = .users
    @StateObject private var vm = AppViewModel()
    @State private var showSplash = true
    
    enum Tab {
        case users, signUp
    }
    
    var body: some View {
        ZStack{
            if showSplash {
                SplashView()
                    .transition(.opacity)
            } else {
                VStack {
                    switch selectedTab {
                    case .users:
                        UsersView()
                            .environmentObject(vm)
                    case .signUp:
                        SignUpView(selectedTab: $selectedTab)
                            .environmentObject(vm)
                    }
                    
                    CustomTabBar(selectedTab: $selectedTab)
                        .background(Color.gray.opacity(0.1))
                }
                if !vm.isConnected {
                    NoInternetOverlay {
                        // натиснули Try again
                        Task {
                            await vm.loadInitialUsers()
                            await vm.loadPositions()
                        }
                    }
                    .transition(.opacity)
                }
            }
        }
        .environmentObject(vm)
        .task {
            try? await Task.sleep(nanoseconds: 3_000_000_000)
            withAnimation { showSplash = false }
        }
    }
}

struct CustomTabBar: View {
    @Binding var selectedTab: ContentView.Tab

    var body: some View {
        HStack {
            TabBarButton(title: "Users",
                         icon: "person.3.sequence.fill",
                         isSelected: selectedTab == .users) {
                selectedTab = .users
            }
            Spacer()
            TabBarButton(title: "Sign Up",
                         icon: "person.crop.circle.fill.badge.plus",
                         isSelected: selectedTab == .signUp) {
                selectedTab = .signUp
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 15)
    }
}


struct TabBarButton: View {
    var title: String
    var icon: String
    var isSelected: Bool
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(isSelected ? .customSecondary : .black.opacity(0.6))
                
                Text(title)
                    .heading1()
                    .foregroundColor(isSelected ? .customSecondary : .black.opacity(0.6))
            }
            .padding(.top, 5)
        }
        .padding(.horizontal, 40)
    }
}

#Preview {
    ContentView()
}
