//
//  File.swift
//  
//
//  Created by Juan Covarrubias on 5.11.2022.
//

import Foundation

public struct IpAddress {

  public let address: [UInt8]

  public var addressString: String {
    address
      .map { String($0) }
      .enumerated()
      .reduce("") { concat, next in
        let (index, element) = next
        return index < address.count - 1
        ? concat + element + "."
        : concat + element
      }
  }

  /// Init IpAddress from mac address string. Fails if string is invalid mac address.
  /// - Parameter ipAddress: Given ip address string
  /// - Returns: On success IpAddress object. On fail nil.
  public init?(ipAddress: String) {
    guard let addressToSet = IpAddress.parseStringToUIntArray(stringToParse: ipAddress) else { return nil }
    self.address = addressToSet
  }

  /// Init MacAddress from bytes. Fails if bytes invalid address.
  /// - Parameter ipAddress: Mac address bytes
  /// - Returns: On success IpAddress object. On fail nil.
  public init?(ipAddress: [UInt8]) {
    guard ipAddress.count == 4 else { return nil }
    self.address = ipAddress
  }
}

extension IpAddress {

  /// Parses a given ip address string to byets
  /// - Parameter stringToParse: Mac Address String
  /// - Returns: On success [UInt8]. On fail nil.
  private static func parseStringToUIntArray(stringToParse: String) -> [UInt8]? {
    let stringArray = stringToParse.components(separatedBy: ".")
    guard stringArray.count == 4 else { return nil }

    let rawValue: [UInt8] = stringArray
      .compactMap { UInt8($0) }

    return rawValue.count == 4
    ? rawValue
    : nil
  }
}

