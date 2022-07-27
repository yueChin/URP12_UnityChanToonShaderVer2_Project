//UCTS_Tess.cginc
//Unitychan Toon Shader ver.2.0
//v.2.0.9
//nobuyuki@unity3d.com
//https://github.com/unity3d-jp/UnityChanToonShaderVer2_Project
//(C)Unity Technologies Japan/UCL
// UNITY_SHADER_NO_UPGRADE
#ifndef UCTS_TESS
#define UCTS_TESS


//#include "HLSLSupport.cginc" // UNITY_CAN_COMPILE_TESSELLATION
 //#include "Lighting.cginc" // UnityTessellationFactors
//#include "Tessellation.cginc"

#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/UnityInstancing.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Macros.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/BRDF.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/GlobalIllumination.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RealtimeLights.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderVariablesFunctions.hlsl"
#include "Assets/UnityChanToonShaderVer2/Toon/Shader/Tess/URPTessellationInput.hlsl"

float _TessPhongStrength;
float _TessEdgeLength;
float _TessExtrusionAmount;

struct VertexInput
{
	float4 vertex : POSITION;
	float4 tangent : TANGENT;
	float3 normal : NORMAL;
	float4 texcoord0 : TEXCOORD0;
	float4 texcoord1 : TEXCOORD1;
	// v.2.0.9
	UNITY_VERTEX_INPUT_INSTANCE_ID 
};

#ifdef TESSELLATION_ON
#ifdef UNITY_CAN_COMPILE_TESSELLATION
struct InternalTessInterp_VertexInput
{
	float4 vertex : INTERNALTESSPOS;
	float4 tangent : TANGENT;
	float3 normal : NORMAL;
	float4 texcoord0 : TEXCOORD0;
	float4 texcoord1 : TEXCOORD1;
	// v.2.0.9
	UNITY_VERTEX_INPUT_INSTANCE_ID
};

InternalTessInterp_VertexInput tess_VertexInput(VertexInput v)
{
	InternalTessInterp_VertexInput o;
	o.vertex = v.vertex;
	o.tangent = v.tangent;
	o.normal = v.normal;
	o.texcoord0 = v.texcoord0;
	o.texcoord1 = v.texcoord1;
	UNITY_TRANSFER_INSTANCE_ID(v,o);
	return o;
}

// tessellation hull constant shader
UnityTessellationFactors hsconst_VertexInput(InputPatch<InternalTessInterp_VertexInput, 3> v)
{
	float4 tf = UnityEdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, _TessEdgeLength);
	UnityTessellationFactors o;
	o.edge[0] = tf.x;
	o.edge[1] = tf.y;
	o.edge[2] = tf.z;
	o.inside = tf.w;
	return o;
}


//定义细分的图元，可以为tri、 quad 或 isoline
[UNITY_domain("tri")]
//定义hull shader中使用的细分方案fractional_even和fractional_odd：分为n-2的等长部分和不等长部分，前者是向上取偶数，后者是向上去奇数
//pow2：没有找到相关的资料微软的文档给的太少了，integer：把一条边n等分
[UNITY_partitioning("fractional_odd")]
//定义细分器所输出的图元类型point（点）、line（线）、triangle_cw（顺时针环绕三角形）、triangle_ccw（逆时针环绕三角形）
[UNITY_outputtopology("triangle_cw")]
//定义计算patch constant data的函数
[UNITY_patchconstantfunc("hsconst_VertexInput")]
//定义hull shader创建的输出控制点数量
[UNITY_outputcontrolpoints(3)]
InternalTessInterp_VertexInput hs_VertexInput(InputPatch<InternalTessInterp_VertexInput, 3> v, uint id : SV_OutputControlPointID)
{
	return v[id];
}

inline VertexInput _ds_VertexInput(UnityTessellationFactors tessFactors, const OutputPatch<InternalTessInterp_VertexInput, 3> vi, float3 bary : SV_DomainLocation)
{
	VertexInput v;

	v.vertex = vi[0].vertex*bary.x + vi[1].vertex*bary.y + vi[2].vertex*bary.z;
	float3 pp[3];
	for (int i = 0; i < 3; ++i)
		pp[i] = v.vertex.xyz - vi[i].normal * (dot(v.vertex.xyz, vi[i].normal) - dot(vi[i].vertex.xyz, vi[i].normal));
	v.vertex.xyz = _TessPhongStrength * (pp[0] * bary.x + pp[1] * bary.y + pp[2] * bary.z) + (1.0f - _TessPhongStrength) * v.vertex.xyz;
	v.tangent = vi[0].tangent*bary.x + vi[1].tangent*bary.y + vi[2].tangent*bary.z;
	v.normal = vi[0].normal*bary.x + vi[1].normal*bary.y + vi[2].normal*bary.z;
	v.vertex.xyz += v.normal.xyz * _TessExtrusionAmount;
	v.texcoord0 = vi[0].texcoord0*bary.x + vi[1].texcoord0*bary.y + vi[2].texcoord0*bary.z;
	v.texcoord1 = vi[0].texcoord1*bary.x + vi[1].texcoord1*bary.y + vi[2].texcoord1*bary.z;
	UNITY_TRANSFER_INSTANCE_ID(vi[0], v);
	return v;
}

#endif // UNITY_CAN_COMPILE_TESSELLATION
#endif // TESSELLATION_ON

#endif // UCTS_TESS
