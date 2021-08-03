//
//  Account.swift
//  KeychainOTP
//
//  Created by Дмитрий Лисин on 21.02.2021.
//

import CryptoKit
import Foundation
import KeychainAccess

/// A model representing an account.
public struct Account: Identifiable, Codable, Hashable {
    /// The id of the account.
    public var id = UUID()
    
    /// A string indicating the account represented by the token.
    ///
    /// This is often an email address or username.
    public let label: String
    
    /// A string indicating the provider or service which issued the token.
    public let issuer: String?
    
    /// A password generator containing this token's secret, algorithm, etc.
    public let generator: Generator

    /// Initializes a new account with the given parameters.
    ///  - Parameters:
    ///     - label: The account name for the token.
    ///     - issuer: The entity which issued the token.
    ///     - generator: The password generator.
    public init(label: String, issuer: String?, generator: Generator) {
        self.label = label
        self.issuer = issuer
        self.generator = generator
    }

    public func incrementCounter(keychain: Keychain) -> Account {
        let account = Account(label: label, issuer: issuer, generator: generator.successor())
        try? account.save(to: keychain)
        return account
    }

    public func generate(time: Date) -> String? {
        let counter = generator.factor.counterValue(at: time)
        return generateOTP(
            secret: generator.secret,
            algorithm: generator.algorithm,
            counter: counter,
            digits: generator.digits
        )
    }

    private func generateOTP(secret: Data, algorithm: OTPAlgorithm = .sha1, counter: UInt64, digits: Int = 6) -> String? {
        // HMAC message data from counter as big endian
        let counterMessage = counter.bigEndian.data

        // HMAC hash counter data with secret key
        var hmac = Data()

        switch algorithm {
        case .sha1:
            hmac = Data(HMAC<Insecure.SHA1>.authenticationCode(for: counterMessage, using: SymmetricKey(data: secret)))
        case .sha256:
            hmac = Data(HMAC<SHA256>.authenticationCode(for: counterMessage, using: SymmetricKey(data: secret)))
        case .sha512:
            hmac = Data(HMAC<SHA512>.authenticationCode(for: counterMessage, using: SymmetricKey(data: secret)))
        }

        // Get last 4 bits of hash as offset
        let offset = Int((hmac.last ?? 0x00) & 0x0F)

        // Get 4 bytes from the hash from [offset] to [offset + 3]
        let truncatedHMAC = Array(hmac[offset ... offset + 3])

        // Convert byte array of the truncated hash to data
        let data = Data(truncatedHMAC)

        // Convert data to UInt32
        var number = UInt32(strtoul(data.bytes.toHexString(), nil, 16))

        // Mask most significant bit
        number &= 0x7FFF_FFFF

        // Modulo number by 10^(digits)
        number = number % UInt32(pow(10, Float(digits)))

        // Convert int to string
        let strNum = String(number)

        // Return string if adding leading zeros is not required
        if strNum.count == digits {
            return strNum
        }

        // Add zeros to start of string if not present and return
        let prefixedZeros = String(repeatElement("0", count: digits - strNum.count))
        return prefixedZeros + strNum
    }

    public func save(to keychain: Keychain) throws {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(self) {
            try keychain
                .label(label)
                .comment("OTP access token")
                .set(encoded, key: id.uuidString)
        }
    }

    public func remove(from keychain: Keychain) throws {
        try keychain.remove(id.uuidString)
    }

    public func loadAll(from keychain: Keychain) -> [Account] {
        let decoder = JSONDecoder()
        let items = keychain.allKeys()
        let accounts = try! items.compactMap { key throws -> Account? in
            guard let data = try keychain.getData(key), let account = try? decoder.decode(Account.self, from: data) else { return nil }
            return account
        }
        return accounts
    }
}
