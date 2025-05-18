//
//  UsersView.swift
//  TESTTASK
//
//  Created by Ivan Kisilov on 14.05.2025.
//

import SwiftUI

struct UsersView: View {
    @EnvironmentObject private var vm: AppViewModel

    private let cardHeight: CGFloat = 120

    var body: some View {
        VStack(spacing: 0) {
            TopBar(title: "Working with GET request")

            ZStack {
                Color.customBackground.ignoresSafeArea()

                if vm.isLoadingUsers && vm.users.isEmpty {
                    ProgressView()
                        .frame(maxHeight: .infinity)
                } else if vm.users.isEmpty {
                    VStack(spacing: 24) {
                        Image(.noUser)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 120)
                        Text("There are no users yet")
                            .heading1()
                            .foregroundColor(.gray)
                    }
                    .frame(maxHeight: .infinity)
                } else {
                    ScrollView(showsIndicators: false) {
                        LazyVStack(spacing: 0, pinnedViews: []) {
                            ForEach(Array(vm.users.enumerated()), id: \.element.id) { idx, user in
                                UserCardView(
                                    avatar: user.avatar ?? UIImage(systemName: "person.circle.fill")!,
                                    fullName: user.name,
                                    job: user.position,
                                    email: user.email,
                                    phone: user.phone
                                )
                                .frame(maxWidth: .infinity, minHeight: cardHeight, alignment: .leading)
                                .padding(.horizontal, 16)
                                .onAppear {
                                    Task { await vm.loadNextUsersIfNeeded(currentIdx: idx) }
                                }

                                if idx < vm.users.count - 1 {
                                    Divider()
                                        .padding(.leading, 82)
                                }
                            }

                            if vm.isLoadingUsers {
                                ProgressView().padding()
                            }
                        }
                    }
                }
            }
        }
        .task { await vm.loadInitialUsers() }
        .alert("Error", isPresented: Binding<Bool>(
            get: { vm.usersError != nil },
            set: { _ in vm.usersError = nil })
        ) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(vm.usersError ?? "Unknown error")
        }
    }
}
