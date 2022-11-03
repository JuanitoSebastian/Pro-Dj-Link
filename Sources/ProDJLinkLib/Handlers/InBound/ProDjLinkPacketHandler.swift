//
//  File.swift
//  
//
//  Created by Juan Covarrubias on 12.6.2022.
//

import Foundation
import NIO
import Combine

final class ProDjLinkPacketHandler: ChannelInboundHandler {

  typealias InboundIn = PdlPacket
  typealias InboundOut = PdlPacket
  let subject: PassthroughSubject<PdlPacket, Never>

  internal init(subject: PassthroughSubject<PdlPacket, Never>) {
    self.subject = subject
  }

  public func channelRead(context: ChannelHandlerContext, data: NIOAny) {
    let packet = self.unwrapInboundIn(data)
    Log.i(packet)
    self.subject.send(packet)
  }

}
