//
//  Day2.swift
//  LearnMetalKit
//  Created by JoyTim on 2024/5/22
//  Copyright © 2024 ___ORGANIZATIONNAME___. All rights reserved.
//

import MetalKit
import simd
import UIKit
class Day2: BaseViewController {
    var piplineState: MTLRenderPipelineState!
    var viewPortSize: vector_uint2?
    override func viewDidLoad() {
        super.viewDidLoad()

//        metalView = MTKView(frame: CGRect(x: 0, y: 100, width: 200, height: 100), device: device)

        view.backgroundColor = .green
        // Do any additional setup after loading the view.
        let dl = device.makeDefaultLibrary()
        let vertexShader = dl?.makeFunction(name: "vertexShader")
        let fragmentShader = dl?.makeFunction(name: "fragmentShader")
        let rpd = MTLRenderPipelineDescriptor()
        rpd.label = "my pip"
        rpd.vertexFunction = vertexShader
        rpd.fragmentFunction = fragmentShader
        rpd.colorAttachments[0].pixelFormat = metalView.colorPixelFormat

        do {
            piplineState = try device.makeRenderPipelineState(descriptor: rpd)

        } catch {
            print(error.localizedDescription)
        }
        /*
         在 Metal 和 MetalKit 中，drawableSize 和 frame 大小是两个不同的概念，它们之间有一定的关系，但不是直接等同的。以下是它们的详细解释：

         frame 大小
         frame 大小指的是视图在其父视图坐标系统中的位置和尺寸。它通常表示的是视图在屏幕上的可见区域。这是 UIKit 和 AppKit 中常见的属性，用于布局视图。

         drawableSize
         drawableSize 是 MetalKit 中 MTKView 的一个属性，表示实际用于渲染的纹理的尺寸。这个尺寸通常与视图的分辨率有关，可以比视图的 frame 大小具有更高的分辨率，特别是在处理视网膜显示器时。
         */
        viewPortSize = vector_uint2(UInt32(metalView.drawableSize.width), UInt32(metalView.drawableSize.height))
    }

    override func draw(in view: MTKView) {
        view.clearColor = MTLClearColorMake(0, 0, 0, 1)
        // 393.
        let triangleVertices: [AAPLVertex] = [
            // 2D positions,    RGBA colors
            AAPLVertex(position: vector_float2(0.0, 1.0), color: vector_float4(1, 0, 0, 1)),
            AAPLVertex(position: vector_float2(-1.0, -1.0), color: vector_float4(0, 1, 0, 1)),
            AAPLVertex(position: vector_float2(1.0, -1.0), color: vector_float4(0, 0, 1, 1))
        ]

        let dataSize = triangleVertices.count * MemoryLayout<AAPLVertex>.stride

        guard let commandBuffer = commandQueue?.makeCommandBuffer() else {
            debugPrint("Make CommandBuffe failed!")
            return
        }

        commandBuffer.label = "MyCommand"
        guard let renderPassDescriptor = view.currentRenderPassDescriptor else {
            debugPrint("Get current render pass descriptor failed!")
            return
        }

        // 通过渲染描述符renderPassDescriptor创建MTLRenderCommandEncoder 对象
        guard let renderCommandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else {
            debugPrint("Make render command encoder failed!")
            return
        }
        renderCommandEncoder.label = "MyRenderCommandEncoder"
        renderCommandEncoder.setViewport(MTLViewport(originX: 0, originY: 0, width: Double(viewPortSize!.x), height: Double(viewPortSize!.y), znear: 0.0, zfar: 1.0))
        renderCommandEncoder.setRenderPipelineState(piplineState)

        renderCommandEncoder.setVertexBytes(triangleVertices, length: dataSize, index: Int(AAPLVertexInputIndexVertices.rawValue))

        // 将viewportSize传递给渲染命令编码器
        renderCommandEncoder.setVertexBytes(&viewPortSize,
                                            length: MemoryLayout.size(ofValue: viewPortSize),
                                            index: Int(AAPLVertexInputIndexViewportSize.rawValue))

        renderCommandEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3)
        renderCommandEncoder.endEncoding()

        guard let drawable = view.currentDrawable else {
            debugPrint("Get current drawable failed!")
            return
        }
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }

    /*
     // MARK: - Navigation

     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         // Get the new view controller using segue.destination.
         // Pass the selected object to the new view controller.
     }
     */
}
