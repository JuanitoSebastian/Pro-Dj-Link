//
//  File.swift
//  
//
//  Created by Juan Covarrubias on 5.11.2022.
//

import Foundation

enum OperationError: Error {
  case deviceAddressError
}

extension OperationError: CustomStringConvertible {

  public var description: String {
    switch self {
    case .deviceAddressError:
      return "Mac and Ip Address not found or invalid"
    }
  }
}
