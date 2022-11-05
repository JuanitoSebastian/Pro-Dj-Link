//
//  DeviceAnouncement.swift
//  
//
//  Created by Juan Covarrubias on 12.6.2022.
//

import Foundation

public struct DeviceAnouncement: PdlData, CustomStringConvertible {

  public let name: String
  public let isMixer: Bool
  public let type: PdlPacketType

  internal init(name: String, isMixer: Bool) {
    self.name = name
    self.isMixer = isMixer
    self.type = .deviceAnouncement
  }

  public var description: String {
    return """
    Device Anouncement from \(name)
    """
  }
}
