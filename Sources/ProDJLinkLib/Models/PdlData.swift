//
//  PdlPacket.swift
//  
//
//  Created by Juan Covarrubias on 8.6.2022.
//

import Foundation

public protocol PdlData {

  var type: PdlPacketType { get }

}

public enum PdlPacketType {

  // PORT 50000
  case keepAlive
  case deviceAnouncement

  // PORT 50001
  case beat

  public static func determineType(identifier: UInt8, port: Int) -> PdlPacketType? {
    if port == 50000 {
      switch identifier {
      case 0x06:
        return .keepAlive
      case 0x0a:
        return .deviceAnouncement
      default:
        return nil
      }
    }

    if port == 50001 {
      switch identifier {
      case 0x28:
        return .beat
      default:
        return nil
      }
    }

    return nil
  }

  var typeIdentifier: UInt8 {
    switch self {
    case .keepAlive: return 0x06
    case .deviceAnouncement: return 0x0a
    case .beat: return 0x28
    }
  }
}

public struct PdlPacket {

  public let senderIpAddress: String
  public let received: Date
  public let data: PdlData

}
