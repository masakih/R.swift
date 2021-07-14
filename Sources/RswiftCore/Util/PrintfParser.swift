//
//  PrintfParser.swift
//  printfFormatParserForR
//
//  Created by Hori,Masaki on 2021/07/11.
//

import FootlessParser

enum LocalizedStringParser {

  // parse String Format Specifiers and the IEEE printf specification.
  //
  // %[parameter][flags][width][.precision][length]type

  typealias ParsedType = Parser<Character, Optional<FormatPart>>

  static func formatPartSpec<A>(_ output: FormatSpecifier?) -> (A) -> FormatPart? {
    { _ in output.map { .spec($0) } }
  }

  static func filtered(parts: [FormatPart?]) -> [FormatPart] {
    parts.compactMap { $0 }
  }

  static let percent = char("%")

  static let parameter = oneOrMore(digit) *> string("$")
  static let flags = string("-") <|> string("+") <|> string(" ") <|> string("0") <|> string("'") <|> string("#")
  static let width = oneOrMore(digit)
  static let precision = string(".") *> zeroOrMore(digit)
  static let length = string("hh") <|> string("h") <|>
    string("ll") <|> string("l") <|> string("L") <|>
    string("q") <|>
    string("z") <|>
    string("j") <|>
    string("t")

  static let objectTypePerser = char("@")
  static let doubleTypePerser = char("a") <|> char("A") <|>
    char("e") <|> char("E") <|>
    char("f") <|> char("F") <|>
    char("g") <|> char("G")
  static let intTypePerser = char("d") <|> char("i")
  static let uIntTypePerser = char("o") <|> char("O") <|> char("u") <|> char("x") <|> char("X")
  static let characterTypePerser = char("c") <|> char("C")
  static let cStringPointerTypePerser = char("s") <|> char("S")
  static let voidPointerTypePerser = char("p")

  // exchange to Optional<FormatSpecifier>
  static let percentType: ParsedType = formatPartSpec(nil) <^> percent
  static let objectType: ParsedType = formatPartSpec(.object) <^> objectTypePerser
  static let doubleType: ParsedType = formatPartSpec(.double) <^> doubleTypePerser
  static let intType: ParsedType = formatPartSpec(.int) <^> intTypePerser
  static let uIntType: ParsedType = formatPartSpec(.uInt) <^> uIntTypePerser
  static let characterType: ParsedType = formatPartSpec(.character) <^> characterTypePerser
  static let cStringPointerType: ParsedType = formatPartSpec(.cStringPointer) <^> cStringPointerTypePerser
  static let voidPointerType: ParsedType = formatPartSpec(.voidPointer) <^> voidPointerTypePerser

  static let type = percentType <|>
    objectType <|>
    doubleType <|>
    intType <|>
    uIntType <|>
    characterType <|>
    cStringPointerType <|>
    voidPointerType

  static let placeHolder = percent *>
    count(0...1, parameter) *>
    count(0...1, flags) *>
    count(0...1, width) *>
    count(0...1, precision) *>
    count(0...1, length) *>
    type

  // none placeholder text
  static let text: ParsedType = formatPartSpec(nil) <^> oneOrMore(not("%"))

  // stringsdict variable
  // %#@named@
  static let keyName = oneOrMore(oneOf("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"))
  static let referencePlaceHolder: ParsedType = FormatPart.reference <^> ( string("%#@") *> keyName <* char("@") )

  // parse full strings
  static let printfFormatted = zeroOrMore(text <|> referencePlaceHolder <|> placeHolder)

  // exclude Optional<FormatSpecifier>.none
  static let formatParts = filtered <^> printfFormatted
}
