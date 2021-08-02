//
//  TypeAlgorithm.swift
//  KeychainOTP
//
//  Created by Дмитрий Лисин on 22.02.2021.
//

import Foundation

public enum TypeAlgorithm: String, CaseIterable, Identifiable {
    case totp = "TOTP"
    case hotp = "HOTP"

    public var id: String { rawValue }
}

public extension String {
    func typeAlgorithmFromString() -> TypeAlgorithm {
        switch self {
        case "totp":
            return .totp
        case "hotp":
            return .hotp
        default:
            return .totp
        }
    }
}
