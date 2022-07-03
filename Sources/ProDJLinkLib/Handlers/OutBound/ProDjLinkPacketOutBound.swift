//
//  ProDjLinkPacketOutBound.swift
//  
//
//  Created by Juan Covarrubias on 2.7.2022.
//

import Foundation
import NIOCore

public class ProDjLinkPacketOutBound: ChannelOutboundHandler {

  public typealias OutboundIn = PdlData
  public typealias OutboundOut = AddressedEnvelope<ByteBuffer>

  public func write(
    context: ChannelHandlerContext,
    data: NIOAny,
    promise: EventLoopPromise<Void>?
  ) {
    let packet = self.unwrapOutboundIn(data)



    switch packet.type {
    case .keepAlive:
      let bytes = packetToByteBuffer(packet: packet as! KeepAlive)
      let buffer = context.channel.allocator.buffer(buffer: bytes)
      // let envelope = AddressedEnvelope<ByteBuffer>(remoteAddress: SocketAddress.makeAddressResolvingHost(<#T##host: String##String#>, port: <#T##Int#>), data: buffer)
      // context.write(self.wrapOutboundOut(envelope))
    default:
      print("Sending this type of packet is not implemented")
    }
  }

  private func packetToByteBuffer(packet: KeepAlive) -> ByteBuffer {
    var buff = ByteBuffer()
    buff.writeBytes(proDjLinkHeader)
    buff.writeBytes([packet.type.typeIdentifier])
    buff.writeBytes([0x00])
    buff.writeString(packet.name)

    let amountOfPadding = 0x1f - buff.readableBytes
    buff.writeBytes([UInt8](repeating: 0x00, count: amountOfPadding))

    buff.writeBytes([0x01, 0x02])
    buff.writeInteger(UInt16(0x35))

    return buff
  }
}
