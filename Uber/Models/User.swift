//
//  User.swift
//  Uber
//
//  Created by Игорь Михайлов on 12.01.2024.
//

import Firebase

enum AccountType: Int, Codable {
    case passenger, driver
}

struct User: Identifiable, Codable {
    let id: String
    let fullName: String
    let email: String
    let coordinates: GeoPoint
    let accountType: AccountType
    var homeLocation: Location?
    var workLocation: Location?
}

struct UserHomeUpdate: Codable {
    let homeLocation: Location
}

struct UserWorkUpdate: Codable {
    let workLocation: Location
}

struct UserCoordinatesUpdate: Codable {
    let coordinates: GeoPoint
}
