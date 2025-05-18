//
//  UserDTO.swift
//  TESTTASK
//
//  Created by Ivan Kisilov on 18.05.2025.
//

import SwiftUI

struct UserDTO: Decodable {
    let id: Int
    let name: String
    let email: String
    let phone: String
    let photo: URL
    let position: String
}
struct Position: Identifiable, Decodable { let id: Int; let name: String }

struct UsersResponse: Decodable {
    let success: Bool
    let page: Int
    let totalPages: Int
    let links: Links
    let users: [UserDTO]
    struct Links: Decodable { let nextUrl: URL?; let prevUrl: URL? }
}

struct PositionsResponse: Decodable { let positions: [Position] }
struct TokenResponse: Decodable { let success: Bool; let token: String }
struct PostOK: Decodable { let success: Bool; let userId: Int }
struct APIError: Decodable { let success: Bool; let message: String }
