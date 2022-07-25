﻿//UCTS_Outline_tess.cginc
//Unitychan Toon Shader ver.2.0
//v.2.0.9
//nobuyuki@unity3d.com
//https://github.com/unity3d-jp/UnityChanToonShaderVer2_Project
//(C)Unity Technologies Japan/UCL
// カメラオフセット付きアウトライン（BaseColorライトカラー反映修正版/Tessellation対応版）
// 2018/02/05 Outline Tex対応版
// #pragma multi_compile _IS_OUTLINE_CLIPPING_NO _IS_OUTLINE_CLIPPING_YES 
// _IS_OUTLINE_CLIPPING_YESは、Clippigマスクを使用するシェーダーでのみ使用できる. OutlineのブレンドモードにBlend SrcAlpha OneMinusSrcAlphaを追加すること.
// ※Tessellation対応
//   対応部分のコードは、Nora氏の https://github.com/Stereoarts/UnityChanToonShaderVer2_Tess を参考にしました.
//

#ifndef UCTS_OUTLINE_TESS_URP
#define UCTS_OUTLINE_TESS_URP

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/GlobalIllumination.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/UnityInput.hlsl"
#include "Assets/UnityChanToonShaderVer2/Toon/Shader/URPInput.hlsl"

#ifdef TESSELLATION_ON
	#include "UCTS_Tess.hlsl"
#endif
#ifndef TESSELLATION_ON
	uniform float4 _LightColor0;
#endif
    uniform float4 _BaseColor;
    //v.2.0.7.5
    uniform float _Unlit_Intensity;
    uniform half _Is_Filter_LightColor;
    uniform half _Is_LightColor_Outline;
    //v.2.0.5
    uniform float4 _Color;
    uniform sampler2D _MainTex; uniform float4 _MainTex_ST;
    uniform float _Outline_Width;
    uniform float _Farthest_Distance;
    uniform float _Nearest_Distance;
    uniform sampler2D _Outline_Sampler; uniform float4 _Outline_Sampler_ST;
    uniform float4 _Outline_Color;
    uniform half _Is_BlendBaseColor;
    uniform float _Offset_Z;
    //v2.0.4
    uniform sampler2D _OutlineTex; uniform float4 _OutlineTex_ST;
    uniform half _Is_OutlineTex;
    //Baked Normal Texture for Outline
    uniform sampler2D _BakedNormal; uniform float4 _BakedNormal_ST;
    uniform half _Is_BakedNormal;
    //
//v.2.0.4
#ifdef _IS_OUTLINE_CLIPPING_YES
    uniform sampler2D _ClippingMask; uniform float4 _ClippingMask_ST;
    uniform float _Clipping_Level;
    uniform half _Inverse_Clipping;
    uniform half _IsBaseMapAlphaAsClippingMask;
#endif
#ifndef TESSELLATION_ON
    struct VertexInput {
        float4 vertex : POSITION;
        float3 normal : NORMAL;
        float4 tangent : TANGENT;
        float2 texcoord0 : TEXCOORD0;
        // v.2.0.9
        UNITY_VERTEX_INPUT_INSTANCE_ID
    };
#endif
    struct VertexOutput {
        float4 pos : SV_POSITION;
        float2 uv0 : TEXCOORD0;
        float3 normalDir : TEXCOORD1;
        float3 tangentDir : TEXCOORD2;
        float3 bitangentDir : TEXCOORD3;
        // v.2.0.9
        UNITY_VERTEX_INPUT_INSTANCE_ID
        UNITY_VERTEX_OUTPUT_STEREO
    };

    VertexOutput vert (VertexInput v) {
        VertexOutput o = (VertexOutput)0;
        UNITY_SETUP_INSTANCE_ID(v);
        UNITY_TRANSFER_INSTANCE_ID(v, o);
        UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
        o.uv0 = v.texcoord0;
        float4 objPos = mul ( unity_ObjectToWorld, float4(0,0,0,1) );
        float2 Set_UV0 = o.uv0;
        float4 _Outline_Sampler_var = tex2Dlod(_Outline_Sampler,float4(TRANSFORM_TEX(Set_UV0, _Outline_Sampler),0.0,0));
        //v.2.0.4.3 baked Normal Texture for Outline
        o.normalDir = TransformObjectToWorldNormal(v.normal);//UnityObjectToWorldNormal(v.normal);
        o.tangentDir = normalize( mul( unity_ObjectToWorld, float4( v.tangent.xyz, 0.0 ) ).xyz );
        o.bitangentDir = normalize(cross(o.normalDir, o.tangentDir) * v.tangent.w);
        float3x3 tangentTransform = float3x3( o.tangentDir, o.bitangentDir, o.normalDir);
        //UnpackNormal()が使えないので、以下で展開。使うテクスチャはBump指定をしないこと.
        float4 _BakedNormal_var = (tex2Dlod(_BakedNormal,float4(TRANSFORM_TEX(Set_UV0, _BakedNormal),0.0,0)) * 2 - 1);
        float3 _BakedNormalDir = normalize(mul(_BakedNormal_var.rgb, tangentTransform));
        //ここまで.
        float Set_Outline_Width = (_Outline_Width*0.001*smoothstep( _Farthest_Distance, _Nearest_Distance, distance(objPos.rgb,_WorldSpaceCameraPos) )*_Outline_Sampler_var.rgb).r;
        //v.2.0.7.5
        float4 _ClipCameraPos = mul(UNITY_MATRIX_VP, float4(_WorldSpaceCameraPos.xyz, 1));
        //v.2.0.7
        #if defined(UNITY_REVERSED_Z)
            //v.2.0.4.2 (DX)
            _Offset_Z = _Offset_Z * -0.01;
        #else
            //OpenGL
            _Offset_Z = _Offset_Z * 0.01;
        #endif
//v2.0.4
#ifdef _OUTLINE_NML
        //v.2.0.4.3 baked Normal Texture for Outline                
        o.pos = TransformObjectToHClip(lerp(float4(v.vertex.xyz + v.normal*Set_Outline_Width,1), float4(v.vertex.xyz + _BakedNormalDir*Set_Outline_Width,1),_Is_BakedNormal));// UnityObjectToClipPos(lerp(float4(v.vertex.xyz + v.normal*Set_Outline_Width,1), float4(v.vertex.xyz + _BakedNormalDir*Set_Outline_Width,1),_Is_BakedNormal));
#elif _OUTLINE_POS
        Set_Outline_Width = Set_Outline_Width*2;
        float signVar = dot(normalize(v.vertex),normalize(v.normal))<0 ? -1 : 1;
        o.pos = UnityObjectToClipPos(float4(v.vertex.xyz + signVar*normalize(v.vertex)*Set_Outline_Width, 1));
#endif
        //v.2.0.7.5
        o.pos.z = o.pos.z + _Offset_Z * _ClipCameraPos.z;
        return o;
    }
