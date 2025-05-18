//
//  RadioButtonField.swift
//  TESTTASK
//
//  Created by Ivan Kisilov on 16.05.2025.
//

import SwiftUI

struct RadioButtonField: View {
    var title: String
    let isSelected: Bool
    
    var body: some View {
        HStack(spacing: 8){
            Circle()
                .strokeBorder(lineWidth: (isSelected ? 4 : 1))
                .foregroundColor(isSelected ? .customSecondary : .gray.opacity(0.5))
                .background(Circle().fill(Color.white))
                .frame(width: 14, height: 14)
                .padding(17)
            Text(title)
                .body2()
            Spacer()
        }
    }
}
