//
//  SignUpView.swift
//  TESTTASK
//
//  Created by Ivan Kisilov on 14.05.2025.
//

import SwiftUI

struct SignUpView: View {
    @Binding var selectedTab: ContentView.Tab
    @EnvironmentObject var vm: AppViewModel

    // MARK: State
    @State private var name = ""
    @State private var email = ""
    @State private var phone = ""
    @State private var selectedPosition: Position? = nil
    @State private var selectedImage: UIImage? = nil
    @State private var regResult: RegResult?
    @State private var showError = false

    @FocusState private var focusedField: Field?

    // MARK: – Enum
    enum Field { case name, email, phone }
    enum RegResult: Identifiable { case success, emailExists; var id: Int { hashValue } }

    // MARK: – Validation helpers
    private static let emailRx = ##"^(?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*|"(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])*")@(?:(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\[(?:(?:25[0-5]|2[0-4]|[0-1]?\d?\d)(?:\.(?:25[0-5]|2[0-4]|[0-1]?\d?\d)){3}|[a-z0-9-]*[a-z0-9]:(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])+)\])$"##


    private static let phoneRx = #"^\+?380[0-9]{9}$"#

    private var emailError: String? {
        guard showError else { return nil }
        if email.isEmpty { return "Required field" }
        if !isValidEmail(email){ return "Invalid email format" }
        return nil
    }
    
    private var isFormValid: Bool {
        isValidName(name) &&
        isValidEmail(email) &&
        isValidPhone(phone) &&
        selectedPosition != nil &&
        selectedImage != nil
    }

    // MARK: – body
    var body: some View {
        TopBar(title: "Working with POST request")

        ScrollViewReader { proxy in
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // -------- Text fields ----------
                    textFields

                    // -------- Positions ----------
                    PositionPicker(positions: vm.positions,
                                   selected: $selectedPosition,
                                   showError: showError)

                    // -------- Photo ----------
                    PhotoUploadField(image: $selectedImage,
                                     errorMessage: (selectedImage == nil && showError)
                                                    ? "Photo is required" : nil)

                    // -------- Button ----------
                    signUpButton
                }
                .padding(.horizontal, 16)
                .padding(.top, 32)
            }
            .onChange(of: focusedField) { field in
                guard let field else { return }
                withAnimation { proxy.scrollTo(field, anchor: .center) }
            }
        }
        .fullScreenCover(item: $regResult) { res in
            RegistrationOverlay(result: res) {
                regResult = nil
                selectedTab = .users
            }
        }
        .task { await vm.loadPositions() }
    }
}

//────────────────────────────────────────────
// MARK: - Sub-views
//────────────────────────────────────────────
private extension SignUpView {

    // Text Fields block
    var textFields: some View {
        VStack(spacing: 12) {
            CustomTextField(placeholder: "Your name",
                            text: $name, field: .name,
                            errorMessage: name.isEmpty && showError ? "Required field" : nil)
                .id(Field.name)

            CustomTextField(placeholder: "Email",
                            text: $email, field: .email,
                            errorMessage: emailError)
                .id(Field.email)

            CustomTextField(placeholder: "Phone",
                            text: $phone, field: .phone,
                            errorMessage: phone.isEmpty && showError ? "Required field" : nil,
                            supportingText: "+38(XXX) XXX - XX - XX")
                .id(Field.phone)
        }
        .padding(.top, 32)
    }

    // Sign Up button
    var signUpButton: some View {
        Button("Sign up", action: validateForm)
            .primaryButton(enabled: isFormValid)
    }
}

//────────────────────────────────────────────
// MARK: - PositionPicker
//────────────────────────────────────────────
private struct PositionPicker: View {
    let positions: [Position]
    @Binding var selected: Position?
    let showError: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Select your position")
                .body1()
                .padding(.bottom, 12)

            ForEach(positions) { pos in
                RadioButtonField(title: pos.name,
                                 isSelected: selected?.id == pos.id)
                    .onTapGesture { selected = pos }
            }

            if selected == nil && showError {
                Text("Required field")
                    .body3()
                    .padding(.horizontal, 16)
                    .padding(.top, 4)
                    .frame(height: 18)
                    .foregroundStyle(.error)
            }
        }
        .padding(.top, 12)
        .padding(.bottom, 24)
        .padding(.horizontal, 16)
    }
}

//────────────────────────────────────────────
// MARK: - Validation helpers
//────────────────────────────────────────────
private extension SignUpView {
    func isValidName(_ s: String)  -> Bool { (2...60).contains(s.count) }
    private func isValidEmail(_ raw: String) -> Bool {
        let s = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        return NSPredicate(
            format: "SELF MATCHES %@",
            Self.emailRx
        ).evaluate(with: s)
    }
    func isValidPhone(_ s: String) -> Bool {
        NSPredicate(format: "SELF MATCHES %@", Self.phoneRx).evaluate(with: s)
    }
    func jpegDataIfValid(_ img: UIImage) -> Data? {
        guard img.size.width  >= 70, img.size.height >= 70,
              let d = img.jpegData(compressionQuality: 0.8),
              d.count < 5*1024*1024 else { return nil }
        return d
    }
}

//────────────────────────────────────────────
// MARK: - Submit
//────────────────────────────────────────────
private extension SignUpView {
    func validateForm() {
        showError = true
        guard isValidName(name),
              isValidEmail(email),
              isValidPhone(phone),
              let pos = selectedPosition,
              let img = selectedImage,
              let data = jpegDataIfValid(img)
        else { return }

        Task {
            let form = FormInput(name: name, email: email, phone: phone, positionId: pos.id, jpegData: data)
            if await vm.submit(form: form) {
                regResult = .success
            } else if vm.submitError == .emailExists {
                regResult = .emailExists
            }

        }
    }
}