#ifdef TESSELLATION_ON
#ifdef UNITY_CAN_COMPILE_TESSELLATION
	tessellation domain shader
	[UNITY_domain("tri")]
	VertexOutput ds_surf(UnityTessellationFactors tessFactors, const OutputPatch<InternalTessInterp_VertexInput, 3> vi, float3 bary : SV_DomainLocation)
	{
		VertexInput v = _ds_VertexInput(tessFactors, vi, bary);
		return vert(v);
	}
#endif // UNITY_CAN_COMPILE_TESSELLATION
#endif // TESSELLATION_ON

    float4 frag(VertexOutput i) : SV_Target{
        UNITY_SETUP_INSTANCE_ID(i);
        UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
        //v.2.0.5
        _Color = _BaseColor;
        float4 objPos = mul ( unity_ObjectToWorld, float4(0,0,0,1) );
        //v.2.0.9
        float3 envLightSource_GradientEquator = unity_AmbientEquator.rgb >0.05 ? unity_AmbientEquator.rgb : half3(0.05,0.05,0.05);
        float3 envLightSource_SkyboxIntensity = max(SampleSH(half4(0.0,0.0,0.0,1.0)),SampleSH(half4(0.0,-1.0,0.0,1.0))).rgb;
        float3 ambientSkyColor = envLightSource_SkyboxIntensity.rgb>0.0 ? envLightSource_SkyboxIntensity*_Unlit_Intensity : envLightSource_GradientEquator*_Unlit_Intensity;
        //
        float3 lightColor = _MainLightColor.rgb >0.05 ? _MainLightColor.rgb : ambientSkyColor.rgb;
        float lightColorIntensity = (0.299*lightColor.r + 0.587*lightColor.g + 0.114*lightColor.b);
        lightColor = lightColorIntensity<1 ? lightColor : lightColor/lightColorIntensity;
        lightColor = lerp(half3(1.0,1.0,1.0), lightColor, _Is_LightColor_Outline);
        float2 Set_UV0 = i.uv0;
        float4 _MainTex_var = tex2D(_MainTex,TRANSFORM_TEX(Set_UV0, _MainTex));
        float3 Set_BaseColor = _BaseColor.rgb*_MainTex_var.rgb;
        float3 _Is_BlendBaseColor_var = lerp( _Outline_Color.rgb*lightColor, (_Outline_Color.rgb*Set_BaseColor*Set_BaseColor*lightColor), _Is_BlendBaseColor );
        //
        float3 _OutlineTex_var = tex2D(_OutlineTex,TRANSFORM_TEX(Set_UV0, _OutlineTex));
//v.2.0.7.5
#ifdef _IS_OUTLINE_CLIPPING_NO
        float3 Set_Outline_Color = lerp(_Is_BlendBaseColor_var, _OutlineTex_var.rgb*_Outline_Color.rgb*lightColor, _Is_OutlineTex );
        return float4(Set_Outline_Color,1.0);
#elif _IS_OUTLINE_CLIPPING_YES
        float4 _ClippingMask_var = tex2D(_ClippingMask,TRANSFORM_TEX(Set_UV0, _ClippingMask));
        float Set_MainTexAlpha = _MainTex_var.a;
        float _IsBaseMapAlphaAsClippingMask_var = lerp( _ClippingMask_var.r, Set_MainTexAlpha, _IsBaseMapAlphaAsClippingMask );
        float _Inverse_Clipping_var = lerp( _IsBaseMapAlphaAsClippingMask_var, (1.0 - _IsBaseMapAlphaAsClippingMask_var), _Inverse_Clipping );
        float Set_Clipping = saturate((_Inverse_Clipping_var+_Clipping_Level));
        clip(Set_Clipping - 0.5);
        float4 Set_Outline_Color = lerp( float4(_Is_BlendBaseColor_var,Set_Clipping), float4((_OutlineTex_var.rgb*_Outline_Color.rgb*lightColor),Set_Clipping), _Is_OutlineTex );
        return Set_Outline_Color;
#endif
    }
// UCTS_Outline_Tess.cginc ここまで.
#endif