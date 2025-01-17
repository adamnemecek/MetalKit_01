//
//  MetalView.swift
//  macOSMetal
//
//  Created by Zach Eriksen on 4/30/18.
//  Copyright © 2018 Zach Eriksen. All rights reserved.
//

import MetalKit

class MetalView: MTKView {
    let renderer: Renderer
    
    required init(coder: NSCoder) {
        guard let defaultDevice = MTLCreateSystemDefaultDevice() else {
            fatalError("Device loading error")
        }
        self.renderer = Renderer(device: defaultDevice)

        super.init(coder: coder)
        // Make sure we are on a device that can run metal!

        self.device = defaultDevice
        self.colorPixelFormat = .bgra8Unorm
        // Our clear color, can be set to any color
        self.clearColor = MTLClearColor(red: 0.1, green: 0.57, blue: 0.25, alpha: 1)

        self.delegate = renderer
    }
}
