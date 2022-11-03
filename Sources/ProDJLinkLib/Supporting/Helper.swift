//
//  File.swift
//  
//
//  Created by Juan Covarrubias on 3.11.2022.
//

import Foundation
import Network

class Helper {

  static let shared: Helper = Helper()

  private init() {}

  func ipAddressToBytes(ipAddress: String) -> [UInt8]? {
    return IPv4Address(ipAddress)?.rawValue.reversed().reversed()
  }
}
