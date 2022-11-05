//
//  File.swift
//  
//
//  Created by Juan Covarrubias on 5.11.2022.
//

import Foundation
import NIOCore

final class ActivePlayerHandler: ChannelInboundHandler {

  typealias InboundIn = PdlPacket
  typealias InboundOut = PdlPacket

  public var pdlPlayerIpAddresses: NSMutableArray

  internal init(pdlPlayerIpAddresses: NSMutableArray) {
    self.pdlPlayerIpAddresses = pdlPlayerIpAddresses
  }

  public func channelRead(context: ChannelHandlerContext, data: NIOAny) {
    let pdlPacket = self.unwrapInboundIn(data)
    guard let pdlKeepAlive = pdlPacket.data as? KeepAlive  else {
      context.fireChannelRead(data)
      return
    }

    if pdlPlayerIpAddresses.contains(pdlKeepAlive.ipAddress.addressString) || pdlKeepAlive.isMixer {
      context.fireChannelRead(data)
      return
    }

    self.pdlPlayerIpAddresses.add(pdlKeepAlive.ipAddress.addressString)

    context.fireChannelRead(data)
  }
}
