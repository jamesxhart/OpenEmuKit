// Copyright (c) 2021, OpenEmu Team
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//     * Redistributions of source code must retain the above copyright
//       notice, this list of conditions and the following disclaimer.
//     * Redistributions in binary form must reproduce the above copyright
//       notice, this list of conditions and the following disclaimer in the
//       documentation and/or other materials provided with the distribution.
//     * Neither the name of the OpenEmu Team nor the
//       names of its contributors may be used to endorse or promote products
//       derived from this software without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY OpenEmu Team ''AS IS'' AND ANY
// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
// WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
// DISCLAIMED. IN NO EVENT SHALL OpenEmu Team BE LIABLE FOR ANY
// DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
// LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
// ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
// SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

import Testing
import XCTest
@testable import OpenEmuKit

// swiftlint:disable:next type_name
private typealias w = ShaderPresetTextWriter

struct ShaderPresetTextWriterTests {
    
    @Test
    func writeDefaultOptions() throws {
        let got = try w.write(preset: .init(name: "foo", shader: "CRT", parameters: ["a": 5, "b": 6]))
        #expect(got == #"$shader="CRT";a=5;b=6"#)
    }
    
    @Test
    func writeAllOptions() throws {
        let got = try w.write(preset: .init(name: "foo", shader: "CRT", parameters: ["a": 5, "b": 6.3]), options: [.all])
        #expect(got == #"$name="foo";$shader="CRT";a=5;b=6.3"#)
    }
    
    @Test
    func writeParametersNoOptions() throws {
        let got = try w.write(preset: .init(name: "foo", shader: "CRT", parameters: ["a": 5, "b": 6]), options: [])
        #expect(got == #"a=5;b=6"#)
    }
    
    @Test
    func writeNoParametersDefaultOptions() throws {
        let got = try w.write(preset: .init(name: "foo", shader: "CRT", parameters: [:]))
        #expect(got == #"$shader="CRT""#)
    }
    
    @Test
    func writeNoParametersAndOptions() throws {
        let got = try w.write(preset: .init(name: "foo", shader: "CRT", parameters: [:]), options: [])
        #expect(got.isEmpty)
    }
    
    // MARK: - invalid characters in identifiers
    
    let invalidCharacters = ShaderPresetTextWriter.invalidCharacters
    
    @Test
    func idDoesNotAllowInvalidCharacters() {
        for ch in invalidCharacters {
            #expect(throws: ShaderPresetWriteError.invalidCharacters) {
                try w.write(preset: .init(name: "foo\(ch)foo", shader: "CRT", parameters: ["a": 5, "b": 6]), options: [.name])
            }
        }
    }
    
    @Test
    func shaderDoesNotAllowInvalidCharacters() {
        for ch in invalidCharacters {
            #expect(throws: ShaderPresetWriteError.invalidCharacters) {
                try w.write(preset: .init(name: "foo", shader: "CRT\(ch) Geom", parameters: ["a": 5, "b": 6]), options: [.shader])
            }
        }
    }
    
    @Test
    func isNotAValidIdentifier() {
        for ch in invalidCharacters {
            #expect(ShaderPresetTextWriter.isValidIdentifier("tt\(ch)tt") == false)
        }
    }
}

class ShaderPresetTextWriterPerformanceTests: XCTestCase {
    
    func testWritePerformance() {
        let preset = ShaderPresetData(name: "foo", shader: "CRT", parameters: ["a": 5, "b": 6.3])
        measure {
            _ = try? w.write(preset: preset, options: [.all])
        }
    }
}
