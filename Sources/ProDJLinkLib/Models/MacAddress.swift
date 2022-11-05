//
//  File.swift
//  
//
//  Created by Juan Covarrubias on 4.11.2022.
//

import Foundation

/// A struct for representing mac addresses. Handy for Pro DJ Link packets
/// since the packets themselfs contain Mac Address of the sender
public struct MacAddress {

  public let address: [UInt8]

  public var addressString: String {
    address
      .map { String(format: "%02X", $0) }
      .enumerated()
      .reduce("") { concat, next in
        let (index, element) = next
        return index < address.count - 1
        ? concat + element + ":"
        : concat + element
      }
  }

  /// Init MacAddress from mac address string. Fails if string is invalid mac address.
  /// - Parameter macAddress: Given mac address string
  /// - Returns: On success MacAddress object. On fail nil.
  public init?(macAddress: String) {
    guard let addressToSet = MacAddress.parseStringToUIntArray(stringToParse: macAddress) else { return nil }
    self.address = addressToSet
  }

  /// Init MacAddress from bytes. Fails if bytes invalid address.
  /// - Parameter macAddress: Mac address bytes
  /// - Returns: On success MacAddress object. On fail nil.
  public init?(macAddress: [UInt8]) {
    guard macAddress.count == 6 else { return nil }
    self.address = macAddress
  }
}

extension MacAddress {

  /// Parses a given mac address string to byets
  /// - Parameter stringToParse: Mac Address String
  /// - Returns: On success [UInt8]. On fail nil.
  private static func parseStringToUIntArray(stringToParse: String) -> [UInt8]? {
    let stringArray = stringToParse.components(separatedBy: ":")
    guard stringArray.count == 6 else { return nil }

    let rawValue: [UInt8] = stringArray
      .compactMap { UInt8($0, radix: 16) }

    return rawValue.count == 6
    ? rawValue
    : nil
  }
}
