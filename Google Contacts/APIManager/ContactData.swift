//
//  ContactData.swift
//  Google Contacts
//
//  Created by Alex Mosunov on 23.01.2021.
//

import Foundation


struct ContactData: Codable {
    let feed: FeedData
}

struct FeedData: Codable {
    let entry: [EntryData]
}

struct EntryData: Codable {
    let title: TitleData?
}

struct TitleData: Codable {
    let contactTitle: String?
    enum CodingKeys: String, CodingKey {
            case contactTitle = "$t"
        }
}
