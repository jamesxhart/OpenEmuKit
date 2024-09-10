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
@testable import OpenEmuKit

@Suite(.serialized)
class ShaderPresetModelTests {
    
    struct ShadersModel: OpenEmuKit.ShadersModel {
        let shaders: [String: OEShaderModel]
        
        init(models: OEShaderModel...) {
            shaders = Dictionary(uniqueKeysWithValues: models.map { ($0.name, $0) })
        }
        
        subscript(name: String) -> OEShaderModel? {
            shaders[name]
        }
    }
    
    private let defaults: UserDefaults
    private let store: ShaderPresetStorage
    private let presets: ShaderPresetStore
    
    private let path: String
    
    init() {
        path = FileManager.default
            .temporaryDirectory
            .appendingPathComponent("OpenEmuKitTests", isDirectory: true)
            .appendingPathComponent(UUID().uuidString).absoluteString
        
        defaults = UserDefaults(suiteName: path)!
        defaults.removePersistentDomain(forName: path)
        
        store = UserDefaultsPresetStorage(store: defaults)
        // swiftlint:disable force_try
        try! store.save(ShaderPresetData(name: "shader 1", shader: "CRT", parameters: [:], id: "id1"))
        try! store.save(ShaderPresetData(name: "shader 2", shader: "MAME", parameters: [:], id: "id2"))
        try! store.save(ShaderPresetData(name: "shader 3", shader: "MAME", parameters: [:], id: "id3"))
        try! store.save(ShaderPresetData(name: "shader 4", shader: "Retro", parameters: [:], id: "id4"))
        
        let shaders = ShadersModel(models:
            OEShaderModel(name: "CRT"),
            OEShaderModel(name: "MAME"),
            OEShaderModel(name: "NTSC"),
            OEShaderModel(name: "Retro")
        )
        presets = ShaderPresetStore(store: store, shaders: shaders)
    }
    
    deinit {
        try? FileManager.default.removeItem(atPath: path)
    }
    
    @Test
    func canFindPreset() {
        #expect(presets.findPreset(byID: "id1") != nil)
    }
    
    @Test
    func instancesAreSame() {
        #expect(presets.findPreset(byID: "id2") === presets.findPreset(byID: "id2"))
    }
    
    @Test
    func findPresets() {
        #expect(presets.findPresets(byShader: "MAME").count == 2, "Expected two presets for MAME shader")
        #expect(presets.findPresets(byShader: "foo").isEmpty, "Expected no presets for foo shader")
    }
    
    @Test
    func exists() {
        #expect(presets.exists(byID: "id2") == true)
        #expect(presets.exists(byID: "foo") == false)
    }
    
    @Test
    func removePreset() throws {
        let a = try #require(presets.findPreset(byID: "id2"))
        presets.removePreset(a)
        #expect(presets.findPreset(byID: "id2") == nil)
        #expect(presets.findPresets(byShader: "MAME").count == 1, "Expected one preset for MAME shader")
    }
    
    @Test
    func renamePreset() throws {
        let a = try #require(presets.findPreset(byID: "id2"), "Expected to find id2")
        a.name = "dummy name"
        try presets.savePreset(a)
        let b = try #require(presets.findPreset(byID: "id2"), "Expected to find id2")
        #expect(b.name == "dummy name")
    }
}
