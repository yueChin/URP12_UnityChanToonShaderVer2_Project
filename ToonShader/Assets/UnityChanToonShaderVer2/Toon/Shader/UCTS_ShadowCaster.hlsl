//UCTS_ShadowCaster.cginc
//Unitychan Toon Shader ver.2.0
//v.2.0.9
//nobuyuki@unity3d.com
//https://github.com/unity3d-jp/UnityChanToonShaderVer2_Project
//(C)Unity Technologies Japan/UCL
//#pragma multi_compile _IS_CLIPPING_OFF _IS_CLIPPING_MODE  _IS_CLIPPING_TRANSMODE
//

#ifndef UCTS_SHADOWCASTER_URP
#define UCTS_SHADOWCASTER_URP

#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/UnityInstancing.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Macros.hlsl"

#ifdef _IS_CLIPPING_MODE
//_Clipping
uniform sampler2D _ClippingMask; uniform float4 _ClippingMask_ST;
uniform float _Clipping_Level;
uniform half _Inverse_Clipping;
#elif _IS_CLIPPING_TRANSMODE
//_TransClipping
uniform sampler2D _ClippingMask; uniform float4 _ClippingMask_ST;
uniform float _Clipping_Level;
uniform half _Inverse_Clipping;
uniform sampler2D _MainTex; uniform float4 _MainTex_ST;
uniform half _IsBaseMapAlphaAsClippingMask;
#elif _IS_CLIPPING_OFF
//Default
#endif


#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceInput.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Shaders/LitInput.hlsl"

// Shadow Casting Light geometric parameters. These variables are used when applying the shadow Normal Bias and are set by UnityEngine.Rendering.Universal.ShadowUtils.SetupShadowCasterConstantBuffer in com.unity.render-pipelines.universal/Runtime/ShadowUtils.cs
// For Directional lights, _LightDirection is used when applying shadow Normal Bias.
// For Spot lights and Point lights, _LightPosition is used to compute the actual light direction because it is different at each shadow caster geometry vertex.
float3 _LightDirection;
float3 _LightPosition;

struct Attributes
{
    float4 positionOS   : POSITION;
    float3 normalOS     : NORMAL;
#ifdef _IS_CLIPPING_MODE
    //_Clipping
    float2 texcoord : TEXCOORD0;
#elif _IS_CLIPPING_TRANSMODE
    //_TransClipping
    float2 texcoord : TEXCOORD0;
#elif _IS_CLIPPING_OFF
    //Default
    float2 texcoord     : TEXCOORD0;
#endif
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct Varyings
{
    //V2F_SHADOW_CASTER;
#ifdef _IS_CLIPPING_MODE
    //_Clipping
    float2 uv : TEXCOORD1;
#elif _IS_CLIPPING_TRANSMODE
    //_TransClipping
    float2 uv : TEXCOORD1;
#elif _IS_CLIPPING_OFF
    //Default
    float2 uv           : TEXCOORD0;
#endif
    float4 positionCS   : SV_POSITION;
};

float4 GetShadowPositionHClip(Attributes input)
{
    float3 positionWS = TransformObjectToWorld(input.positionOS.xyz);
    float3 normalWS = TransformObjectToWorldNormal(input.normalOS);

#if _CASTING_PUNCTUAL_LIGHT_SHADOW
    float3 lightDirectionWS = normalize(_LightPosition - positionWS);
#else
    float3 lightDirectionWS = _LightDirection;
#endif

    float4 positionCS = TransformWorldToHClip(ApplyShadowBias(positionWS, normalWS, lightDirectionWS));

#if UNITY_REVERSED_Z
    positionCS.z = min(positionCS.z, UNITY_NEAR_CLIP_VALUE);
#else
    positionCS.z = max(positionCS.z, UNITY_NEAR_CLIP_VALUE);
#endif

    return positionCS;
}

Varyings ShadowPassVertex(Attributes input)
{
    Varyings output;
    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_TRANSFER_INSTANCE_ID(input, output);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);
    #ifdef _IS_CLIPPING_MODE
    //_Clipping
    output.uv = input.texcoord;
    #elif _IS_CLIPPING_TRANSMODE
    //_TransClipping
    output.uv = input.texcoord;
    #elif _IS_CLIPPING_OFF
    //Default
    #endif
    output.uv = TRANSFORM_TEX(input.texcoord, _BaseMap);
    output.positionCS = GetShadowPositionHClip(input);
    return output;
}

