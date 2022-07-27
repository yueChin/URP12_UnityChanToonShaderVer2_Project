#ifndef URP_TESSELLATIONINPUT_INCLUDED
#define URP_TESSELLATIONINPUT_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

#if defined(SHADER_API_D3D11) || defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE) || defined(SHADER_API_VULKAN) || defined(SHADER_API_METAL) || defined(SHADER_API_PSSL)
#define UNITY_CAN_COMPILE_TESSELLATION 1
#   define UNITY_domain                 domain
#   define UNITY_partitioning           partitioning
#   define UNITY_outputtopology         outputtopology
#   define UNITY_patchconstantfunc      patchconstantfunc
#   define UNITY_outputcontrolpoints    outputcontrolpoints
#endif

struct UnityTessellationFactors {
    float edge[3] : SV_TessFactor;
    float inside : SV_InsideTessFactor;
};

float UnityCalcEdgeTessFactor (float3 wpos0, float3 wpos1, float edgeLen)
{
    // distance to edge center
    float dist = distance (0.5 * (wpos0+wpos1), _WorldSpaceCameraPos);
    // length of the edge
    float len = distance(wpos0, wpos1);
    // edgeLen is approximate desired size in pixels
    float f = max(len * _ScreenParams.y / (edgeLen * dist), 1.0);
    return f;
}

// Desired edge length based tessellation:
// Approximate resulting edge length in pixels is "edgeLength".
// Does not take viewing FOV into account, just flat out divides factor by distance.
float4 UnityEdgeLengthBasedTess (float4 v0, float4 v1, float4 v2, float edgeLength)
{
    float3 pos0 = mul(unity_ObjectToWorld,v0).xyz;
    float3 pos1 = mul(unity_ObjectToWorld,v1).xyz;
    float3 pos2 = mul(unity_ObjectToWorld,v2).xyz;
    float4 tess;
    tess.x = UnityCalcEdgeTessFactor (pos1, pos2, edgeLength);
    tess.y = UnityCalcEdgeTessFactor (pos2, pos0, edgeLength);
    tess.z = UnityCalcEdgeTessFactor (pos0, pos1, edgeLength);
    tess.w = (tess.x + tess.y + tess.z) / 3.0f;
    return tess;
}


#endif