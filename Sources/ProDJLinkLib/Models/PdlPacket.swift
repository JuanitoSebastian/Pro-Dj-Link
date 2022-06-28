//
//  PdlPacket.swift
//  
//
//  Created by Juan Covarrubias on 8.6.2022.
//

import Foundation

public protocol PdlPacket {

  var type: PdlPacketType { get }
  var received: Date { get }
  var ipAddress: String { get }

}

public enum PdlPacketType: UInt8 {

  case keepAlive = 0x06
  case deviceAnouncement = 0x0a

}
