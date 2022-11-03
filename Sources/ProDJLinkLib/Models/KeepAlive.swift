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
  public let macAddress: [UInt8]
  public let ipAddress: String
  public let type: PdlPacketType

  internal init(
    name: String,
    playerNumber: Int,
    macAddress: [UInt8],
    ipAddress: String,
    isMixer: Bool
  ) {
    self.name = name
    self.playerNumber = playerNumber
    self.macAddress = macAddress
    self.ipAddress = ipAddress
    self.isMixer = name.contains("DJM")
    self.type = .keepAlive
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
    Ip: \(ipAddress)
    Mac: \(macAddressString)
    Player Number: \(playerNumber)
    IsMixer: \(isMixer)
    """
  }

  var packetBytes: ByteBuffer? {
    guard let ipAddress = Helper.shared.ipAddressToBytes(ipAddress: self.ipAddress) else { return nil }

    var buff = ByteBuffer()
    buff.writeBytes(proDjLinkHeader)
    buff.writeBytes([self.type.typeIdentifier])
    buff.writeBytes([0x00])

    // Device Name padded with 0x00
    buff.writeString(self.name)
    let amountOfPadding = 0x20 - buff.readableBytes
    buff.writeBytes([UInt8](repeating: 0x00, count: amountOfPadding))

    buff.writeBytes([0x01, 0x02])
    buff.writeInteger(UInt16(0x35)) // Packet length
    buff.writeBytes([UInt8(self.playerNumber)])
    buff.writeBytes([0x01])

    buff.writeBytes(self.macAddress)
    buff.writeBytes(ipAddress)

    buff.writeBytes([0x01, 0x00, 0x00, 0x00, 0x01, 0x00])

    return buff
  }

}
