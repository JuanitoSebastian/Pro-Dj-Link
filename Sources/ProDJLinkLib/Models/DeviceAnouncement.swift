//
//  DeviceAnouncement.swift
//  
//
//  Created by Juan Covarrubias on 12.6.2022.
//

import Foundation

public struct DeviceAnouncement: PdlPacket, CustomStringConvertible {

  internal init(received: Date, name: String, ipAddress: String) {
    self.received = received
    self.name = name
    self.ipAddress = ipAddress
  }

  public let received: Date
  let name: String
  public let ipAddress: String

  public var type: PdlPacketType {
    .deviceAnouncement
  }

  public var description: String {
    return """
    Device Anouncement from \(name)
    Received: \(received)
    Ip: \(ipAddress)
    """
  }
}
