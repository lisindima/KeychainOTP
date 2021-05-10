//
//  Generator.swift
//  OTP
//
//  Created by Дмитрий Лисин on 22.02.2021.
//

import Combine
import Foundation

public struct Generator: Codable, Hashable {
    public let algorithm: OTPAlgorithm
    public let secret: Data
    public let factor: Factor
    public let digits: Int

    public init(algorithm: OTPAlgorithm, secret: Data, factor: Factor, digits: Int) {
        self.algorithm = algorithm
        self.secret = secret
        self.factor = factor
        self.digits = digits
    }

    public func successor() -> Generator {
        switch factor {
        case let .counter(counterValue):
            return Generator(
                algorithm: algorithm,
                secret: secret,
                factor: .counter(counterValue + 1),
                digits: digits
            )
        case .timer:
            return self
        }
    }
}
