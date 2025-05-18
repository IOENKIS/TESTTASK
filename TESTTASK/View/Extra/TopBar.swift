//
//  TopBar.swift
//  TESTTASK
//
//  Created by Ivan Kisilov on 14.05.2025.
//


import SwiftUI

struct TopBar: View {
    var title: String
    
    var body: some View {
        Rectangle()
            .fill(Color.customPrimary)
            .frame(height: 56)
            .overlay {
                Text(title)
                    .heading2()
            }
    }
}
