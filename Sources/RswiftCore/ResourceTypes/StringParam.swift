//
//  StringParam.swift
//  R.swift
//
//  Created by Tom Lokhorst on 2016-04-18.
//  From: https://github.com/mac-cain13/R.swift
//  License: MIT License
//
//  Parts of the content of this file are loosly based on StringsFileParser.swift from SwiftGen/GenumKit.
//  We don't feel this is a "substantial portion of the Software" so are not including their MIT license,
//  eventhough we would like to give credit where credit is due by referring to SwiftGen thanking Olivier
//  Halligon for creating SwiftGen and GenumKit.
//
//  See: https://github.com/AliSoftware/SwiftGen/blob/master/GenumKit/Parsers/StringsFileParser.swift
//

import Foundation

import FootlessParser

struct StringParam : Equatable, Unifiable {
  let name: String?
  let spec: FormatSpecifier

  func unify(_ other: StringParam) -> StringParam? {
    if let name = name, let otherName = other.name , name != otherName {
      return nil
    }

    if let spec = spec.unify(other.spec) {
      return StringParam(name: name ?? other.name, spec: spec)
    }

    return nil
  }
}

func ==(lhs: StringParam, rhs: StringParam) -> Bool {
  return lhs.name == rhs.name && lhs.spec == rhs.spec
}

enum FormatPart: Unifiable {
  case spec(FormatSpecifier)
  case reference(String)

  var formatSpecifier: FormatSpecifier? {
    switch self {
    case .spec(let formatSpecifier):
      return formatSpecifier

    case .reference:
      return nil
    }
  }

  // "I give %d apples to %@ %#@named@" --> [.Spec(.Int), .Spec(.String), .Reference("named")]
  static func formatParts(formatString: String) -> [FormatPart] {
    do {
      return try FootlessParser.parse(LocalizedStringParser.formatParts, formatString)
    } catch {
      return []
    }
  }

  func unify(_ other: FormatPart) -> FormatPart? {
    switch (self, other) {
    case let (.spec(l), .spec(r)):
      if let spec = l.unify(r) {
        return .spec(spec)
      }
      else {
        return nil
      }

    case let (.reference(l), .reference(r)) where l == r:
      return .reference(l)

    default:
      return nil
    }
  }
}

// https://developer.apple.com/library/ios/documentation/Cocoa/Conceptual/Strings/Articles/formatSpecifiers.html#//apple_ref/doc/uid/TP40004265-SW1
enum FormatSpecifier {
  case object
  case double
  case int
  case uInt
  case character
  case cStringPointer
  case voidPointer
  case topType

  var type: Type {
    switch self {
    case .object:
      return ._String
    case .double:
      return ._Double
    case .int:
      return ._Int
    case .uInt:
      return ._UInt
    case .character:
      return ._Character
    case .cStringPointer:
      return ._CStringPointer
    case .voidPointer:
      return ._VoidPointer
    case .topType:
      return ._Any
    }
  }
}

extension FormatSpecifier : Unifiable {

  // Convenience initializer, uses last character of string,
  // ignoring lengt modifiers, e.g. "lld"
  init?(formatString string: String) {
    guard let last = string.last else {
      return nil
    }

    self.init(formatChar: last)
  }

  init?(formatChar char: Swift.Character) {
    let lcChar = Swift.String(char).lowercased().first!
    switch lcChar {
    case "@":
      self = .object
    case "a", "e", "f", "g":
      self = .double
    case "d", "i":
      self = .int
    case "o", "u", "x":
      self = .uInt
    case "c":
      self = .character
    case "s":
      self = .cStringPointer
    case "p":
      self = .voidPointer
    default:
      return nil
    }
  }

  func unify(_ other: FormatSpecifier) -> FormatSpecifier? {
    if self == .topType {
      return other
    }

    if other == .topType {
      return self
    }

    if self == other {
      return self
    }

    return nil
  }
}
