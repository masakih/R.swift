//
//  PrintfParser.swift
//  printfFormatParserForR
//
//  Created by Hori,Masaki on 2021/07/11.
//

import FootlessParser

enum LocalizedStringParser {
  
  static let percent = char("%")
  
  static let formatParam = oneOrMore(digit) *> string("$")
  static let formatFlag = string("-") <|> string("+") <|> string(" ") <|> string("0") <|> string("'") <|> string("#")
  static let formatWidth = oneOrMore(digit)
  static let formatPrecision = string(".") *> zeroOrMore(digit)
  static let fotmatLength = string("hh") <|> string("h") <|>
    string("l") <|> string("ll") <|> string("L") <|>
    string("q") <|>
    string("z") <|>
    string("j") <|>
    string("t")
  
  static let formatOptions = formatParam <|>
    formatFlag <|>
    formatWidth <|>
    formatPrecision <|>
    fotmatLength
  
  static let formatObjectP = char("@")
  static let formatDoubleP = char("a") <|> char("A") <|>
    char("e") <|> char("E") <|>
    char("f") <|> char("F") <|>
    char("g") <|> char("G")
  static let formatIntP = char("d") <|> char("i")
  static let formatUIntP = char("o") <|> char("O") <|> char("u") <|> char("x") <|> char("X")
  static let formatCharacterP = char("c") <|> char("C")
  static let formatStringPointerP = char("s") <|> char("S")
  static let formatVoidPointerP = char("p")
  
  static func formatPartSpec<A>(_ output: FormatSpecifier?) -> (A) -> FormatPart? {
    { _ in output.map { .spec($0) } }
  }
  
  typealias ParsedType = Parser<Character, Optional<FormatPart>>
  static let percentT: ParsedType = formatPartSpec(nil) <^> percent
  static let formatObject: ParsedType = formatPartSpec(.object) <^> formatObjectP
  static let formatDouble: ParsedType = formatPartSpec(.double) <^> formatDoubleP
  static let formatInt: ParsedType = formatPartSpec(.int) <^> formatIntP
  static let formatUInt: ParsedType = formatPartSpec(.uInt) <^> formatUIntP
  static let formatCharacter: ParsedType = formatPartSpec(.character) <^> formatCharacterP
  static let formatStringPointer: ParsedType = formatPartSpec(.cStringPointer) <^> formatStringPointerP
  static let formatVoidPointer: ParsedType = formatPartSpec(.voidPointer) <^> formatVoidPointerP
  
  static let formatType = percentT <|>
    formatObject <|>
    formatDouble <|>
    formatInt <|>
    formatUInt <|>
    formatCharacter <|>
    formatStringPointer <|>
    formatVoidPointer
  
  static let placeHolder = percent *>
    zeroOrMore(formatParam) *>
    zeroOrMore(formatFlag) *>
    zeroOrMore(formatWidth) *>
    zeroOrMore(formatPrecision) *>
    zeroOrMore(fotmatLength) *>
    zeroOrMore(formatOptions) *>
    formatType
  
  static let text: ParsedType = formatPartSpec(nil) <^> oneOrMore(not("%"))
  
  static let keyName = oneOrMore(oneOf("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"))
  static let referencePlaceHolder: ParsedType = FormatPart.reference <^> ( string("%#@") *> keyName <* char("@") )
  
  static let printfFormatted = zeroOrMore(text <|> referencePlaceHolder <|> placeHolder)
  
  static func filtered(parts: [FormatPart?]) -> [FormatPart] {
    parts.compactMap { $0 }
  }
  
  
  static let formatParts = filtered <^> printfFormatted
}
