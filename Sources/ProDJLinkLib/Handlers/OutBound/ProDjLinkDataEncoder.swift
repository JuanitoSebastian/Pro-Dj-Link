//
//  ProDjLinkPacketOutBound.swift
//  
//
//  Created by Juan Covarrubias on 2.7.2022.
//

import Foundation
import NIOCore
import Network

/// A ChannelOutBoundHandler that converts given PdlData objects to ByteBuffers that can
/// be sent to Pro DJ Link equipment
public class ProDjLinkDataEncoder: ChannelOutboundHandler {

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
      guard let bytes = keepAlivePacketToByteBuffer(packet: keepAlivePacket) else { return }
      let buffer = context.channel.allocator.buffer(buffer: bytes)
      let envelope = try! AddressedEnvelope<ByteBuffer>(remoteAddress: SocketAddress(ipAddress: packet.remoteAddress.ipAddress!, port: packet.remoteAddress.port!), data: buffer)
      context.write(self.wrapOutboundOut(envelope), promise: promise)
    default:
      Log.e("Sending this type of packet is not implemented")
    }
  }

}

extension ProDjLinkDataEncoder {

  /// Converts a given KeepAlive object to a ByteBuffer
  ///  - Parameter packet: Packet to convert to bytes
  ///  - Returns ByteBuffer on success. nil on fail.
  private func keepAlivePacketToByteBuffer(packet: KeepAlive) -> ByteBuffer? {
    var buff = ByteBuffer()
    buff.writeBytes(proDjLinkHeader)
    buff.writeBytes([packet.type.typeIdentifier])
    buff.writeBytes([0x00])

    // Device Name padded with 0x00
    buff.writeString(packet.name)
    let amountOfPadding = 0x20 - buff.readableBytes
    buff.writeBytes([UInt8](repeating: 0x00, count: amountOfPadding))

    buff.writeBytes([0x01, 0x02])
    buff.writeInteger(UInt16(0x35)) // Packet length
    buff.writeBytes([UInt8(packet.playerNumber)])
    buff.writeBytes([0x01])

    buff.writeBytes(packet.macAddress.address)
    buff.writeBytes(packet.ipAddress.address)

    buff.writeBytes([0x01, 0x00, 0x00, 0x00, 0x01, 0x00])

    return buff
  }
}
