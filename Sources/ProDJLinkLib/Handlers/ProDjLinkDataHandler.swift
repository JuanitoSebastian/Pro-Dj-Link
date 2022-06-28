//
//  File.swift
//  
//
//  Created by Juan Covarrubias on 7.6.2022.
//

import Foundation
import NIO

final class ProDjLinkDataHandler: ChannelInboundHandler {

  typealias InboundIn = AddressedEnvelope<ByteBuffer>
  typealias InboundOut = PdlPacket

  public func channelRead(context: ChannelHandlerContext, data: NIOAny) {
    let addressedEnvelope = self.unwrapInboundIn(data)
    let typeRaw = addressedEnvelope.data.getBytes(at: 10, length: 1)
    guard let typeRaw = typeRaw else { return }

    let packetType = PdlPacketType(rawValue: typeRaw[0])

    do {
      switch packetType {
      case .keepAlive:
        let packet = try createKeepAlivePacket(message: addressedEnvelope)
        context.fireChannelRead(self.wrapInboundOut(packet))

      case .deviceAnouncement:
        let packet = try createDeviceAnouncementPacket(message: addressedEnvelope)
        context.fireChannelRead(self.wrapInboundOut(packet))

      default:
        print("Message was not recognized")
      }
    } catch {
      print("Message was not recognized")
    }
  }

  private func createKeepAlivePacket(message: AddressedEnvelope<ByteBuffer>) throws -> KeepAlive {
    let data = message.data
    let name = decodeStringFromBytes(atIndex: 12, length: 20, bytes: data)
    let playerNumber = decodeIntFromBytes(atIndex: 36, length: 1, bytes: data)
    let deviceType = decodeIntFromBytes(atIndex: 55, length: 1, bytes: data)
    let macAddress = data.getBytes(at: 40, length: 6)

    guard
      let name = name,
      let playerNumber = playerNumber,
      let deviceType = deviceType,
      let macAddress = macAddress,
      let ipAddress = message.remoteAddress.ipAddress
    else {
      throw PdlError.decodingError
    }

    let packet = KeepAlive(
      received: Date(),
      name: name,
      playerNumber: playerNumber,
      macAddress: macAddress,
      ipAddress: ipAddress,
      isMixer: deviceType != 1
    )

    return packet
  }

  private func createDeviceAnouncementPacket(message: AddressedEnvelope<ByteBuffer>) throws -> DeviceAnouncement {
    let data = message.data
    let name = decodeStringFromBytes(atIndex: 12, length: 20, bytes: data)
    let deviceType = decodeIntFromBytes(atIndex: 36, length: 1, bytes: data)
    let ipAddress = message.remoteAddress.ipAddress

    guard let name = name, let deviceType = deviceType, let ipAddress = ipAddress else {
      throw PdlError.decodingError
    }

    let packet = DeviceAnouncement(
      received: Date(),
      name: name,
      ipAddress: ipAddress,
      isMixer: deviceType != 1
    )

    return packet
  }

}

// MARK: - Helper Functions
extension ProDjLinkDataHandler {

  /// Decodes a string from given ByteBuffer
  /// - Parameter at: Where to start decoding from
  /// - Parameter length: Length in bytes of section to decode
  /// - Parameter bytes: ByteBuffer to decode from
  private func decodeStringFromBytes(atIndex: Int, length: Int, bytes: ByteBuffer) -> String? {
    let clippedData = bytes.getBytes(at: atIndex, length: length)
    guard let clippedData = clippedData else {
      return nil
    }

    // Remove padding by filtering
    let stringToReturn = String(bytes: clippedData.filter { $0 != 0 }, encoding: .utf8)

    guard let stringToReturn = stringToReturn else {
      return nil
    }

    return stringToReturn
  }

  /// Decodes an integer from given ByteBuffer
  /// - Parameter at: Where to start decoding from
  /// - Parameter bytes: ByteBuffer to decode from
  private func decodeIntFromBytes(atIndex: Int, length: Int, bytes: ByteBuffer) -> Int? {
    switch length {
    case 1:
      let decodedNumber: UInt8? = bytes.getInteger(at: atIndex)
      guard let decodedNumber = decodedNumber else {
        return nil
      }
      return Int(decodedNumber)
    default:
      let decodedNumber: Int? = bytes.getInteger(at: atIndex)
      guard let decodedNumber = decodedNumber else {
        return nil
      }
      return Int(decodedNumber)
    }
  }
}
