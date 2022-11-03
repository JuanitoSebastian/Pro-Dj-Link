//
//  ProDjLinkService.swift
//  
//
//  Created by Juan Covarrubias on 19.6.2022.
//

import Foundation
import NIO
import Combine

public class ProDjLinkService {

  public let subject: PassthroughSubject<PdlPacket, Never>

  internal var pdlDeviceIpAddresses: NSMutableArray

  private let group: MultiThreadedEventLoopGroup
  private let queue: DispatchQueue
  private let ipAddressToBind: String
  private let ipAddressUserDevice: String
  private var channels: [Int: Channel]
  private var keepAliveTimer: Timer?
  

  public init(
    ipAddressUserDevice: String
  ) {
    self.group =  MultiThreadedEventLoopGroup(numberOfThreads: 2)
    self.queue = DispatchQueue(label: "ProDjLinkQ")
    self.channels = [:]
    self.ipAddressToBind = ipAddressDefault
    self.ipAddressUserDevice = ipAddressUserDevice
    self.subject = PassthroughSubject<PdlPacket, Never>()
    self.pdlDeviceIpAddresses = []
  }

  public func startServer() {
    queue.async {
      do {
        defer {
          try! self.group.syncShutdownGracefully()
        }
        self.channels[50000] = try self.getBootstrap().bind(host: self.ipAddressToBind, port: 50000).wait()
        self.channels[50001] = try self.getBootstrap().bind(host: self.ipAddressToBind, port: 50001).wait()
        Log.i("Server is running")
        self.scheduleKeepAliveTimer()
        try self.channels.values.forEach { channel in try channel.closeFuture.wait() }
      } catch {
        Log.e("Failed to start server")
      }
    }
  }

  private func scheduleKeepAliveTimer() {
    group.next().scheduleRepeatedTask(initialDelay: .seconds(1), delay: .milliseconds(1500), notifying: nil) { task in
      guard self.pdlDeviceIpAddresses.count > 0 else { return }

      self.pdlDeviceIpAddresses.forEach { pdlDeviceIpAddress in
        guard let pdlDeviceIpAddress = pdlDeviceIpAddress as? String else { return }
        let keepAliveData = KeepAlive(
          name: "CDJ-2000nexus",
          playerNumber: 5,
          macAddress: [0xff, 0xff, 0xff, 0xff, 0xff, 0xff],
          ipAddress: self.ipAddressUserDevice,
          isMixer: true
        )
        let envelope = AddressedEnvelope<PdlData>(
          remoteAddress: try! SocketAddress.init(ipAddress: pdlDeviceIpAddress, port: 50000),
          data: keepAliveData
        )

        guard let channelToUse = self.channels[50000] else { return }
        channelToUse.writeAndFlush(envelope).whenFailure { error in
          Log.e("Keep Alive failed, Error: \(error)")
          task.cancel()
        }
      }
    }
  }

  public func stopServer() {
    channels.values.forEach { channel in _ = channel.close() }
  }

  func getBootstrap() -> DatagramBootstrap {
    let bootstrap = DatagramBootstrap(group: self.group)
      .channelOption(ChannelOptions.socket(SocketOptionLevel(SOL_SOCKET), SO_REUSEADDR), value: 1)
      .channelInitializer { channel in
        channel.pipeline.addHandlers([
          BackPressureHandler(),
          ProDjLinkFilter(pdlDeviceIpAddresses: self.pdlDeviceIpAddresses),
          ProDjLinkDataHandler(),
          ProDjLinkPacketHandler(subject: self.subject),
          ProDjLinkPacketOutBound()
        ])
      }
    return bootstrap
  }

}
