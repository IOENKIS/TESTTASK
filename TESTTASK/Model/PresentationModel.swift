//
//  UserModel.swift
//  TESTTASK
//
//  Created by Ivan Kisilov on 18.05.2025.
//

import SwiftUI

struct UserModel: Identifiable, Equatable {
    let id: Int
    let name: String
    let position: String
    let email: String
    let phone: String
    var avatar: UIImage? = nil
    init(dto: UserDTO) {
        id = dto.id; name = dto.name; position = dto.position
        email = dto.email; phone = dto.phone
    }
}

struct FormInput {
    let name, email, phone: String
    let positionId: Int
    let jpegData: Data
}
