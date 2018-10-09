//
//  ViewController.swift
//  Try_Swift
//
//  Created by 好多余先生 on 2018/8/7.
//  Copyright © 2018年 好多余先生. All rights reserved.
//

import UIKit
import Metal
import QuartzCore


class ViewController: UIViewController {

    var device: MTLDevice!
    var metalLayer: CAMetalLayer!
    var vertexBuffer: MTLBuffer!
    var pipelineState: MTLRenderPipelineState!
    var queue: MTLCommandQueue!
    var timer: CADisplayLink!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
    
        device = MTLCreateSystemDefaultDevice()
        metalLayer = CAMetalLayer()
        metalLayer.device = device
        metalLayer.pixelFormat = .bgra8Unorm //像素格式
        metalLayer.framebufferOnly = true   //帧缓冲 大多数情况下无需开启，除非需要对layer做纹理（textures）处理
        metalLayer.frame = view.layer.frame
        view.layer.addSublayer(metalLayer)
        
        
        //创建buffer区，Metal里每一个图形都是由三维坐标组成
        let vertexData:[Float] = [0.0,1.0,0.0,-1.0,-1.0,0.0,1.0,-1.0,0.0]
        
        let dataSize = vertexData.count * MemoryLayout.size(ofValue: vertexData[0]) //获取字节大小
        vertexBuffer = device.makeBuffer(bytes: vertexData, length: dataSize, options: .cpuCacheModeWriteCombined)
        
        
        let defaultLibrary = device.makeDefaultLibrary()
        let fragmentProgram = defaultLibrary?.makeFunction(name:"basic_fragment")
        let vertexProgram = defaultLibrary?.makeFunction(name: "basic_vertex")
        
        //管道状态解释器
        let pipelineStateDescripitor = MTLRenderPipelineDescriptor()
        pipelineStateDescripitor.vertexFunction = vertexProgram
        pipelineStateDescripitor.fragmentFunction = fragmentProgram
        pipelineStateDescripitor.colorAttachments[0].pixelFormat = .bgra8Unorm
        
        do {
           try pipelineState = device.makeRenderPipelineState(descriptor: pipelineStateDescripitor)
        }catch let error {
            print(error)
        }
        
        //队列
        queue = device.makeCommandQueue()
        
        //刷新屏幕（静态的的话无需）
        timer = CADisplayLink(target: self, selector: #selector(gameloop))
        timer.add(to: .main, forMode: .defaultRunLoopMode)
    }
    
    
    @objc func gameloop() {
        
        let draw = metalLayer.nextDrawable()
        
        let renderPassDes = MTLRenderPassDescriptor()
        renderPassDes.colorAttachments[0].texture = draw?.texture
        renderPassDes.colorAttachments[0].loadAction = .clear   //绘制之前把纹理清空
        renderPassDes.colorAttachments[0].clearColor = MTLClearColor(red: 0.0, green: 104.0/255.0, blue: 5.0/255.0, alpha: 1.0) //背景颜色
        
        let buffer = queue.makeCommandBuffer()
        let renderEncoder = buffer?.makeRenderCommandEncoder(descriptor: renderPassDes)
        renderEncoder?.setRenderPipelineState(pipelineState)
        renderEncoder?.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        renderEncoder?.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3)
        renderEncoder?.endEncoding()
        
        buffer?.present(draw!) //保证新纹理绘制完成后立即出现
        buffer?.commit()
    }
    
}




