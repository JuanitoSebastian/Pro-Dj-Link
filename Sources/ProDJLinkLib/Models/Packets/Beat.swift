//
//  Beat.swift
//  
//
//  Created by Juan Covarrubias on 30.6.2022.
//

import Foundation

public struct Beat: PdlData, CustomStringConvertible {

  public let type: PdlPacketType

  public let name: String
  public let playerNumber: Int
  public let nextBeat: Int
  public let secondBeat: Int
  public let nextBar: Int
  public let fourthBeat: Int
  public let secondBar: Int
  public let eightBeat: Int
  public let pitch: Int
  public let bpm: Int

  internal init(
    name: String,
    playerNumber: Int,
    nextBeat: Int,
    secondBeat: Int,
    nextBar: Int,
    fourthBeat: Int,
    secondBar: Int,
    eightBeat: Int,
    pitch: Int,
    bpm: Int
  ) {
    self.name = name
    self.playerNumber = playerNumber
    self.nextBeat = nextBeat
    self.secondBeat = secondBeat
    self.nextBar = nextBar
    self.fourthBeat = fourthBeat
    self.secondBar = secondBar
    self.eightBeat = eightBeat
    self.pitch = pitch
    self.bpm = bpm
    self.type = .beat
  }


  public var description: String {
    return """
    Beat from \(name)
    BPM: \(bpm)
    Pitch: \(pitch)
    """
  }
}
