//
//  Factor.swift
//  KeychainOTP
//
//  Created by Дмитрий Лисин on 22.02.2021.
//

import Foundation

public enum Factor {
    case counter(UInt64)
    case timer(period: TimeInterval)

    func counterValue(at time: Date) -> UInt64 {
        switch self {
        case let .counter(counter):
            return counter
        case let .timer(period):
            let timeSinceEpoch = time.timeIntervalSince1970
            return UInt64(timeSinceEpoch / period)
        }
    }

    public var getTypeAlgorithm: TypeAlgorithm {
        switch self {
        case .counter:
            return .hotp
        case .timer:
            return .totp
        }
    }

    public var getValuePeriod: TimeInterval {
        switch self {
        case .counter:
            return 30
        case let .timer(period):
            return period
        }
    }
}

extension Factor {
    enum CodingKeys: String, CodingKey {
        case counter, timer
    }
}

extension Factor: Codable, Hashable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case let .counter(counter):
            try container.encode(counter, forKey: .counter)
        case let .timer(period):
            try container.encode(period, forKey: .timer)
        }
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let key = container.allKeys.first

        switch key {
        case .counter:
            let counter = try container.decode(UInt64.self, forKey: .counter)
            self = .counter(counter)
        case .timer:
            let timer = try container.decode(TimeInterval.self, forKey: .timer)
            self = .timer(period: timer)
        default:
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: container.codingPath,
                    debugDescription: "Unabled to decode enum."
                )
            )
        }
    }
}
