//
//  CustomShader.metal
//  Try_Swift
//
//  Created by 好多余先生 on 2018/10/9.
//  Copyright © 2018 好多余先生. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;
/*
 所有的vertex shader 必须以 vertex 开头 ，函数必须返回顶点的最终位置
 第一个参数指向一个元素为packed_float3（一个向量包含3个浮点数）的数组的指针。[[...]]语法声明被用作y特定额外信息的属性，例如资源位置，shader输入，内建变量。[[buffer(0)]]指这个参数将被 会被发送到vertex shader 的第一块buffer data 所遍历。
 第二个参数指 vertex shader 会接受一个vertex_id 的属性的特定参数
 */
vertex float4 basic_vertex(
    const device packed_float3 * vertex_array[[buffer(0)]],
    unsigned int vid [[vertex_id]]){
    return float4(vertex_array[vid], 1.0);
}

/*
 所有fragment shaders必须以fragment关键字开始。这个函数必须至少返回fragment的最终颜色
 通过指定一个颜色的RGBA值来完成这个任务。
 half4比float4在内存上更有效率
 */
fragment half4 basic_fragment() {
    return half4(1.0,0.5,0.3,0.8);
}
