//
//  Renderer.swift
//  macOSMetal
//
//  Created by Zach Eriksen on 4/30/18.
//  Copyright © 2018 Zach Eriksen. All rights reserved.
//

import MetalKit

struct Vertex {
    var position: float3
    var color: float4
}

extension MTLDevice {
    func makeBuffer<T>(data: [T]) -> MTLBuffer? {
        self.makeBuffer(
            bytes: data,
            length: MemoryLayout<T>.stride * data.count,
            options: []
        )
    }
}

let vertices: [Vertex] = [
    Vertex(position: float3( 0,  1, 0), color: float4(1, 0, 0, 1)),
    Vertex(position: float3(-1, -1, 0), color: float4(0, 1, 0, 1)),
    Vertex(position: float3( 1, -1, 0), color: float4(0, 0, 1, 1))
]

final class Renderer: NSObject {
    let commandQueue: MTLCommandQueue
    let renderPipelineState: MTLRenderPipelineState

    let vertexBuffer: MTLBuffer

    init(device: MTLDevice) {
        guard let commandQueue = device.makeCommandQueue() else { fatalError() }
        guard let library = device.makeDefaultLibrary() else { fatalError() }

        self.commandQueue = commandQueue

        // Our vertex function name
        let vertexFunction = library.makeFunction(name: "basic_vertex_function")
        // Our fragment function name
        let fragmentFunction = library.makeFunction(name: "basic_fragment_function")
        // Create basic descriptor
        let rpd = MTLRenderPipelineDescriptor()
        // Attach the pixel format that si the same as the MetalView
        rpd.colorAttachments[0].pixelFormat = .bgra8Unorm
        // Attach the shader functions
        rpd.vertexFunction = vertexFunction
        rpd.fragmentFunction = fragmentFunction
        // Try to update the state of the renderPipeline
        do {
            self.renderPipelineState = try device.makeRenderPipelineState(descriptor: rpd)
        } catch {
            fatalError(error.localizedDescription)
        }

        guard let buffer = device.makeBuffer(data: vertices) else { fatalError() }

        self.vertexBuffer = buffer

        super.init()
    }
}

extension Renderer: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {

    }

    func draw(in view: MTKView) {
        // Get the current drawable and descriptor
        guard let drawable = view.currentDrawable,
              let renderPassDescriptor = view.currentRenderPassDescriptor,
              let commandBuffer = self.commandQueue.makeCommandBuffer(),
              let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else {
            return
        }
        // Create a buffer from the commandQueue


        encoder.setRenderPipelineState(self.renderPipelineState)
        // Pass in the vertexBuffer into index 0
        encoder.setVertexBuffer(self.vertexBuffer, offset: 0, index: 0)
        // Draw primitive at vertextStart 0
        encoder.drawPrimitives(
            type: .triangle,
            vertexStart: 0,
            vertexCount: vertices.count
        )

        encoder.endEncoding()
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}
