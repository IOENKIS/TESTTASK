//
//  SplashView.swift
//  TESTTASK
//
//  Created by Ivan Kisilov on 14.05.2025.
//

import SwiftUI

struct SplashView: View {
    var body: some View {
        ZStack{
            Color.customPrimary.ignoresSafeArea()
            VStack{
                Spacer()
                Image(.catLogo)
                    .resizable()
                    .scaledToFit()
                    .scaleEffect(0.7)
                Image(.testTaskLogo)
                    .resizable()
                    .scaledToFit()
                Spacer()
            }
            .padding(100)
        }
    }
}

#Preview {
    SplashView()
}
