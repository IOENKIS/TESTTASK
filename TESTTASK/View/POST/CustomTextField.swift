//
//  CustomTextField.swift
//  TESTTASK
//
//  Created by Ivan Kisilov on 16.05.2025.
//

import SwiftUI

struct CustomTextField: View {
    var placeholder: String
    @Binding var text: String
    var field: SignUpView.Field // Це допоможе визначити, яке поле в фокусі
    @FocusState private var focusedField: SignUpView.Field? // Тепер локальний state
    var errorMessage: String? = nil
    private var hasError: Bool { errorMessage != nil }
    var supportingText: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .leading) {
                // TextField з порожнім плейсхолдером
                TextField("", text: $text)
                    .textFieldStyle(PlainTextFieldStyle())
                    .padding(.horizontal, 14)
                    .padding(.vertical, 16)
                    .background(RoundedRectangle(cornerRadius: 4).strokeBorder(hasError ? .error : (focusedField == field ? .customSecondary : .gray.opacity(0.6)), lineWidth: 2))
                    .focused($focusedField, equals: field)
                    .onTapGesture {
                        focusedField = field
                    }
                
                // Плейсхолдер, який буде завжди поверх
                Text(placeholder)
                    .foregroundColor(hasError ? .error : (focusedField == field && text.isEmpty ? .customSecondary : .gray))
                    .padding(.leading, 16)
                    .scaleEffect(focusedField == field || !text.isEmpty ? 0.75 : 1, anchor: .leading) // Плейсхолдер зменшується коли є фокус або текст
                    .offset(x: focusedField == field || !text.isEmpty ? 0 : 10, y: focusedField == field || !text.isEmpty ? -16 : 0) // Зсуваємо плейсхолдер вгору
                    .animation(.easeInOut(duration: 0.2), value: focusedField)
                
            }
            let info = hasError ? errorMessage : supportingText
            let showInfo = hasError || supportingText != nil
            
            Text(info ?? " ")
                .body3()
                .padding(.horizontal, 16)
                .padding(.top, 4)
                .frame(height: 18, alignment: .top)
                .foregroundStyle(hasError ? .error : .black.opacity(0.6))
                .opacity(showInfo ? 1 : 0)
        }
    }
}

