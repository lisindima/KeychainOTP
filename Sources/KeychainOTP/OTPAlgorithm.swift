//
//  OTPAlgorithm.swift
//  OTP
//
//  Created by Дмитрий Лисин on 22.02.2021.
//

import Foundation

public enum OTPAlgorithm: String, CaseIterable, Identifiable, Codable {
    case sha1 = "SHA1"
    case sha256 = "SHA256"
    case sha512 = "SHA512"

    public var id: String { rawValue }
}

public extension String {
    func algorithmFromString() -> OTPAlgorithm {
        switch self {
        case "SHA1":
            return .sha1
        case "SHA256":
            return .sha256
        case "SHA512":
            return .sha512
        default:
            return .sha1
        }
    }
}
