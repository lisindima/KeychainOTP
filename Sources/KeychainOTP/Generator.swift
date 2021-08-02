//
//  Generator.swift
//  KeychainOTP
//
//  Created by Дмитрий Лисин on 22.02.2021.
//

import Foundation

public struct Generator: Codable, Hashable {
    /// The cryptographic hash function used to generate the password.
    public let algorithm: OTPAlgorithm
    
    /// The secret shared between the client and server.
    public let secret: Data
    
    /// The moving factor, either timer- or counter-based.
    public let factor: Factor
    
    /// The number of digits in the password.
    public let digits: Int

    /// Initializes a new password generator with the given parameters.
    ///  - Parameters:
    ///     - algorithm: The cryptographic hash function.
    ///     - secret: The shared secret.
    ///     - factor: The moving factor.
    ///     - digits: The number of digits in the password.
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
