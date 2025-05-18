//
//  RegistrationOverlay.swift
//  TESTTASK
//
//  Created by Ivan Kisilov on 16.05.2025.
//

import SwiftUI

struct RegistrationOverlay: View {
    let result: SignUpView.RegResult
    let dismiss: () -> Void

    private var image: Image {
        result == .success ? Image(.regSuccess) : Image(.regResign)
    }
    private var title: String {
        result == .success ? "User successfully registered" : "That email is already registered"
    }
    private var buttonTitle: String {
        result == .success ? "Got it" : "Try again"
    }

    var body: some View {
        ZStack {
            Color.customBackground.ignoresSafeArea()

            VStack(spacing: 32) {
                image
                    .resizable()
                    .scaledToFit()
                    .frame(width: 160, height: 160)

                Text(title)
                    .heading1()
                    .multilineTextAlignment(.center)

                Button(buttonTitle, action: dismiss)
                    .primaryButton()
                    .frame(width: 140)
            }

            VStack {
                HStack {
                    Spacer()
                    Button(action: dismiss) {
                        Image(systemName: "xmark")
                            .font(.title2.weight(.bold))
                            .padding(12)
                            .foregroundStyle(.black)
                    }
                }
                Spacer()
            }
            .padding()
        }
    }
}
