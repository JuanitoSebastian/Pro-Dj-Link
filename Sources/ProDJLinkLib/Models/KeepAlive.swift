//
//  KeepAlive.swift
//  
//
//  Created by Juan Covarrubias on 12.6.2022.
//

import Foundation

public struct KeepAlive: PdlPacket, CustomStringConvertible {

  public let received: Date
  public let name: String
  public let playerNumber: Int
  public let isMixer: Bool
  public let macAddress: [UInt8]
  public let ipAddress: String

  internal init(
    received: Date,
    name: String,
    playerNumber: Int,
    macAddress: [UInt8],
    ipAddress: String,
    isMixer: Bool
  ) {
    self.received = received
    self.name = name
    self.playerNumber = playerNumber
    self.macAddress = macAddress
    self.ipAddress = ipAddress
    self.isMixer = isMixer
  }

  public var type: PdlPacketType {
    .keepAlive
  }

  public var macAddressString: String {
    macAddress
      .map { String(format: "%02X", $0) }
      .reduce("", { concat, value in
        return concat == "" ? concat + value : concat + ":" + value
      })
  }

  public var description: String {
    return """
    Keep Alive from \(name)
    Received: \(received)
    Ip: \(ipAddress)
    Mac: \(macAddressString)
    Player Number: \(playerNumber)
    IsMixer: \(isMixer)
    """
  }

}
