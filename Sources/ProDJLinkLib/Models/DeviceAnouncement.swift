//
//  DeviceAnouncement.swift
//  
//
//  Created by Juan Covarrubias on 12.6.2022.
//

import Foundation

public struct DeviceAnouncement: PdlPacket, CustomStringConvertible {

  public let received: Date
  public let name: String
  public let ipAddress: String
  public let isMixer: Bool
  public let type: PdlPacketType

  internal init(received: Date, name: String, ipAddress: String, isMixer: Bool) {
    self.received = received
    self.name = name
    self.ipAddress = ipAddress
    self.isMixer = isMixer
    self.type = .deviceAnouncement
  }

  public var description: String {
    return """
    Device Anouncement from \(name)
    Received: \(received)
    Ip: \(ipAddress)
    """
  }
}
