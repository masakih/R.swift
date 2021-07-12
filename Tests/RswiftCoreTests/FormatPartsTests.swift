//
//  FormatPartsTests.swift
//  
//
//  Created by Hori,Masaki on 2021/07/12.
//

import XCTest
@testable import RswiftCore

extension FormatPart: Equatable {
  
  public static func == (lhs: FormatPart, rhs: FormatPart) -> Bool {
    switch (lhs, rhs) {
    case let (.spec(l), .spec(r)): return l == r
    case let (.reference(l), .reference(r)): return l == r
    default: return false
    }
  }
}


class FormatPartsTests: XCTestCase {
  
  func testNormal() throws {
    
    let none = FormatPart.formatParts(formatString: "abcdefghijklmnopqrstuvwxyz0123456789~`!@#$^&*()-_+=[{]}|;:'\",<.>/?")
    XCTAssertEqual(none, [])
    
    let per = FormatPart.formatParts(formatString: "%%%%")
    XCTAssertEqual(per, [])
    
    let o = FormatPart.formatParts(formatString: "%@")
    XCTAssertEqual(o, [.spec(.object)])
    
    let d = FormatPart.formatParts(formatString: "%a%A%e%E%f%F%g%G")
    XCTAssertEqual(d, [.spec(.double), .spec(.double), .spec(.double), .spec(.double), .spec(.double), .spec(.double), .spec(.double), .spec(.double)])
    
    let i = FormatPart.formatParts(formatString: "%i%d")
    XCTAssertEqual(i, [.spec(.int), .spec(.int)])
    
    let ui = FormatPart.formatParts(formatString: "%o%O%u%x%X")
    XCTAssertEqual(ui, [.spec(.uInt), .spec(.uInt), .spec(.uInt), .spec(.uInt), .spec(.uInt)])
    
    let c = FormatPart.formatParts(formatString: "%c%C")
    XCTAssertEqual(c, [.spec(.character), .spec(.character)])
    
    let s = FormatPart.formatParts(formatString: "%s%S")
    XCTAssertEqual(s, [.spec(.cStringPointer), .spec(.cStringPointer)])
    
    let p = FormatPart.formatParts(formatString: "%p")
    XCTAssertEqual(p, [.spec(.voidPointer)])
    
    
    let n = FormatPart.formatParts(formatString: "%n")
    XCTAssertEqual(n, [])
    
    let ppp = FormatPart.formatParts(formatString: "%")
    XCTAssertEqual(ppp, [])
  }
  
  func testPrameterized() throws {
    
    let p0 = FormatPart.formatParts(formatString: "%5$-98.465hE")
    XCTAssertEqual(p0, [.spec(.double)])
    
    let p1 = FormatPart.formatParts(formatString: "%50$+98hhg")
    XCTAssertEqual(p1, [.spec(.double)])
    
    let p2 = FormatPart.formatParts(formatString: "%5$ .4lf")
    XCTAssertEqual(p2, [.spec(.double)])
    
    let p3 = FormatPart.formatParts(formatString: "%5$0llA")
    XCTAssertEqual(p3, [.spec(.double)])
    
    let p4 = FormatPart.formatParts(formatString: "%5$'.qa")
    XCTAssertEqual(p4, [.spec(.double)])
    
    let p5 = FormatPart.formatParts(formatString: "%5$#98.465qf")
    XCTAssertEqual(p5, [.spec(.double)])
  }
  
  func testRefarence() throws {
    
    let p0 = FormatPart.formatParts(formatString: "%#@named@")
    XCTAssertEqual(p0, [.reference("named")])
    
    let p1 = FormatPart.formatParts(formatString: "I give %d apples to %@ %#@named@")
    XCTAssertEqual(p1, [.spec(.int), .spec(.object), .reference("named")])
  }
}
