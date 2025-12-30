//
//  NasaStuffModel.swift
//  NasaGallary
//
//  Created by Nitin Kapasiya on 29/12/25.
//

import Foundation

struct NasaStuffModel: Codable {
    let copyright: String?
    let date: String
    let explanation: String
    let hdurl: String?
    let mediaType: String
    let serviceVersion: String?
    let title: String
    let url: String

    enum CodingKeys: String, CodingKey {
        case copyright
        case date
        case explanation
        case hdurl
        case mediaType = "media_type"
        case serviceVersion = "service_version"
        case title
        case url
    }
}

extension NasaStuffModel {
    var displayMediaURL: String {
        hdurl ?? url
    }

    var isImage: Bool {
        mediaType == "image"
    }

    var isVideo: Bool {
        mediaType == "video"
    }
}

