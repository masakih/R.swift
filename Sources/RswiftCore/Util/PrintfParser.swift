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

  static let parameter = oneOrMore(digit) <* string("$")
  static let flags = string("-") <|> string("+") <|> string(" ") <|> string("0") <|> string("'") <|> string("#")
  static let width = oneOrMore(digit)
  static let precision = string(".") *> zeroOrMore(digit)
  static let length = string("hh") <|> string("h") <|>
    string("ll") <|> string("l") <|> string("L") <|>
    string("q") <|>
    string("z") <|>
    string("j") <|>
    string("t")

  static let objectTypeParser = char("@")
  static let doubleTypeParser = char("a") <|> char("A") <|>
    char("e") <|> char("E") <|>
    char("f") <|> char("F") <|>
    char("g") <|> char("G")
  static let intTypeParser = char("d") <|> char("i")
  static let uIntTypeParser = char("o") <|> char("O") <|> char("u") <|> char("x") <|> char("X")
  static let characterTypeParser = char("c") <|> char("C")
  static let cStringPointerTypeParser = char("s") <|> char("S")
  static let voidPointerTypeParser = char("p")
  static let noneTypeParser = char("n")

  // exchange to Optional<FormatSpecifier>
  static let percentType: ParsedType = formatPartSpec(nil) <^> percent
  static let objectType: ParsedType = formatPartSpec(.object) <^> objectTypeParser
  static let doubleType: ParsedType = formatPartSpec(.double) <^> doubleTypeParser
  static let intType: ParsedType = formatPartSpec(.int) <^> intTypeParser
  static let uIntType: ParsedType = formatPartSpec(.uInt) <^> uIntTypeParser
  static let characterType: ParsedType = formatPartSpec(.character) <^> characterTypeParser
  static let cStringPointerType: ParsedType = formatPartSpec(.cStringPointer) <^> cStringPointerTypeParser
  static let voidPointerType: ParsedType = formatPartSpec(.voidPointer) <^> voidPointerTypeParser
  static let noneType: ParsedType = formatPartSpec(nil) <^> noneTypeParser

  static let type = percentType <|>
    objectType <|>
    doubleType <|>
    intType <|>
    uIntType <|>
    characterType <|>
    cStringPointerType <|>
    voidPointerType <|>
    noneType

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
