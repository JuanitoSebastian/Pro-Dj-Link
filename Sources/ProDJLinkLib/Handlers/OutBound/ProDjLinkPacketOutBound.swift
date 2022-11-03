//
//  ProDjLinkPacketOutBound.swift
//  
//
//  Created by Juan Covarrubias on 2.7.2022.
//

import Foundation
import NIOCore
import Network

public class ProDjLinkPacketOutBound: ChannelOutboundHandler {

  public typealias OutboundIn = AddressedEnvelope<PdlData>
  public typealias OutboundOut = AddressedEnvelope<ByteBuffer>

  public func write(
    context: ChannelHandlerContext,
    data: NIOAny,
    promise: EventLoopPromise<Void>?
  ) {
    let packet = self.unwrapOutboundIn(data)
    switch packet.data.type {
    case .keepAlive:
      guard let keepAlivePacket = packet.data as? KeepAlive else { return }
      guard let bytes = keepAlivePacket.packetBytes else { return }
      let buffer = context.channel.allocator.buffer(buffer: bytes)
      let envelope = try! AddressedEnvelope<ByteBuffer>(remoteAddress: SocketAddress(ipAddress: packet.remoteAddress.ipAddress!, port: packet.remoteAddress.port!), data: buffer)
      context.write(self.wrapOutboundOut(envelope), promise: promise)
    default:
      print("Sending this type of packet is not implemented")
    }
  }

}
