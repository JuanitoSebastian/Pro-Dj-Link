//
//  File.swift
//  
//
//  Created by Juan Covarrubias on 7.6.2022.
//

import Foundation
import NIO

final class ProDjLinkDataDecoder: ChannelInboundHandler {

  typealias InboundIn = AddressedEnvelope<ByteBuffer>
  typealias InboundOut = PdlPacket

  public func channelRead(context: ChannelHandlerContext, data: NIOAny) {
    let addressedEnvelope = self.unwrapInboundIn(data)
    guard
      let typeRaw = addressedEnvelope.data.getBytes(at: 10, length: 1),
      let port = context.localAddress?.port
    else {
      return
    }

    let packetType = PdlPacketType.determineType(identifier: typeRaw[0], port: port)

    do {
      switch packetType {
      case .keepAlive:
        let packet = try createKeepAlivePacket(message: addressedEnvelope)
        context.fireChannelRead(self.wrapInboundOut(packet))

      case .deviceAnouncement:
        let packet = try createDeviceAnouncementPacket(message: addressedEnvelope)
        context.fireChannelRead(self.wrapInboundOut(packet))

      case .beat:
        let packet = try createBeatPacket(message: addressedEnvelope)
        context.fireChannelRead(self.wrapInboundOut(packet))

      default:
        Log.w("Message type was not recognized")
      }
    } catch PdlError.decodingError {
      Log.e("Packet values could not be decoded")
    } catch {
      Log.e("Error receiving packet")
    }
  }

  private func createKeepAlivePacket(message: AddressedEnvelope<ByteBuffer>) throws -> PdlPacket {
    let data = message.data
    let name = decodeStringFromBytes(atIndex: 0x0c, length: 20, bytes: data)
    let playerNumber = decodeIntFromBytes(atIndex: 0x24, length: 1, bytes: data)
    let deviceType = decodeIntFromBytes(atIndex: 0x34, length: 1, bytes: data)
    let macAddressRaw = data.getBytes(at: 0x26, length: 6)

    guard
      let name,
      let playerNumber,
      let deviceType,
      let macAddressRaw,
      let senderIpAddressString = message.remoteAddress.ipAddress
    else {
      throw PdlError.decodingError
    }

    guard let macAddress = MacAddress(macAddress: macAddressRaw) ,
    let senderIpAddress = IpAddress(ipAddress: senderIpAddressString) else {
      throw PdlError.decodingError
    }

    let pdlData = KeepAlive(
      name: name,
      playerNumber: playerNumber,
      macAddress: macAddress,
      ipAddress: senderIpAddress,
      isMixer: deviceType != 1
    )

    let packet = PdlPacket(
      senderIpAddress: senderIpAddress.addressString,
      received: Date.now,
      data: pdlData
    )

    return packet
  }

  private func createDeviceAnouncementPacket(message: AddressedEnvelope<ByteBuffer>) throws -> PdlPacket {
    let data = message.data

    guard
      let name = decodeStringFromBytes(atIndex: 0x0c, length: 20, bytes: data),
      let deviceType = decodeIntFromBytes(atIndex: 0x24, length: 1, bytes: data),
      let senderIpAddress = message.remoteAddress.ipAddress
    else {
      throw PdlError.decodingError
    }

    let pdlData = DeviceAnouncement(
      name: name,
      isMixer: deviceType != 1
    )

    let packet = PdlPacket(
      senderIpAddress: senderIpAddress,
      received: Date.now,
      data: pdlData
    )

    return packet
  }

  private func createBeatPacket(message: AddressedEnvelope<ByteBuffer>) throws -> PdlPacket {
    let data = message.data

    guard
      let name = decodeStringFromBytes(atIndex: 0x0b, length: 0x14, bytes: data),
      let playerNumber = decodeIntFromBytes(atIndex: 0x21, length: 1, bytes: data),
      let nextBeat = decodeIntFromBytes(atIndex: 0x24, length: 32, bytes: data),
      let secondBeat = decodeIntFromBytes(atIndex: 0x28, length: 32, bytes: data),
      let nextBar = decodeIntFromBytes(atIndex: 0x2c, length: 32, bytes: data),
      let fourthBeat = decodeIntFromBytes(atIndex: 0x30, length: 32, bytes: data),
      let secondBar = decodeIntFromBytes(atIndex: 0x34, length: 32, bytes: data),
      let eightBeat = decodeIntFromBytes(atIndex: 0x3a, length: 32, bytes: data),
      let pitch = decodeIntFromBytes(atIndex: 0x54, length: 32, bytes: data),
      let bpm = decodeIntFromBytes(atIndex: 0x5a, length: 16, bytes: data),
      let senderIpAddress = message.remoteAddress.ipAddress
    else {
      throw PdlError.decodingError
    }

    let pdlData = Beat(
      name: name,
      playerNumber: playerNumber,
      nextBeat: nextBeat,
      secondBeat: secondBeat,
      nextBar: nextBar,
      fourthBeat: fourthBeat,
      secondBar: secondBar,
      eightBeat: eightBeat,
      pitch: pitch,
      bpm: bpm
    )

    let packet = PdlPacket(
      senderIpAddress: senderIpAddress,
      received: Date.now,
      data: pdlData)

    return packet

  }

}

// MARK: - Helper Functions
extension ProDjLinkDataDecoder {

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
    case 16:
      let decodedNumber: UInt16? = bytes.getInteger(at: atIndex)
      guard let decodedNumber = decodedNumber else {
        return nil
      }
      return Int(decodedNumber)
    case 32:
      let decodedNumber: UInt32? = bytes.getInteger(at: atIndex)
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
