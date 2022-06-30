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

  let group: MultiThreadedEventLoopGroup
  let queue: DispatchQueue
  let ipAddress: String
  let port: Int
  var channels: [Channel]

  public init(
    ipAddress: String = defaultIpAddress,
    port: Int = defaultPort
  ) {
    self.group =  MultiThreadedEventLoopGroup(numberOfThreads: 2)
    self.queue = DispatchQueue(label: "ProDjLinkQ")
    self.channels = []
    self.ipAddress = ipAddress
    self.port = port
    self.subject = PassthroughSubject<PdlPacket, Never>()
  }

  public func startServer() {
    queue.async {
      let ipAddress = defaultIpAddress
      let port = defaultPort

      do {
        defer {
          try! self.group.syncShutdownGracefully()
        }

        try self.channels.append(self.getBootstrap().bind(host: ipAddress, port: 50000).wait())
        try self.channels.append(self.getBootstrap().bind(host: ipAddress, port: 50001).wait())
        print("Server running at: \(ipAddress) port \(port)")
        try self.channels.forEach { channel in try channel.closeFuture.wait() }
      } catch {
        print("Failed to start Server")
      }
    }
  }

  public func stopServer() {
    channels.forEach { channel in channel.close() }
  }

  func getBootstrap() -> DatagramBootstrap {
    let bootstrap = DatagramBootstrap(group: self.group)
      .channelOption(ChannelOptions.socket(SocketOptionLevel(SOL_SOCKET), SO_REUSEADDR), value: 1)
      .channelInitializer { channel in
        channel.pipeline.addHandlers([
          BackPressureHandler(),
          ProDjLinkFilter(),
          ProDjLinkDataHandler(),
          ProDjLinkPacketHandler(subject: self.subject)]
        )
      }
    return bootstrap
  }

}
