//
//  File.swift
//  
//
//  Created by Juan Covarrubias on 6.6.2022.
//

import Foundation
import NIOCore

final class ProDjLinkFilter: ChannelInboundHandler {

  typealias InboundIn = AddressedEnvelope<ByteBuffer>
  typealias InboundOut = AddressedEnvelope<ByteBuffer>

  public func channelRead(context: ChannelHandlerContext, data: NIOAny) {
    let addressEnvelope = self.unwrapInboundIn(data)

    let byteBuff = addressEnvelope.data
    let dataFromBuffer = byteBuff.getBytes(at: 0, length: 10)

    guard let dataFromBuffer = dataFromBuffer else { return }

    guard dataFromBuffer == proDjLinkHeader else { return }

    context.fireChannelRead(data)
  }

}
