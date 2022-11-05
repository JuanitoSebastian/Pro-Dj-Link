//
//  KeepAlive.swift
//  
//
//  Created by Juan Covarrubias on 12.6.2022.
//

import Foundation
import Network
import NIOCore

public struct KeepAlive: PdlData, CustomStringConvertible {

  public let name: String
  public let playerNumber: Int
  public let isMixer: Bool
  public let macAddress: MacAddress
  public let ipAddress: IpAddress
  public let type: PdlPacketType

  internal init(
    name: String,
    playerNumber: Int,
    macAddress: MacAddress,
    ipAddress: IpAddress,
    isMixer: Bool
  ) {
    self.name = name
    self.playerNumber = playerNumber
    self.macAddress = macAddress
    self.ipAddress = ipAddress
    self.isMixer = name.contains("DJM")
    self.type = .keepAlive
  }

  public var description: String {
    return """
    Keep Alive from \(name)
    Ip: \(ipAddress.addressString)
    Mac: \(macAddress.addressString)
    Player Number: \(playerNumber)
    IsMixer: \(isMixer)
    """
  }
}