half4 ShadowPassFragment(Varyings input) : SV_TARGET
{
    UNITY_SETUP_INSTANCE_ID(i);
    //                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
#ifdef _IS_CLIPPING_MODE
    //_Clipping
    float2 Set_UV0 = input.uv;
    float4 _ClippingMask_var = tex2D(_ClippingMask,TRANSFORM_TEX(Set_UV0, _ClippingMask));
    float Set_Clipping = saturate((lerp( _ClippingMask_var.r, (1.0 - _ClippingMask_var.r), _Inverse_Clipping )+_Clipping_Level));
    clip(Set_Clipping - 0.5);
#elif _IS_CLIPPING_TRANSMODE
    //_TransClipping
    float2 Set_UV0 = input.uv;
    float4 _ClippingMask_var = tex2D(_ClippingMask,TRANSFORM_TEX(Set_UV0, _ClippingMask));
    float4 _MainTex_var = tex2D(_MainTex,TRANSFORM_TEX(Set_UV0, _BaseMap));
    float Set_MainTexAlpha = _MainTex_var.a;
    float _IsBaseMapAlphaAsClippingMask_var = lerp( _ClippingMask_var.r, Set_MainTexAlpha, _IsBaseMapAlphaAsClippingMask );
    float _Inverse_Clipping_var = lerp( _IsBaseMapAlphaAsClippingMask_var, (1.0 - _IsBaseMapAlphaAsClippingMask_var), _Inverse_Clipping );
    float Set_Clipping = saturate((_Inverse_Clipping_var+_Clipping_Level));
    clip(Set_Clipping - 0.5);
#elif _IS_CLIPPING_OFF
    //Default
#endif
    Alpha(SampleAlbedoAlpha(input.uv, TEXTURE2D_ARGS(_BaseMap, sampler_BaseMap)).a, _BaseColor, _Cutoff);
    return 0;
}

struct VertexInput {
    float4 vertex : POSITION;
    #ifdef _IS_CLIPPING_MODE
    //_Clipping
    float2 texcoord0 : TEXCOORD0;
    #elif _IS_CLIPPING_TRANSMODE
    //_TransClipping
    float2 texcoord0 : TEXCOORD0;
    #elif _IS_CLIPPING_OFF
    //Default
    #endif
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct VertexOutput {
    //V2F_SHADOW_CASTER;
    #ifdef _IS_CLIPPING_MODE
    //_Clipping
    float2 uv0 : TEXCOORD1;
    #elif _IS_CLIPPING_TRANSMODE
    //_TransClipping
    float2 uv0 : TEXCOORD1;
    #elif _IS_CLIPPING_OFF
    //Default
    #endif
    UNITY_VERTEX_INPUT_INSTANCE_ID
    UNITY_VERTEX_OUTPUT_STEREO
};
VertexOutput vert (VertexInput v) {
    VertexOutput o = (VertexOutput)0;
    UNITY_SETUP_INSTANCE_ID(v);
    UNITY_TRANSFER_INSTANCE_ID(v, o);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
    #ifdef _IS_CLIPPING_MODE
    //_Clipping
    o.uv0 = v.texcoord0;
    #elif _IS_CLIPPING_TRANSMODE
    //_TransClipping
    o.uv0 = v.texcoord0;
    #elif _IS_CLIPPING_OFF
    //Default
    #endif
    //o.pos = UnityObjectToClipPos( v.vertex );
    //TRANSFER_SHADOW_CASTER(o)
    return o;
}
float4 frag(VertexOutput i) : SV_TARGET {
    UNITY_SETUP_INSTANCE_ID(i);
    //                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
    #ifdef _IS_CLIPPING_MODE
    //_Clipping
    float2 Set_UV0 = i.uv0;
    float4 _ClippingMask_var = tex2D(_ClippingMask,TRANSFORM_TEX(Set_UV0, _ClippingMask));
    float Set_Clipping = saturate((lerp( _ClippingMask_var.r, (1.0 - _ClippingMask_var.r), _Inverse_Clipping )+_Clipping_Level));
    clip(Set_Clipping - 0.5);
    #elif _IS_CLIPPING_TRANSMODE
    //_TransClipping
    float2 Set_UV0 = i.uv0;
    float4 _ClippingMask_var = tex2D(_ClippingMask,TRANSFORM_TEX(Set_UV0, _ClippingMask));
    float4 _MainTex_var = tex2D(_MainTex,TRANSFORM_TEX(Set_UV0, _MainTex));
    float Set_MainTexAlpha = _MainTex_var.a;
    float _IsBaseMapAlphaAsClippingMask_var = lerp( _ClippingMask_var.r, Set_MainTexAlpha, _IsBaseMapAlphaAsClippingMask );
    float _Inverse_Clipping_var = lerp( _IsBaseMapAlphaAsClippingMask_var, (1.0 - _IsBaseMapAlphaAsClippingMask_var), _Inverse_Clipping );
    float Set_Clipping = saturate((_Inverse_Clipping_var+_Clipping_Level));
    clip(Set_Clipping - 0.5);
    #elif _IS_CLIPPING_OFF
    //Default
    #endif
    //SHADOW_CASTER_FRAGMENT(i)
    return 0;
}

#endif