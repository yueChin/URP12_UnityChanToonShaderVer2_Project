//UCTS_ShadingGradeMap.cginc
//Unitychan Toon Shader ver.2.0
//v.2.0.9
//nobuyuki@unity3d.com
//https://github.com/unity3d-jp/UnityChanToonShaderVer2_Project
//(C)Unity Technologies Japan/UCL
//#pragma multi_compile _IS_TRANSCLIPPING_OFF _IS_TRANSCLIPPING_ON
//#pragma multi_compile _IS_ANGELRING_OFF _IS_ANGELRING_ON
//#pragma multi_compile _IS_PASS_FWDBASE _IS_PASS_FWDDELTA
//#include "UCTS_ShadingGradeMap.cginc"
#ifndef UCTS_SHADINGGRADEMAP_URP
#define UCTS_SHADINGGRADEMAP_URP

#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/UnityInstancing.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/SpaceTransforms.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Macros.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/BRDF.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/GlobalIllumination.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/UnityInput.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RealtimeLights.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderVariablesFunctions.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Shaders/LitInput.hlsl"
#include "Assets/UnityChanToonShaderVer2/Toon/Shader/URPInput.hlsl"

CBUFFER_START(PREMATERIAL)
uniform sampler2D _MainTex; uniform float4 _MainTex_ST;
//uniform float4 _BaseColor;
//v.2.0.5
uniform float4 _Color;
uniform half _Use_BaseAs1st;
uniform half _Use_1stAs2nd;
//
uniform half _Is_LightColor_Base;
uniform sampler2D _1st_ShadeMap; uniform float4 _1st_ShadeMap_ST;
uniform float4 _1st_ShadeColor;
uniform half _Is_LightColor_1st_Shade;
uniform sampler2D _2nd_ShadeMap; uniform float4 _2nd_ShadeMap_ST;
uniform float4 _2nd_ShadeColor;
uniform half _Is_LightColor_2nd_Shade;
uniform sampler2D _NormalMap; uniform float4 _NormalMap_ST;
uniform half _Is_NormalMapToBase;
uniform half _Set_SystemShadowsToBase;
uniform float _Tweak_SystemShadowsLevel;
uniform sampler2D _ShadingGradeMap; uniform float4 _ShadingGradeMap_ST;
//v.2.0.6
uniform float _Tweak_ShadingGradeMapLevel;
uniform half _BlurLevelSGM;
//
uniform float _1st_ShadeColor_Step;
uniform float _1st_ShadeColor_Feather;
uniform float _2nd_ShadeColor_Step;
uniform float _2nd_ShadeColor_Feather;
uniform float4 _HighColor;
uniform sampler2D _HighColor_Tex; uniform float4 _HighColor_Tex_ST;
uniform half _Is_LightColor_HighColor;
uniform half _Is_NormalMapToHighColor;
uniform float _HighColor_Power;
uniform half _Is_SpecularToHighColor;
uniform half _Is_BlendAddToHiColor;
uniform half _Is_UseTweakHighColorOnShadow;
uniform float _TweakHighColorOnShadow;
uniform sampler2D _Set_HighColorMask; uniform float4 _Set_HighColorMask_ST;
uniform float _Tweak_HighColorMaskLevel;
uniform half _RimLight;
uniform float4 _RimLightColor;
uniform half _Is_LightColor_RimLight;
uniform half _Is_NormalMapToRimLight;
uniform float _RimLight_Power;
uniform float _RimLight_InsideMask;
uniform half _RimLight_FeatherOff;
uniform half _LightDirection_MaskOn;
uniform float _Tweak_LightDirection_MaskLevel;
uniform half _Add_Antipodean_RimLight;
uniform float4 _Ap_RimLightColor;
uniform half _Is_LightColor_Ap_RimLight;
uniform float _Ap_RimLight_Power;
uniform half _Ap_RimLight_FeatherOff;
uniform sampler2D _Set_RimLightMask; uniform float4 _Set_RimLightMask_ST;
uniform float _Tweak_RimLightMaskLevel;
uniform half _MatCap;
uniform sampler2D _MatCap_Sampler; uniform float4 _MatCap_Sampler_ST;
uniform float4 _MatCapColor;
uniform half _Is_LightColor_MatCap;
uniform half _Is_BlendAddToMatCap;
uniform float _Tweak_MatCapUV;
uniform float _Rotate_MatCapUV;
uniform half _Is_NormalMapForMatCap;
uniform sampler2D _NormalMapForMatCap; uniform float4 _NormalMapForMatCap_ST;
uniform float _Rotate_NormalMapForMatCapUV;
uniform half _Is_UseTweakMatCapOnShadow;
uniform float _TweakMatCapOnShadow;
//MatcapMask
uniform sampler2D _Set_MatcapMask; uniform float4 _Set_MatcapMask_ST;
uniform float _Tweak_MatcapMaskLevel;
//v.2.0.5
uniform half _Is_Ortho;
//v.2.0.6
uniform float _CameraRolling_Stabilizer;
uniform half _BlurLevelMatcap;
uniform half _Inverse_MatcapMask;
//uniform float _BumpScale;
uniform float _BumpScaleMatcap;
//Emissive
uniform sampler2D _Emissive_Tex; uniform float4 _Emissive_Tex_ST;
uniform float4 _Emissive_Color;
//v.2.0.7
uniform half _Is_ViewCoord_Scroll;
uniform float _Rotate_EmissiveUV;
uniform float _Base_Speed;
uniform float _Scroll_EmissiveU;
uniform float _Scroll_EmissiveV;
uniform half _Is_PingPong_Base;
uniform float4 _ColorShift;
uniform float4 _ViewShift;
uniform float _ColorShift_Speed;
uniform half _Is_ColorShift;
uniform half _Is_ViewShift;
uniform float3 emissive;
// 
uniform float _Unlit_Intensity;
//v.2.0.5
uniform half _Is_Filter_HiCutPointLightColor;
uniform half _Is_Filter_LightColor;
//v.2.0.4.4
uniform float _StepOffset;
uniform half _Is_BLD;
uniform float _Offset_X_Axis_BLD;
uniform float _Offset_Y_Axis_BLD;
uniform half _Inverse_Z_Axis_BLD;
CBUFFER_END

//v.2.0.4
#ifdef _IS_TRANSCLIPPING_OFF
//
#elif _IS_TRANSCLIPPING_ON
uniform sampler2D _ClippingMask; uniform float4 _ClippingMask_ST;
uniform half _IsBaseMapAlphaAsClippingMask;
uniform float _Clipping_Level;
uniform half _Inverse_Clipping;
uniform float _Tweak_transparency;
#endif

uniform float _GI_Intensity;
//v.2.0.4
#ifdef _IS_ANGELRING_OFF
//
#elif _IS_ANGELRING_ON
uniform half _AngelRing;
uniform sampler2D _AngelRing_Sampler; uniform float4 _AngelRing_Sampler_ST;
uniform float4 _AngelRing_Color;
uniform half _Is_LightColor_AR;
uniform float _AR_OffsetU;
uniform float _AR_OffsetV;
uniform half _ARSampler_AlphaOn;
#endif

// UV回転をする関数：RotateUV()
//float2 rotatedUV = RotateUV(i.uv0, (_angular_Verocity*3.141592654), float2(0.5, 0.5), _Time.g);
float2 RotateUV(float2 _uv, float _radian, float2 _piv, float _time)
{
    float RotateUV_ang = _radian;
    float RotateUV_cos = cos(_time*RotateUV_ang);
    float RotateUV_sin = sin(_time*RotateUV_ang);
    return (mul(_uv - _piv, float2x2( RotateUV_cos, -RotateUV_sin, RotateUV_sin, RotateUV_cos)) + _piv);
}
//
half3 DecodeLightProbe( half3 N ){
    return SampleSH(N);
}

struct Attributes
{
    float4 positionOS   : POSITION;
    float3 normalOS     : NORMAL;
    float4 tangentOS    : TANGENT;
    float2 texcoord0     : TEXCOORD0;
    float2 lightmapUV   : TEXCOORD1;
    //v.2.0.4
    #ifdef _IS_ANGELRING_OFF
    //
    #elif _IS_ANGELRING_ON
    float2 texcoord1 : TEXCOORD2;
    #endif
    // v.2.0.9
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct Varyings
{
    float2 uv0                       : TEXCOORD0;
#ifdef _IS_ANGELRING_OFF
    DECLARE_LIGHTMAP_OR_SH(lightmapUV, vertexSH, 1);
    float3 positionWS               : TEXCOORD2;
    float3 normalWS                 : TEXCOORD3;
    float4 tangentWS                : TEXCOORD4;    // xyz: tangent, w: sign
    float3 bitangentWS              : TEXCOORD5;

    half4 fogFactorAndVertexLight   : TEXCOORD7; // x: fogFactor, yzw: vertex light

    float4 shadowCoord              : TEXCOORD8;
    float mirrorFlag : TEXCOORD9;
#elif _IS_ANGELRING_ON
    float2 uv1 : TEXCOORD1;
    DECLARE_LIGHTMAP_OR_SH(lightmapUV, vertexSH, 2);
    float3 positionWS : TEXCOORD3;
    float3 normalWS : TEXCOORD4;
    float4 tangentWS : TEXCOORD5;
    float3 bitangentWS : TEXCOORD6;
    //v.2.0.7
    float mirrorFlag : TEXCOORD7;
    float4 shadowCoord              : TEXCOORD8;
    half4 fogFactorAndVertexLight   : TEXCOORD9;
#endif
    float4 positionCS               : SV_POSITION;
    
    UNITY_VERTEX_INPUT_INSTANCE_ID
    UNITY_VERTEX_OUTPUT_STEREO
};

void InitializeInputData(Varyings input, half3 normalTS, out InputData inputData)
{
    inputData = (InputData)0;

#if defined(REQUIRES_WORLD_SPACE_POS_INTERPOLATOR)
    inputData.positionWS = input.positionWS;
#endif

    half3 viewDirWS = SafeNormalize(_WorldSpaceCameraPos.xyz - input.positionWS.xyz);
#if defined(_NORMALMAP) || defined(_DETAIL)
    float sgn = input.tangentWS.w;      // should be either +1 or -1
    float3 bitangent = sgn * cross(input.normalWS.xyz, input.tangentWS.xyz);
    inputData.normalWS = TransformTangentToWorld(normalTS, half3x3(input.tangentWS.xyz, bitangent.xyz, input.normalWS.xyz));
#else
    inputData.normalWS = input.normalWS;
#endif

    inputData.normalWS = NormalizeNormalPerPixel(inputData.normalWS);
    inputData.viewDirectionWS = viewDirWS;

#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
    inputData.shadowCoord = input.shadowCoord;
#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
    inputData.shadowCoord = TransformWorldToShadowCoord(inputData.positionWS);
#else
    inputData.shadowCoord = float4(0, 0, 0, 0);
#endif

    inputData.fogCoord = input.fogFactorAndVertexLight.x;
    inputData.vertexLighting = input.fogFactorAndVertexLight.yzw;
    inputData.bakedGI = SAMPLE_GI(input.lightmapUV, input.vertexSH, inputData.normalWS);
    inputData.normalizedScreenSpaceUV = GetNormalizedScreenSpaceUV(input.positionCS);
    inputData.shadowMask = SAMPLE_SHADOWMASK(input.lightmapUV);
}

struct ToonSurfaceData
{
    Varyings input;
    float2 Set_UV0;
    float3 normalDirection;
    float4 _MainTex_var;
    float3 viewDirection;
#if _IS_TRANSCLIPPING_ON
    float _Inverse_Clipping_var;
#endif
};

float4 GetMainLightColor(ToonSurfaceData tsd,float3x3 tangentTransform)
{
    float3 defaultLightDirection = normalize(unity_MatrixV[2].xyz + unity_MatrixV[1].xyz);
    //v.2.0.5
    float3 defaultLightColor = saturate(max(half3(0.05,0.05,0.05)*_Unlit_Intensity,max(SampleSH(half4(0.0, 0.0, 0.0, 1.0)),SampleSH(half4(0.0, -1.0, 0.0, 1.0)).rgb)*_Unlit_Intensity));
    float3 customLightDirection = normalize(mul( unity_ObjectToWorld, float4(((float3(1.0,0.0,0.0)*_Offset_X_Axis_BLD*10)+(float3(0.0,1.0,0.0)*_Offset_Y_Axis_BLD*10)+(float3(0.0,0.0,-1.0)*lerp(-1.0,1.0,_Inverse_Z_Axis_BLD))),0)).xyz);

    float3 lightDirection = normalize(lerp(defaultLightDirection,_MainLightPosition.xyz,any(_MainLightPosition.xyz)));
    lightDirection = lerp(lightDirection, customLightDirection, _Is_BLD);
    //v.2.0.5:
    float3 lightColor = lerp(max(defaultLightColor,_MainLightColor.rgb),max(defaultLightColor,saturate(_MainLightColor.rgb)),_Is_Filter_LightColor);
    float3 halfDirection = normalize(tsd.viewDirection+lightDirection);
    float3 Set_LightColor = lightColor.rgb;
    float3 Set_BaseColor = lerp( (tsd._MainTex_var.rgb*_BaseColor.rgb), ((tsd._MainTex_var.rgb*_BaseColor.rgb)*Set_LightColor), _Is_LightColor_Base );
    //v.2.0.5
    float4 _1st_ShadeMap_var = lerp(tex2D(_1st_ShadeMap,TRANSFORM_TEX(tsd.Set_UV0, _1st_ShadeMap)),tsd._MainTex_var,_Use_BaseAs1st);
    float3 _Is_LightColor_1st_Shade_var = lerp( (_1st_ShadeMap_var.rgb*_1st_ShadeColor.rgb), ((_1st_ShadeMap_var.rgb*_1st_ShadeColor.rgb)*Set_LightColor), _Is_LightColor_1st_Shade );
    float _HalfLambert_var = 0.5*dot(lerp( tsd.input.normalWS, tsd.normalDirection, _Is_NormalMapToBase ),lightDirection)+0.5; // Half Lambert
    //float4 _ShadingGradeMap_var = tex2D(_ShadingGradeMap,TRANSFORM_TEX(Set_UV0, _ShadingGradeMap));
    //v.2.0.6
    float4 _ShadingGradeMap_var = tex2Dlod(_ShadingGradeMap,float4(TRANSFORM_TEX(tsd.Set_UV0, _ShadingGradeMap),0.0,_BlurLevelSGM));
    //v.2.0.6
    //Minmimum value is same as the Minimum Feather's value with the Minimum Step's value as threshold.
    float _SystemShadowsLevel_var = (_MainLightShadowParams.x*0.5)+0.5+_Tweak_SystemShadowsLevel > 0.001 ? (_MainLightShadowParams.x*0.5)+0.5+_Tweak_SystemShadowsLevel : 0.0001;
    float _ShadingGradeMapLevel_var = _ShadingGradeMap_var.r < 0.95 ? _ShadingGradeMap_var.r+_Tweak_ShadingGradeMapLevel : 1;
    float Set_ShadingGrade = saturate(_ShadingGradeMapLevel_var)*lerp( _HalfLambert_var, (_HalfLambert_var*saturate(_SystemShadowsLevel_var)), _Set_SystemShadowsToBase );
    //
    float Set_FinalShadowMask = saturate((1.0 + ( (Set_ShadingGrade - (_1st_ShadeColor_Step-_1st_ShadeColor_Feather)) * (0.0 - 1.0) ) / (_1st_ShadeColor_Step - (_1st_ShadeColor_Step-_1st_ShadeColor_Feather)))); // Base and 1st Shade Mask
    float3 _BaseColor_var = lerp(Set_BaseColor,_Is_LightColor_1st_Shade_var,Set_FinalShadowMask);
    //v.2.0.5
    float4 _2nd_ShadeMap_var = lerp(tex2D(_2nd_ShadeMap,TRANSFORM_TEX(tsd.Set_UV0, _2nd_ShadeMap)),_1st_ShadeMap_var,_Use_1stAs2nd);
    float Set_ShadeShadowMask = saturate((1.0 + ( (Set_ShadingGrade - (_2nd_ShadeColor_Step-_2nd_ShadeColor_Feather)) * (0.0 - 1.0) ) / (_2nd_ShadeColor_Step - (_2nd_ShadeColor_Step-_2nd_ShadeColor_Feather)))); // 1st and 2nd Shades Mask
    //Composition: 3 Basic Colors as Set_FinalBaseColor
    float3 Set_FinalBaseColor = lerp(_BaseColor_var,lerp(_Is_LightColor_1st_Shade_var,lerp( (_2nd_ShadeMap_var.rgb*_2nd_ShadeColor.rgb), ((_2nd_ShadeMap_var.rgb*_2nd_ShadeColor.rgb)*Set_LightColor), _Is_LightColor_2nd_Shade ),Set_ShadeShadowMask),Set_FinalShadowMask);
    float4 _Set_HighColorMask_var = tex2D(_Set_HighColorMask,TRANSFORM_TEX(tsd.Set_UV0, _Set_HighColorMask));
    float _Specular_var = 0.5*dot(halfDirection,lerp( tsd.input.normalWS, tsd.normalDirection, _Is_NormalMapToHighColor ))+0.5; // Specular
    float _TweakHighColorMask_var = (saturate((_Set_HighColorMask_var.g+_Tweak_HighColorMaskLevel))*lerp( (1.0 - step(_Specular_var,(1.0 - pow(_HighColor_Power,5)))), pow(_Specular_var,exp2(lerp(11,1,_HighColor_Power))), _Is_SpecularToHighColor ));
    float4 _HighColor_Tex_var = tex2D(_HighColor_Tex,TRANSFORM_TEX(tsd.Set_UV0, _HighColor_Tex));
    float3 _HighColor_var = (lerp( (_HighColor_Tex_var.rgb*_HighColor.rgb), ((_HighColor_Tex_var.rgb*_HighColor.rgb)*Set_LightColor), _Is_LightColor_HighColor )*_TweakHighColorMask_var);
    //Composition: 3 Basic Colors and HighColor as Set_HighColor
    float3 Set_HighColor = (lerp( saturate((Set_FinalBaseColor-_TweakHighColorMask_var)), Set_FinalBaseColor, lerp(_Is_BlendAddToHiColor,1.0,_Is_SpecularToHighColor) )+lerp( _HighColor_var, (_HighColor_var*((1.0 - Set_FinalShadowMask)+(Set_FinalShadowMask*_TweakHighColorOnShadow))), _Is_UseTweakHighColorOnShadow ));
    float4 _Set_RimLightMask_var = tex2D(_Set_RimLightMask,TRANSFORM_TEX(tsd.Set_UV0, _Set_RimLightMask));
    float3 _Is_LightColor_RimLight_var = lerp( _RimLightColor.rgb, (_RimLightColor.rgb*Set_LightColor), _Is_LightColor_RimLight );
    float _RimArea_var = (1.0 - dot(lerp( tsd.input.normalWS, tsd.normalDirection, _Is_NormalMapToRimLight ),tsd.viewDirection));
    float _RimLightPower_var = pow(_RimArea_var,exp2(lerp(3,0,_RimLight_Power)));
    float _Rimlight_InsideMask_var = saturate(lerp( (0.0 + ( (_RimLightPower_var - _RimLight_InsideMask) * (1.0 - 0.0) ) / (1.0 - _RimLight_InsideMask)), step(_RimLight_InsideMask,_RimLightPower_var), _RimLight_FeatherOff ));
    float _VertHalfLambert_var = 0.5*dot(tsd.input.normalWS,lightDirection)+0.5;
    float3 _LightDirection_MaskOn_var = lerp( (_Is_LightColor_RimLight_var*_Rimlight_InsideMask_var), (_Is_LightColor_RimLight_var*saturate((_Rimlight_InsideMask_var-((1.0 - _VertHalfLambert_var)+_Tweak_LightDirection_MaskLevel)))), _LightDirection_MaskOn );
    float _ApRimLightPower_var = pow(_RimArea_var,exp2(lerp(3,0,_Ap_RimLight_Power)));
    float3 Set_RimLight = (saturate((_Set_RimLightMask_var.g+_Tweak_RimLightMaskLevel))*lerp( _LightDirection_MaskOn_var, (_LightDirection_MaskOn_var+(lerp( _Ap_RimLightColor.rgb, (_Ap_RimLightColor.rgb*Set_LightColor), _Is_LightColor_Ap_RimLight )*saturate((lerp( (0.0 + ( (_ApRimLightPower_var - _RimLight_InsideMask) * (1.0 - 0.0) ) / (1.0 - _RimLight_InsideMask)), step(_RimLight_InsideMask,_ApRimLightPower_var), _Ap_RimLight_FeatherOff )-(saturate(_VertHalfLambert_var)+_Tweak_LightDirection_MaskLevel))))), _Add_Antipodean_RimLight ));
    //Composition: HighColor and RimLight as _RimLight_var
    float3 _RimLight_var = lerp( Set_HighColor, (Set_HighColor+Set_RimLight), _RimLight );
    //Matcap
    //v.2.0.6 : CameraRolling Stabilizer
    //鏡スクリプト判定：_sign_Mirror = -1 なら、鏡の中と判定.
    //v.2.0.7
    half _sign_Mirror = tsd.input.mirrorFlag;
    //
    float3 _Camera_Right = unity_MatrixV[0].xyz;
    float3 _Camera_Front = unity_MatrixV[2].xyz;
    float3 _Up_Unit = float3(0, 1, 0);
    float3 _Right_Axis = cross(_Camera_Front, _Up_Unit);
    //鏡の中なら反転.
    if(_sign_Mirror < 0){
        _Right_Axis = -1 * _Right_Axis;
        _Rotate_MatCapUV = -1 * _Rotate_MatCapUV;
    }else{
        _Right_Axis = _Right_Axis;
    }
    float _Camera_Right_Magnitude = sqrt(_Camera_Right.x*_Camera_Right.x + _Camera_Right.y*_Camera_Right.y + _Camera_Right.z*_Camera_Right.z);
    float _Right_Axis_Magnitude = sqrt(_Right_Axis.x*_Right_Axis.x + _Right_Axis.y*_Right_Axis.y + _Right_Axis.z*_Right_Axis.z);
    float _Camera_Roll_Cos = dot(_Right_Axis, _Camera_Right) / (_Right_Axis_Magnitude * _Camera_Right_Magnitude);
    float _Camera_Roll = acos(clamp(_Camera_Roll_Cos, -1, 1));
    half _Camera_Dir = _Camera_Right.y < 0 ? -1 : 1;
    float _Rot_MatCapUV_var_ang = (_Rotate_MatCapUV*3.141592654) - _Camera_Dir*_Camera_Roll*_CameraRolling_Stabilizer;
    //v.2.0.7
    float2 _Rot_MatCapNmUV_var = RotateUV(tsd.Set_UV0, (_Rotate_NormalMapForMatCapUV*3.141592654), float2(0.5, 0.5), 1.0);
    //V.2.0.6
    float3 _NormalMapForMatCap_var = UnpackScaleNormal(tex2D(_NormalMapForMatCap,TRANSFORM_TEX(_Rot_MatCapNmUV_var, _NormalMapForMatCap)),_BumpScaleMatcap);
    //v.2.0.5: MatCap with camera skew correction
    float3 viewNormal = (mul(unity_MatrixV, float4(lerp( tsd.input.normalWS, mul( _NormalMapForMatCap_var.rgb, tangentTransform ).rgb, _Is_NormalMapForMatCap ),0))).rgb;
    float3 NormalBlend_MatcapUV_Detail = viewNormal.rgb * float3(-1,-1,1);
    float3 NormalBlend_MatcapUV_Base = (mul( unity_MatrixV, float4(tsd.viewDirection,0) ).rgb*float3(-1,-1,1)) + float3(0,0,1);
    float3 noSknewViewNormal = NormalBlend_MatcapUV_Base*dot(NormalBlend_MatcapUV_Base, NormalBlend_MatcapUV_Detail)/NormalBlend_MatcapUV_Base.b - NormalBlend_MatcapUV_Detail;                
    float2 _ViewNormalAsMatCapUV = (lerp(noSknewViewNormal,viewNormal,_Is_Ortho).rg*0.5)+0.5;
    //
    //v.2.0.7
    float2 _Rot_MatCapUV_var = RotateUV((0.0 + ((_ViewNormalAsMatCapUV - (0.0+_Tweak_MatCapUV)) * (1.0 - 0.0) ) / ((1.0-_Tweak_MatCapUV) - (0.0+_Tweak_MatCapUV))), _Rot_MatCapUV_var_ang, float2(0.5, 0.5), 1.0);
    //鏡の中ならUV左右反転.
    if(_sign_Mirror < 0){
        _Rot_MatCapUV_var.x = 1-_Rot_MatCapUV_var.x;
    }else{
        _Rot_MatCapUV_var = _Rot_MatCapUV_var;
    }
    //v.2.0.6 : LOD of Matcap
    float4 _MatCap_Sampler_var = tex2Dlod(_MatCap_Sampler,float4(TRANSFORM_TEX(_Rot_MatCapUV_var, _MatCap_Sampler),0.0,_BlurLevelMatcap));
    //                
    //MatcapMask
    float4 _Set_MatcapMask_var = tex2D(_Set_MatcapMask,TRANSFORM_TEX(tsd.Set_UV0, _Set_MatcapMask));
    float _Tweak_MatcapMaskLevel_var = saturate(lerp(_Set_MatcapMask_var.g, (1.0 - _Set_MatcapMask_var.g), _Inverse_MatcapMask) + _Tweak_MatcapMaskLevel);
    float3 _Is_LightColor_MatCap_var = lerp( (_MatCap_Sampler_var.rgb*_MatCapColor.rgb), ((_MatCap_Sampler_var.rgb*_MatCapColor.rgb)*Set_LightColor), _Is_LightColor_MatCap );
    //v.2.0.6 : ShadowMask on Matcap in Blend mode : multiply
    float3 Set_MatCap = lerp( _Is_LightColor_MatCap_var, (_Is_LightColor_MatCap_var*((1.0 - Set_FinalShadowMask)+(Set_FinalShadowMask*_TweakMatCapOnShadow)) + lerp(Set_HighColor*Set_FinalShadowMask*(1.0-_TweakMatCapOnShadow), float3(0.0, 0.0, 0.0), _Is_BlendAddToMatCap)), _Is_UseTweakMatCapOnShadow );
    //
    //v.2.0.6
    //Composition: RimLight and MatCap as finalColor
    //Broke down finalColor composition
    float3 matCapColorOnAddMode = _RimLight_var+Set_MatCap*_Tweak_MatcapMaskLevel_var;
    float _Tweak_MatcapMaskLevel_var_MultiplyMode = _Tweak_MatcapMaskLevel_var * lerp (1, (1 - (Set_FinalShadowMask)*(1 - _TweakMatCapOnShadow)), _Is_UseTweakMatCapOnShadow);
    float3 matCapColorOnMultiplyMode = Set_HighColor*(1-_Tweak_MatcapMaskLevel_var_MultiplyMode) + Set_HighColor*Set_MatCap*_Tweak_MatcapMaskLevel_var_MultiplyMode + lerp(float3(0,0,0),Set_RimLight,_RimLight);
    float3 matCapColorFinal = lerp(matCapColorOnMultiplyMode, matCapColorOnAddMode, _Is_BlendAddToMatCap);
//v.2.0.4
#ifdef _IS_ANGELRING_OFF
    float3 finalColor = lerp(_RimLight_var, matCapColorFinal, _MatCap);// Final Composition before Emissive
    //
#elif _IS_ANGELRING_ON
    float3 finalColor = lerp(_RimLight_var, matCapColorFinal, _MatCap);// Final Composition before AR
    //v.2.0.7 AR Camera Rolling Stabilizer
    float3 _AR_OffsetU_var = lerp(mul(UNITY_MATRIX_V, float4(tsd.input.normalWS,0)).xyz,float3(0,0,1),_AR_OffsetU);
    float2 AR_VN = _AR_OffsetU_var.xy*0.5 + float2(0.5,0.5);
    float2 AR_VN_Rotate = RotateUV(AR_VN, -(_Camera_Dir*_Camera_Roll), float2(0.5,0.5), 1.0);
    float2 _AR_OffsetV_var = float2(AR_VN_Rotate.x, lerp(tsd.input.uv1.y, AR_VN_Rotate.y, _AR_OffsetV));
    float4 _AngelRing_Sampler_var = tex2D(_AngelRing_Sampler,TRANSFORM_TEX(_AR_OffsetV_var, _AngelRing_Sampler));
    float3 _Is_LightColor_AR_var = lerp( (_AngelRing_Sampler_var.rgb*_AngelRing_Color.rgb), ((_AngelRing_Sampler_var.rgb*_AngelRing_Color.rgb)*Set_LightColor), _Is_LightColor_AR );
    float3 Set_AngelRing = _Is_LightColor_AR_var;
    float Set_ARtexAlpha = _AngelRing_Sampler_var.a;
    float3 Set_AngelRingWithAlpha = (_Is_LightColor_AR_var*_AngelRing_Sampler_var.a);
    //Composition: MatCap and AngelRing as finalColor
    finalColor = lerp(finalColor, lerp((finalColor + Set_AngelRing), ((finalColor*(1.0 - Set_ARtexAlpha))+Set_AngelRingWithAlpha), _ARSampler_AlphaOn ), _AngelRing );// Final Composition before Emissive
#endif
//v.2.0.7
#ifdef _EMISSIVE_SIMPLE
    float4 _Emissive_Tex_var = tex2D(_Emissive_Tex,TRANSFORM_TEX(tsd.Set_UV0, _Emissive_Tex));
    float emissiveMask = _Emissive_Tex_var.a;
    emissive = _Emissive_Tex_var.rgb * _Emissive_Color.rgb * emissiveMask;
#elif _EMISSIVE_ANIMATION
    //v.2.0.7 Calculation View Coord UV for Scroll 
    float3 viewNormal_Emissive = (mul(UNITY_MATRIX_V, float4(tsd.input.normalWS,0))).xyz;
    float3 NormalBlend_Emissive_Detail = viewNormal_Emissive * float3(-1,-1,1);
    float3 NormalBlend_Emissive_Base = (mul( UNITY_MATRIX_V, float4(tsd.viewDirection,0)).xyz*float3(-1,-1,1)) + float3(0,0,1);
    float3 noSknewViewNormal_Emissive = NormalBlend_Emissive_Base*dot(NormalBlend_Emissive_Base, NormalBlend_Emissive_Detail)/NormalBlend_Emissive_Base.z - NormalBlend_Emissive_Detail;
    float2 _ViewNormalAsEmissiveUV = noSknewViewNormal_Emissive.xy*0.5+0.5;
    float2 _ViewCoord_UV = RotateUV(_ViewNormalAsEmissiveUV, -(_Camera_Dir*_Camera_Roll), float2(0.5,0.5), 1.0);
    //鏡の中ならUV左右反転.
    if(_sign_Mirror < 0){
        _ViewCoord_UV.x = 1-_ViewCoord_UV.x;
    }else{
        _ViewCoord_UV = _ViewCoord_UV;
    }
    float2 emissive_uv = lerp(tsd.input.uv0, _ViewCoord_UV, _Is_ViewCoord_Scroll);
    //
    float4 _time_var = _Time;
    float _base_Speed_var = (_time_var.g*_Base_Speed);
    float _Is_PingPong_Base_var = lerp(_base_Speed_var, sin(_base_Speed_var), _Is_PingPong_Base );
    float2 scrolledUV = emissive_uv + float2(_Scroll_EmissiveU, _Scroll_EmissiveV)*_Is_PingPong_Base_var;
    float rotateVelocity = _Rotate_EmissiveUV*3.141592654;
    float2 _rotate_EmissiveUV_var = RotateUV(scrolledUV, rotateVelocity, float2(0.5, 0.5), _Is_PingPong_Base_var);
    float4 _Emissive_Tex_var = tex2D(_Emissive_Tex,TRANSFORM_TEX(tsd.Set_UV0, _Emissive_Tex));
    float emissiveMask = _Emissive_Tex_var.a;
    _Emissive_Tex_var = tex2D(_Emissive_Tex,TRANSFORM_TEX(_rotate_EmissiveUV_var, _Emissive_Tex));
    float _colorShift_Speed_var = 1.0 - cos(_time_var.g*_ColorShift_Speed);
    float viewShift_var = smoothstep( 0.0, 1.0, max(0,dot(tsd.normalDirection,tsd.viewDirection)));
    float4 colorShift_Color = lerp(_Emissive_Color, lerp(_Emissive_Color, _ColorShift, _colorShift_Speed_var), _Is_ColorShift);
    float4 viewShift_Color = lerp(_ViewShift, colorShift_Color, viewShift_var);
    float4 emissive_Color = lerp(colorShift_Color, viewShift_Color, _Is_ViewShift);
    emissive = emissive_Color.rgb * _Emissive_Tex_var.rgb * emissiveMask;
#endif
//
    //v.2.0.6: GI_Intensity with Intensity Multiplier Filter
    float3 envLightColor = DecodeLightProbe(tsd.normalDirection) < float3(1,1,1) ? DecodeLightProbe(tsd.normalDirection) : float3(1,1,1);
    float envLightIntensity = 0.299*envLightColor.r + 0.587*envLightColor.g + 0.114*envLightColor.b <1 ? (0.299*envLightColor.r + 0.587*envLightColor.g + 0.114*envLightColor.b) : 1;
    //Final Composition
    finalColor =  saturate(finalColor) + (envLightColor*envLightIntensity*_GI_Intensity*smoothstep(1,0,envLightIntensity/2)) + emissive;

    //v.2.0.4
#ifdef _IS_TRANSCLIPPING_OFF
    half4 finalRGBA = half4(finalColor,1);
#elif _IS_TRANSCLIPPING_ON
    float Set_Opacity = saturate((tsd._Inverse_Clipping_var+_Tweak_transparency));
    half4 finalRGBA = half4(finalColor,Set_Opacity);
#endif
    return finalRGBA;
}

float4 GetAdditionLightColor(ToonSurfaceData tsd,Light light)
{
//v.2.0.4

    float3 lightDirection = normalize(lerp(light.lightPositionWS.xyz, light.lightPositionWS.xyz - tsd.input.positionWS.xyz,light.lightPositionWS.w));
    //v.2.0.5: 
    float3 addPassLightColor = (0.5*dot(lerp( tsd.input.normalWS, tsd.normalDirection, _Is_NormalMapToBase ), lightDirection)+0.5) * _MainLightColor.rgb * light.shadowAttenuation;
    float pureIntencity = max(0.001,(0.299*_MainLightColor.r + 0.587*_MainLightColor.g + 0.114*_MainLightColor.b));
    float3 lightColor = max(0, lerp(addPassLightColor, lerp(0,min(addPassLightColor,addPassLightColor/pureIntencity),light.lightPositionWS.w),_Is_Filter_LightColor));
////// Lighting:
    float3 halfDirection = normalize(tsd.viewDirection+lightDirection);
    //v.2.0.5
    _Color = _BaseColor;
    
    //v.2.0.4.4
    _1st_ShadeColor_Step = saturate(_1st_ShadeColor_Step + _StepOffset);
    _2nd_ShadeColor_Step = saturate(_2nd_ShadeColor_Step + _StepOffset);
    //
    //v.2.0.5: If Added lights is directional, set 0 as _LightIntensity
    float _LightIntensity = lerp(0,(0.299*_MainLightColor.r + 0.587*_MainLightColor.g + 0.114*_MainLightColor.b)*light.shadowAttenuation,light.lightPositionWS.w) ;
    //v.2.0.5: Filtering the high intensity zone of PointLights
    float3 Set_LightColor = lerp(lightColor,lerp(lightColor,min(lightColor,_MainLightColor.rgb*light.shadowAttenuation*_1st_ShadeColor_Step),light.lightPositionWS.w),_Is_Filter_HiCutPointLightColor);
    //
    float3 Set_BaseColor = lerp( (tsd._MainTex_var.rgb*_BaseColor.rgb*_LightIntensity), ((tsd._MainTex_var.rgb*_BaseColor.rgb)*Set_LightColor), _Is_LightColor_Base );
    //v.2.0.5
    float4 _1st_ShadeMap_var = lerp(tex2D(_1st_ShadeMap,TRANSFORM_TEX(tsd.Set_UV0, _1st_ShadeMap)),tsd._MainTex_var,_Use_BaseAs1st);
    float3 _Is_LightColor_1st_Shade_var = lerp( (_1st_ShadeMap_var.rgb*_1st_ShadeColor.rgb*_LightIntensity), ((_1st_ShadeMap_var.rgb*_1st_ShadeColor.rgb)*Set_LightColor), _Is_LightColor_1st_Shade );
    float _HalfLambert_var = 0.5*dot(lerp( tsd.input.normalWS, tsd.normalDirection, _Is_NormalMapToBase ),lightDirection)+0.5; // Half Lambert
    //v.2.0.6
    float4 _ShadingGradeMap_var = tex2Dlod(_ShadingGradeMap,float4(TRANSFORM_TEX(tsd.Set_UV0, _ShadingGradeMap),0.0,_BlurLevelSGM));
    //v.2.0.6
    float _ShadingGradeMapLevel_var = _ShadingGradeMap_var.r < 0.95 ? _ShadingGradeMap_var.r+_Tweak_ShadingGradeMapLevel : 1;
    float Set_ShadingGrade = saturate(_ShadingGradeMapLevel_var)*lerp( _HalfLambert_var, (_HalfLambert_var*saturate(1.0+_Tweak_SystemShadowsLevel)), _Set_SystemShadowsToBase );
    //
    float Set_FinalShadowMask = saturate((1.0 + ( (Set_ShadingGrade - (_1st_ShadeColor_Step-_1st_ShadeColor_Feather)) * (0.0 - 1.0) ) / (_1st_ShadeColor_Step - (_1st_ShadeColor_Step-_1st_ShadeColor_Feather)))); // Base and 1st Shade Mask
    float3 _BaseColor_var = lerp(Set_BaseColor,_Is_LightColor_1st_Shade_var,Set_FinalShadowMask);
    //v.2.0.5
    float4 _2nd_ShadeMap_var = lerp(tex2D(_2nd_ShadeMap,TRANSFORM_TEX(tsd.Set_UV0, _2nd_ShadeMap)),_1st_ShadeMap_var,_Use_1stAs2nd);
    float Set_ShadeShadowMask = saturate((1.0 + ( (Set_ShadingGrade - (_2nd_ShadeColor_Step-_2nd_ShadeColor_Feather)) * (0.0 - 1.0) ) / (_2nd_ShadeColor_Step - (_2nd_ShadeColor_Step-_2nd_ShadeColor_Feather)))); // 1st and 2nd Shades Mask
    //Composition: 3 Basic Colors as finalColor
    float3 finalColor = lerp(_BaseColor_var,lerp(_Is_LightColor_1st_Shade_var,lerp( (_2nd_ShadeMap_var.rgb*_2nd_ShadeColor.rgb*_LightIntensity), ((_2nd_ShadeMap_var.rgb*_2nd_ShadeColor.rgb)*Set_LightColor), _Is_LightColor_2nd_Shade ),Set_ShadeShadowMask),Set_FinalShadowMask);

    //v.2.0.6: Add HighColor if _Is_Filter_HiCutPointLightColor is False
    float4 _Set_HighColorMask_var = tex2D(_Set_HighColorMask,TRANSFORM_TEX(tsd.Set_UV0, _Set_HighColorMask));
    float _Specular_var = 0.5*dot(halfDirection,lerp( tsd.input.normalWS, tsd.normalDirection, _Is_NormalMapToHighColor ))+0.5; // Specular
    float _TweakHighColorMask_var = (saturate((_Set_HighColorMask_var.g+_Tweak_HighColorMaskLevel))*lerp( (1.0 - step(_Specular_var,(1.0 - pow(_HighColor_Power,5)))), pow(_Specular_var,exp2(lerp(11,1,_HighColor_Power))), _Is_SpecularToHighColor ));
    float4 _HighColor_Tex_var = tex2D(_HighColor_Tex,TRANSFORM_TEX(tsd.Set_UV0, _HighColor_Tex));
    float3 _HighColor_var = (lerp( (_HighColor_Tex_var.rgb*_HighColor.rgb), ((_HighColor_Tex_var.rgb*_HighColor.rgb)*Set_LightColor), _Is_LightColor_HighColor )*_TweakHighColorMask_var);
    finalColor = finalColor + lerp(lerp( _HighColor_var, (_HighColor_var*((1.0 - Set_FinalShadowMask)+(Set_FinalShadowMask*_TweakHighColorOnShadow))), _Is_UseTweakHighColorOnShadow ),float3(0,0,0),_Is_Filter_HiCutPointLightColor);
    //

    finalColor = saturate(finalColor);

    //v.2.0.4
#ifdef _IS_TRANSCLIPPING_OFF
    half4 finalRGBA = half4(finalColor,0);
#elif _IS_TRANSCLIPPING_ON
    float Set_Opacity = saturate((tsd._Inverse_Clipping_var+_Tweak_transparency));
    half4 finalRGBA = half4(finalColor * Set_Opacity,0);
#endif
    return finalRGBA;
}

// Used in Standard (Physically Based) shader
Varyings LitPassVertex(Attributes input)
{
    Varyings output = (Varyings)0;

    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_TRANSFER_INSTANCE_ID(input, output);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

    VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);

    // normalWS and tangentWS already normalize.
    // this is required to avoid skewing the direction during interpolation
    // also required for per-vertex lighting and SH evaluation
    VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);

    half3 viewDirWS = GetWorldSpaceViewDir(vertexInput.positionWS);
    half3 vertexLight = VertexLighting(vertexInput.positionWS, normalInput.normalWS);
    half fogFactor = ComputeFogFactor(vertexInput.positionCS.z);

    output.uv0 = input.texcoord0;
    //v.2.0.4
#ifdef _IS_ANGELRING_OFF
    //
#elif _IS_ANGELRING_ON
    output.uv1 = input.texcoord1;
#endif

    // already normalized from normal transform to WS.
    output.normalWS = normalInput.normalWS;
    real sign = input.tangentOS.w * GetOddNegativeScale();
    half4 tangentWS = half4(normalInput.tangentWS.xyz, sign);
    output.tangentWS = tangentWS;
    output.bitangentWS = normalInput.bitangentWS;
    OUTPUT_LIGHTMAP_UV(input.lightmapUV, unity_LightmapST, output.lightmapUV);
    OUTPUT_SH(output.normalWS.xyz, output.vertexSH);

    output.fogFactorAndVertexLight = half4(fogFactor, vertexLight);
    output.positionWS =  vertexInput.positionWS;

#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
    output.shadowCoord = GetShadowCoord(vertexInput);
#endif

    output.positionCS = vertexInput.positionCS;

    //v.2.0.7 鏡の中判定（右手座標系か、左手座標系かの判定）o.mirrorFlag = -1 なら鏡の中.
    float3 crossFwd = cross(UNITY_MATRIX_V[0], UNITY_MATRIX_V[1]);
    output.mirrorFlag = dot(crossFwd, UNITY_MATRIX_V[2]) < 0 ? 1 : -1;
    
    return output;
}

// Used in Standard (Physically Based) shader
half4 LitPassFragment(Varyings input) : SV_Target
{
    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

    SurfaceData surfaceData;
    InitializeStandardLitSurfaceData(input.uv0, surfaceData);

    InputData inputData;
    InitializeInputData(input, surfaceData.normalTS, inputData);
    
    input.normalWS = normalize(input.normalWS);
    float3x3 tangentTransform = float3x3( input.tangentWS.xyz, input.bitangentWS, input.normalWS);
    float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - input.positionWS.xyz);
    float2 Set_UV0 = input.uv0;
    //v.2.0.6
    float3 _NormalMap_var = UnpackScaleNormal(tex2D(_NormalMap,TRANSFORM_TEX(Set_UV0, _NormalMap)), _BumpScale);
    float3 normalLocal = _NormalMap_var.rgb;
    float3 normalDirection = normalize(mul( normalLocal, tangentTransform )); // Perturbed normals
    float4 _MainTex_var = tex2D(_MainTex,TRANSFORM_TEX(Set_UV0, _MainTex));
//v.2.0.4
#ifdef _IS_TRANSCLIPPING_OFF
//
#elif _IS_TRANSCLIPPING_ON
    float4 _ClippingMask_var = tex2D(_ClippingMask,TRANSFORM_TEX(Set_UV0, _ClippingMask));
    float Set_MainTexAlpha = _MainTex_var.a;
    float _IsBaseMapAlphaAsClippingMask_var = lerp( _ClippingMask_var.r, Set_MainTexAlpha, _IsBaseMapAlphaAsClippingMask );
    float _Inverse_Clipping_var = lerp( _IsBaseMapAlphaAsClippingMask_var, (1.0 - _IsBaseMapAlphaAsClippingMask_var), _Inverse_Clipping );
    float Set_Clipping = saturate((_Inverse_Clipping_var+_Clipping_Level));
    clip(Set_Clipping - 0.5);
#endif
    
    ToonSurfaceData tsd;
    tsd.input = input;
    tsd.Set_UV0 = Set_UV0;
    tsd.normalDirection = normalDirection;
    tsd._MainTex_var = _MainTex_var;
    tsd.viewDirection = viewDirection;
    #if _IS_TRANSCLIPPING_ON
    tsd._Inverse_Clipping_var = _Inverse_Clipping_var;
    #endif

    
    float4 finalRGBA = GetMainLightColor(tsd,tangentTransform);
    #if defined(_ADDITIONAL_LIGHTS)
    half4 shadowMask = CalculateShadowMask(inputData);
    AmbientOcclusionFactor aoFactor = CreateAmbientOcclusionFactor(inputData, surfaceData);
    uint pixelLightCount = GetAdditionalLightsCount();

    #if USE_CLUSTERED_LIGHTING
        for (uint lightIndex = 0; lightIndex < min(_AdditionalLightsDirectionalCount, MAX_VISIBLE_LIGHTS); lightIndex++)
        {
            Light light = GetAdditionalLight(lightIndex, inputData, shadowMask, aoFactor);
            float4 additionLight = GetAdditionLightColor(tsd,light);
            finalRGBA = float4((finalRGBA.xyz * 1 + additionLight.xyz * 1),(finalRGBA.a * 1 + additionLight.z * 1)  );
        }
    #endif

    LIGHT_LOOP_BEGIN(pixelLightCount)
        Light light = GetAdditionalLight(lightIndex, inputData, shadowMask, aoFactor);
        float4 additionLight = GetAdditionLightColor(tsd,light);
        finalRGBA = float4((finalRGBA.xyz * 1 + additionLight.xyz * 1),(finalRGBA.a * 1 + additionLight.z * 1) );
    LIGHT_LOOP_END
    #endif
    
//-----------------------
    finalRGBA.rgb = MixFog(finalRGBA.rgb, inputData.fogCoord);
    finalRGBA.a = OutputAlpha(finalRGBA.a, _Surface);

    return finalRGBA;
}

struct VertexInput {
    float4 vertex : POSITION;
    float3 normal : NORMAL;
    float4 tangent : TANGENT;
    float2 texcoord0 : TEXCOORD0;
    float2 lightmapUV   : TEXCOORD1;
//v.2.0.4
#ifdef _IS_ANGELRING_OFF
//
#elif _IS_ANGELRING_ON
    float2 texcoord1 : TEXCOORD2;
#endif
    // v.2.0.9
    UNITY_VERTEX_INPUT_INSTANCE_ID 
};
struct VertexOutput {
    float4 pos : SV_POSITION;
    float2 uv0 : TEXCOORD0;
//v.2.0.4
#ifdef _IS_ANGELRING_OFF
    float4 posWorld : TEXCOORD1;
    float3 normalDir : TEXCOORD2;
    float3 tangentDir : TEXCOORD3;
    float3 bitangentDir : TEXCOORD4;
    //v.2.0.7
    float mirrorFlag : TEXCOORD5;
    float4 shadowCoord              : TEXCOORD6;
    DECLARE_LIGHTMAP_OR_SH(lightmapUV, vertexSH, 7);
    half4 fogFactorAndVertexLight   : TEXCOORD8; // x: fogFactor, yzw: vertex light
    //
#elif _IS_ANGELRING_ON
    float2 uv1 : TEXCOORD1;
    float4 posWorld : TEXCOORD2;
    float3 normalDir : TEXCOORD3;
    float3 tangentDir : TEXCOORD4;
    float3 bitangentDir : TEXCOORD5;
    //v.2.0.7
    float mirrorFlag : TEXCOORD6;
    float4 shadowCoord              : TEXCOORD7;
    DECLARE_LIGHTMAP_OR_SH(lightmapUV, vertexSH, 8);
    half4 fogFactorAndVertexLight   : TEXCOORD9;
    //
#endif
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
//v.2.0.4
#ifdef _IS_ANGELRING_OFF
//
#elif _IS_ANGELRING_ON
    o.uv1 = v.texcoord1;
#endif
    o.normalDir = TransformObjectToWorldNormal(v.normal);//UnityObjectToWorldNormal(v.normal);
    o.tangentDir = normalize( mul( unity_ObjectToWorld, float4( v.tangent.xyz, 0.0 ) ).xyz );
    o.bitangentDir = normalize(cross(o.normalDir, o.tangentDir) * v.tangent.w);
    o.posWorld = mul(unity_ObjectToWorld, v.vertex);
    //float3 lightColor = GetMainLight();
    o.pos = TransformObjectToHClip(v.vertex);//UnityObjectToClipPos( v.vertex );
    //v.2.0.7 鏡の中判定（右手座標系か、左手座標系かの判定）o.mirrorFlag = -1 なら鏡の中.
    float3 crossFwd = cross(UNITY_MATRIX_V[0], UNITY_MATRIX_V[1]);
    o.mirrorFlag = dot(crossFwd, UNITY_MATRIX_V[2]) < 0 ? 1 : -1;
    //
    // UNITY_TRANSFER_FOG(o,o.pos);
    // TRANSFER_VERTEX_TO_FRAGMENT(o);
    OUTPUT_LIGHTMAP_UV(v.lightmapUV, unity_LightmapST, o.lightmapUV);
    OUTPUT_SH(o.normalDir.xyz, o.vertexSH);
    VertexPositionInputs vertexInput = GetVertexPositionInputs(v.vertex.xyz);
    VertexNormalInputs normalInput = GetVertexNormalInputs(v.normal, v.tangent);
    half fogFactor = ComputeFogFactor(vertexInput.positionCS.z);
    half3 vertexLight = VertexLighting(vertexInput.positionWS, normalInput.normalWS);
    o.fogFactorAndVertexLight = half4(fogFactor, vertexLight);
    o.shadowCoord = TransformWorldToShadowCoord(o.posWorld);
    return o;
}
float4 frag(VertexOutput i, half facing : VFACE) : SV_TARGET {
    UNITY_SETUP_INSTANCE_ID(i);
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);

    i.normalDir = normalize(i.normalDir);
    float3x3 tangentTransform = float3x3( i.tangentDir, i.bitangentDir, i.normalDir);
    float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
    float2 Set_UV0 = i.uv0;
    //v.2.0.6
    float3 _NormalMap_var = UnpackScaleNormal(tex2D(_NormalMap,TRANSFORM_TEX(Set_UV0, _NormalMap)), _BumpScale);
    float3 normalLocal = _NormalMap_var.rgb;
    float3 normalDirection = normalize(mul( normalLocal, tangentTransform )); // Perturbed normals
    float4 _MainTex_var = tex2D(_MainTex,TRANSFORM_TEX(Set_UV0, _MainTex));
//v.2.0.4
#ifdef _IS_TRANSCLIPPING_OFF
//
#elif _IS_TRANSCLIPPING_ON
    float4 _ClippingMask_var = tex2D(_ClippingMask,TRANSFORM_TEX(Set_UV0, _ClippingMask));
    float Set_MainTexAlpha = _MainTex_var.a;
    float _IsBaseMapAlphaAsClippingMask_var = lerp( _ClippingMask_var.r, Set_MainTexAlpha, _IsBaseMapAlphaAsClippingMask );
    float _Inverse_Clipping_var = lerp( _IsBaseMapAlphaAsClippingMask_var, (1.0 - _IsBaseMapAlphaAsClippingMask_var), _Inverse_Clipping );
    float Set_Clipping = saturate((_Inverse_Clipping_var+_Clipping_Level));
    clip(Set_Clipping - 0.5);
#endif

    
#if defined(SHADOWS_SHADOWMASK) && defined(LIGHTMAP_ON)
    half4 shadowMask = SAMPLE_SHADOWMASK(i.lightmapUV);
#elif !defined (LIGHTMAP_ON)
    half4 shadowMask = unity_ProbesOcclusion;
#else
    half4 shadowMask = half4(1, 1, 1, 1);
#endif
    Light mainLight = GetMainLight(i.shadowCoord, i.posWorld, shadowMask);
    half3 attenuatedLightColor = mainLight.color * (mainLight.distanceAttenuation * mainLight.shadowAttenuation);
//v.2.0.4
#ifdef _IS_PASS_FWDBASE
    float3 defaultLightDirection = normalize(unity_MatrixV[2].xyz + unity_MatrixV[1].xyz);
    //v.2.0.5
    float3 defaultLightColor = saturate(max(half3(0.05,0.05,0.05)*_Unlit_Intensity,max(SampleSH(half4(0.0, 0.0, 0.0, 1.0)),SampleSH(half4(0.0, -1.0, 0.0, 1.0)).rgb)*_Unlit_Intensity));
    float3 customLightDirection = normalize(mul( unity_ObjectToWorld, float4(((float3(1.0,0.0,0.0)*_Offset_X_Axis_BLD*10)+(float3(0.0,1.0,0.0)*_Offset_Y_Axis_BLD*10)+(float3(0.0,0.0,-1.0)*lerp(-1.0,1.0,_Inverse_Z_Axis_BLD))),0)).xyz);

    float3 lightDirection = normalize(lerp(defaultLightDirection,_MainLightPosition.xyz,any(_MainLightPosition.xyz)));
    lightDirection = lerp(lightDirection, customLightDirection, _Is_BLD);
    //v.2.0.5:
    float3 lightColor = lerp(max(defaultLightColor,_MainLightColor.rgb),max(defaultLightColor,saturate(_MainLightColor.rgb)),_Is_Filter_LightColor);
#elif _IS_PASS_FWDDELTA
    float3 lightDirection = normalize(lerp(_MainLightPosition.xyz, _MainLightPosition.xyz - i.posWorld.xyz,_MainLightPosition.w));
    //v.2.0.5: 
    float3 addPassLightColor = (0.5*dot(lerp( i.normalDir, normalDirection, _Is_NormalMapToBase ), lightDirection)+0.5) * _MainLightColor.rgb * attenuatedLightColor;
    float pureIntencity = max(0.001,(0.299*_MainLightColor.r + 0.587*_MainLightColor.g + 0.114*_MainLightColor.b));
    float3 lightColor = max(0, lerp(addPassLightColor, lerp(0,min(addPassLightColor,addPassLightColor/pureIntencity),_MainLightPosition.w),_Is_Filter_LightColor));
#else
    float3 lightDirection = 1;
#endif
////// Lighting:
    float3 halfDirection = normalize(viewDirection+lightDirection);
    //v.2.0.5
    _Color = _BaseColor;

#ifdef _IS_PASS_FWDBASE
    float3 Set_LightColor = lightColor.rgb;
    float3 Set_BaseColor = lerp( (_MainTex_var.rgb*_BaseColor.rgb), ((_MainTex_var.rgb*_BaseColor.rgb)*Set_LightColor), _Is_LightColor_Base );
    //v.2.0.5
    float4 _1st_ShadeMap_var = lerp(tex2D(_1st_ShadeMap,TRANSFORM_TEX(Set_UV0, _1st_ShadeMap)),_MainTex_var,_Use_BaseAs1st);
    float3 _Is_LightColor_1st_Shade_var = lerp( (_1st_ShadeMap_var.rgb*_1st_ShadeColor.rgb), ((_1st_ShadeMap_var.rgb*_1st_ShadeColor.rgb)*Set_LightColor), _Is_LightColor_1st_Shade );
    float _HalfLambert_var = 0.5*dot(lerp( i.normalDir, normalDirection, _Is_NormalMapToBase ),lightDirection)+0.5; // Half Lambert
    //float4 _ShadingGradeMap_var = tex2D(_ShadingGradeMap,TRANSFORM_TEX(Set_UV0, _ShadingGradeMap));
    //v.2.0.6
    float4 _ShadingGradeMap_var = tex2Dlod(_ShadingGradeMap,float4(TRANSFORM_TEX(Set_UV0, _ShadingGradeMap),0.0,_BlurLevelSGM));
    //v.2.0.6
    //Minmimum value is same as the Minimum Feather's value with the Minimum Step's value as threshold.
    float _SystemShadowsLevel_var = (attenuatedLightColor*0.5)+0.5+_Tweak_SystemShadowsLevel > 0.001 ? (attenuatedLightColor*0.5)+0.5+_Tweak_SystemShadowsLevel : 0.0001;
    float _ShadingGradeMapLevel_var = _ShadingGradeMap_var.r < 0.95 ? _ShadingGradeMap_var.r+_Tweak_ShadingGradeMapLevel : 1;
    float Set_ShadingGrade = saturate(_ShadingGradeMapLevel_var)*lerp( _HalfLambert_var, (_HalfLambert_var*saturate(_SystemShadowsLevel_var)), _Set_SystemShadowsToBase );
    //
    float Set_FinalShadowMask = saturate((1.0 + ( (Set_ShadingGrade - (_1st_ShadeColor_Step-_1st_ShadeColor_Feather)) * (0.0 - 1.0) ) / (_1st_ShadeColor_Step - (_1st_ShadeColor_Step-_1st_ShadeColor_Feather)))); // Base and 1st Shade Mask
    float3 _BaseColor_var = lerp(Set_BaseColor,_Is_LightColor_1st_Shade_var,Set_FinalShadowMask);
    //v.2.0.5
    float4 _2nd_ShadeMap_var = lerp(tex2D(_2nd_ShadeMap,TRANSFORM_TEX(Set_UV0, _2nd_ShadeMap)),_1st_ShadeMap_var,_Use_1stAs2nd);
    float Set_ShadeShadowMask = saturate((1.0 + ( (Set_ShadingGrade - (_2nd_ShadeColor_Step-_2nd_ShadeColor_Feather)) * (0.0 - 1.0) ) / (_2nd_ShadeColor_Step - (_2nd_ShadeColor_Step-_2nd_ShadeColor_Feather)))); // 1st and 2nd Shades Mask
    //Composition: 3 Basic Colors as Set_FinalBaseColor
    float3 Set_FinalBaseColor = lerp(_BaseColor_var,lerp(_Is_LightColor_1st_Shade_var,lerp( (_2nd_ShadeMap_var.rgb*_2nd_ShadeColor.rgb), ((_2nd_ShadeMap_var.rgb*_2nd_ShadeColor.rgb)*Set_LightColor), _Is_LightColor_2nd_Shade ),Set_ShadeShadowMask),Set_FinalShadowMask);
    float4 _Set_HighColorMask_var = tex2D(_Set_HighColorMask,TRANSFORM_TEX(Set_UV0, _Set_HighColorMask));
    float _Specular_var = 0.5*dot(halfDirection,lerp( i.normalDir, normalDirection, _Is_NormalMapToHighColor ))+0.5; // Specular
    float _TweakHighColorMask_var = (saturate((_Set_HighColorMask_var.g+_Tweak_HighColorMaskLevel))*lerp( (1.0 - step(_Specular_var,(1.0 - pow(_HighColor_Power,5)))), pow(_Specular_var,exp2(lerp(11,1,_HighColor_Power))), _Is_SpecularToHighColor ));
    float4 _HighColor_Tex_var = tex2D(_HighColor_Tex,TRANSFORM_TEX(Set_UV0, _HighColor_Tex));
    float3 _HighColor_var = (lerp( (_HighColor_Tex_var.rgb*_HighColor.rgb), ((_HighColor_Tex_var.rgb*_HighColor.rgb)*Set_LightColor), _Is_LightColor_HighColor )*_TweakHighColorMask_var);
    //Composition: 3 Basic Colors and HighColor as Set_HighColor
    float3 Set_HighColor = (lerp( saturate((Set_FinalBaseColor-_TweakHighColorMask_var)), Set_FinalBaseColor, lerp(_Is_BlendAddToHiColor,1.0,_Is_SpecularToHighColor) )+lerp( _HighColor_var, (_HighColor_var*((1.0 - Set_FinalShadowMask)+(Set_FinalShadowMask*_TweakHighColorOnShadow))), _Is_UseTweakHighColorOnShadow ));
    float4 _Set_RimLightMask_var = tex2D(_Set_RimLightMask,TRANSFORM_TEX(Set_UV0, _Set_RimLightMask));
    float3 _Is_LightColor_RimLight_var = lerp( _RimLightColor.rgb, (_RimLightColor.rgb*Set_LightColor), _Is_LightColor_RimLight );
    float _RimArea_var = (1.0 - dot(lerp( i.normalDir, normalDirection, _Is_NormalMapToRimLight ),viewDirection));
    float _RimLightPower_var = pow(_RimArea_var,exp2(lerp(3,0,_RimLight_Power)));
    float _Rimlight_InsideMask_var = saturate(lerp( (0.0 + ( (_RimLightPower_var - _RimLight_InsideMask) * (1.0 - 0.0) ) / (1.0 - _RimLight_InsideMask)), step(_RimLight_InsideMask,_RimLightPower_var), _RimLight_FeatherOff ));
    float _VertHalfLambert_var = 0.5*dot(i.normalDir,lightDirection)+0.5;
    float3 _LightDirection_MaskOn_var = lerp( (_Is_LightColor_RimLight_var*_Rimlight_InsideMask_var), (_Is_LightColor_RimLight_var*saturate((_Rimlight_InsideMask_var-((1.0 - _VertHalfLambert_var)+_Tweak_LightDirection_MaskLevel)))), _LightDirection_MaskOn );
    float _ApRimLightPower_var = pow(_RimArea_var,exp2(lerp(3,0,_Ap_RimLight_Power)));
    float3 Set_RimLight = (saturate((_Set_RimLightMask_var.g+_Tweak_RimLightMaskLevel))*lerp( _LightDirection_MaskOn_var, (_LightDirection_MaskOn_var+(lerp( _Ap_RimLightColor.rgb, (_Ap_RimLightColor.rgb*Set_LightColor), _Is_LightColor_Ap_RimLight )*saturate((lerp( (0.0 + ( (_ApRimLightPower_var - _RimLight_InsideMask) * (1.0 - 0.0) ) / (1.0 - _RimLight_InsideMask)), step(_RimLight_InsideMask,_ApRimLightPower_var), _Ap_RimLight_FeatherOff )-(saturate(_VertHalfLambert_var)+_Tweak_LightDirection_MaskLevel))))), _Add_Antipodean_RimLight ));
    //Composition: HighColor and RimLight as _RimLight_var
    float3 _RimLight_var = lerp( Set_HighColor, (Set_HighColor+Set_RimLight), _RimLight );
    //Matcap
    //v.2.0.6 : CameraRolling Stabilizer
    //鏡スクリプト判定：_sign_Mirror = -1 なら、鏡の中と判定.
    //v.2.0.7
    half _sign_Mirror = i.mirrorFlag;
    //
    float3 _Camera_Right = unity_MatrixV[0].xyz;
    float3 _Camera_Front = unity_MatrixV[2].xyz;
    float3 _Up_Unit = float3(0, 1, 0);
    float3 _Right_Axis = cross(_Camera_Front, _Up_Unit);
    //鏡の中なら反転.
    if(_sign_Mirror < 0){
        _Right_Axis = -1 * _Right_Axis;
        _Rotate_MatCapUV = -1 * _Rotate_MatCapUV;
    }else{
        _Right_Axis = _Right_Axis;
    }
    float _Camera_Right_Magnitude = sqrt(_Camera_Right.x*_Camera_Right.x + _Camera_Right.y*_Camera_Right.y + _Camera_Right.z*_Camera_Right.z);
    float _Right_Axis_Magnitude = sqrt(_Right_Axis.x*_Right_Axis.x + _Right_Axis.y*_Right_Axis.y + _Right_Axis.z*_Right_Axis.z);
    float _Camera_Roll_Cos = dot(_Right_Axis, _Camera_Right) / (_Right_Axis_Magnitude * _Camera_Right_Magnitude);
    float _Camera_Roll = acos(clamp(_Camera_Roll_Cos, -1, 1));
    half _Camera_Dir = _Camera_Right.y < 0 ? -1 : 1;
    float _Rot_MatCapUV_var_ang = (_Rotate_MatCapUV*3.141592654) - _Camera_Dir*_Camera_Roll*_CameraRolling_Stabilizer;
    //v.2.0.7
    float2 _Rot_MatCapNmUV_var = RotateUV(Set_UV0, (_Rotate_NormalMapForMatCapUV*3.141592654), float2(0.5, 0.5), 1.0);
    //V.2.0.6
    float3 _NormalMapForMatCap_var = UnpackScaleNormal(tex2D(_NormalMapForMatCap,TRANSFORM_TEX(_Rot_MatCapNmUV_var, _NormalMapForMatCap)),_BumpScaleMatcap);
    //v.2.0.5: MatCap with camera skew correction
    float3 viewNormal = (mul(unity_MatrixV, float4(lerp( i.normalDir, mul( _NormalMapForMatCap_var.rgb, tangentTransform ).rgb, _Is_NormalMapForMatCap ),0))).rgb;
    float3 NormalBlend_MatcapUV_Detail = viewNormal.rgb * float3(-1,-1,1);
    float3 NormalBlend_MatcapUV_Base = (mul( unity_MatrixV, float4(viewDirection,0) ).rgb*float3(-1,-1,1)) + float3(0,0,1);
    float3 noSknewViewNormal = NormalBlend_MatcapUV_Base*dot(NormalBlend_MatcapUV_Base, NormalBlend_MatcapUV_Detail)/NormalBlend_MatcapUV_Base.b - NormalBlend_MatcapUV_Detail;                
    float2 _ViewNormalAsMatCapUV = (lerp(noSknewViewNormal,viewNormal,_Is_Ortho).rg*0.5)+0.5;
    //
    //v.2.0.7
    float2 _Rot_MatCapUV_var = RotateUV((0.0 + ((_ViewNormalAsMatCapUV - (0.0+_Tweak_MatCapUV)) * (1.0 - 0.0) ) / ((1.0-_Tweak_MatCapUV) - (0.0+_Tweak_MatCapUV))), _Rot_MatCapUV_var_ang, float2(0.5, 0.5), 1.0);
    //鏡の中ならUV左右反転.
    if(_sign_Mirror < 0){
        _Rot_MatCapUV_var.x = 1-_Rot_MatCapUV_var.x;
    }else{
        _Rot_MatCapUV_var = _Rot_MatCapUV_var;
    }
    //v.2.0.6 : LOD of Matcap
    float4 _MatCap_Sampler_var = tex2Dlod(_MatCap_Sampler,float4(TRANSFORM_TEX(_Rot_MatCapUV_var, _MatCap_Sampler),0.0,_BlurLevelMatcap));
    //                
    //MatcapMask
    float4 _Set_MatcapMask_var = tex2D(_Set_MatcapMask,TRANSFORM_TEX(Set_UV0, _Set_MatcapMask));
    float _Tweak_MatcapMaskLevel_var = saturate(lerp(_Set_MatcapMask_var.g, (1.0 - _Set_MatcapMask_var.g), _Inverse_MatcapMask) + _Tweak_MatcapMaskLevel);
    float3 _Is_LightColor_MatCap_var = lerp( (_MatCap_Sampler_var.rgb*_MatCapColor.rgb), ((_MatCap_Sampler_var.rgb*_MatCapColor.rgb)*Set_LightColor), _Is_LightColor_MatCap );
    //v.2.0.6 : ShadowMask on Matcap in Blend mode : multiply
    float3 Set_MatCap = lerp( _Is_LightColor_MatCap_var, (_Is_LightColor_MatCap_var*((1.0 - Set_FinalShadowMask)+(Set_FinalShadowMask*_TweakMatCapOnShadow)) + lerp(Set_HighColor*Set_FinalShadowMask*(1.0-_TweakMatCapOnShadow), float3(0.0, 0.0, 0.0), _Is_BlendAddToMatCap)), _Is_UseTweakMatCapOnShadow );
    //
    //v.2.0.6
    //Composition: RimLight and MatCap as finalColor
    //Broke down finalColor composition
    float3 matCapColorOnAddMode = _RimLight_var+Set_MatCap*_Tweak_MatcapMaskLevel_var;
    float _Tweak_MatcapMaskLevel_var_MultiplyMode = _Tweak_MatcapMaskLevel_var * lerp (1, (1 - (Set_FinalShadowMask)*(1 - _TweakMatCapOnShadow)), _Is_UseTweakMatCapOnShadow);
    float3 matCapColorOnMultiplyMode = Set_HighColor*(1-_Tweak_MatcapMaskLevel_var_MultiplyMode) + Set_HighColor*Set_MatCap*_Tweak_MatcapMaskLevel_var_MultiplyMode + lerp(float3(0,0,0),Set_RimLight,_RimLight);
    float3 matCapColorFinal = lerp(matCapColorOnMultiplyMode, matCapColorOnAddMode, _Is_BlendAddToMatCap);
//v.2.0.4
#ifdef _IS_ANGELRING_OFF
    float3 finalColor = lerp(_RimLight_var, matCapColorFinal, _MatCap);// Final Composition before Emissive
    //
#elif _IS_ANGELRING_ON
    float3 finalColor = lerp(_RimLight_var, matCapColorFinal, _MatCap);// Final Composition before AR
    //v.2.0.7 AR Camera Rolling Stabilizer
    float3 _AR_OffsetU_var = lerp(mul(UNITY_MATRIX_V, float4(i.normalDir,0)).xyz,float3(0,0,1),_AR_OffsetU);
    float2 AR_VN = _AR_OffsetU_var.xy*0.5 + float2(0.5,0.5);
    float2 AR_VN_Rotate = RotateUV(AR_VN, -(_Camera_Dir*_Camera_Roll), float2(0.5,0.5), 1.0);
    float2 _AR_OffsetV_var = float2(AR_VN_Rotate.x, lerp(i.uv1.y, AR_VN_Rotate.y, _AR_OffsetV));
    float4 _AngelRing_Sampler_var = tex2D(_AngelRing_Sampler,TRANSFORM_TEX(_AR_OffsetV_var, _AngelRing_Sampler));
    float3 _Is_LightColor_AR_var = lerp( (_AngelRing_Sampler_var.rgb*_AngelRing_Color.rgb), ((_AngelRing_Sampler_var.rgb*_AngelRing_Color.rgb)*Set_LightColor), _Is_LightColor_AR );
    float3 Set_AngelRing = _Is_LightColor_AR_var;
    float Set_ARtexAlpha = _AngelRing_Sampler_var.a;
    float3 Set_AngelRingWithAlpha = (_Is_LightColor_AR_var*_AngelRing_Sampler_var.a);
    //Composition: MatCap and AngelRing as finalColor
    finalColor = lerp(finalColor, lerp((finalColor + Set_AngelRing), ((finalColor*(1.0 - Set_ARtexAlpha))+Set_AngelRingWithAlpha), _ARSampler_AlphaOn ), _AngelRing );// Final Composition before Emissive
#endif
//v.2.0.7
#ifdef _EMISSIVE_SIMPLE
    float4 _Emissive_Tex_var = tex2D(_Emissive_Tex,TRANSFORM_TEX(Set_UV0, _Emissive_Tex));
    float emissiveMask = _Emissive_Tex_var.a;
    emissive = _Emissive_Tex_var.rgb * _Emissive_Color.rgb * emissiveMask;
#elif _EMISSIVE_ANIMATION
    //v.2.0.7 Calculation View Coord UV for Scroll 
    float3 viewNormal_Emissive = (mul(UNITY_MATRIX_V, float4(i.normalDir,0))).xyz;
    float3 NormalBlend_Emissive_Detail = viewNormal_Emissive * float3(-1,-1,1);
    float3 NormalBlend_Emissive_Base = (mul( UNITY_MATRIX_V, float4(viewDirection,0)).xyz*float3(-1,-1,1)) + float3(0,0,1);
    float3 noSknewViewNormal_Emissive = NormalBlend_Emissive_Base*dot(NormalBlend_Emissive_Base, NormalBlend_Emissive_Detail)/NormalBlend_Emissive_Base.z - NormalBlend_Emissive_Detail;
    float2 _ViewNormalAsEmissiveUV = noSknewViewNormal_Emissive.xy*0.5+0.5;
    float2 _ViewCoord_UV = RotateUV(_ViewNormalAsEmissiveUV, -(_Camera_Dir*_Camera_Roll), float2(0.5,0.5), 1.0);
    //鏡の中ならUV左右反転.
    if(_sign_Mirror < 0){
        _ViewCoord_UV.x = 1-_ViewCoord_UV.x;
    }else{
        _ViewCoord_UV = _ViewCoord_UV;
    }
    float2 emissive_uv = lerp(i.uv0, _ViewCoord_UV, _Is_ViewCoord_Scroll);
    //
    float4 _time_var = _Time;
    float _base_Speed_var = (_time_var.g*_Base_Speed);
    float _Is_PingPong_Base_var = lerp(_base_Speed_var, sin(_base_Speed_var), _Is_PingPong_Base );
    float2 scrolledUV = emissive_uv + float2(_Scroll_EmissiveU, _Scroll_EmissiveV)*_Is_PingPong_Base_var;
    float rotateVelocity = _Rotate_EmissiveUV*3.141592654;
    float2 _rotate_EmissiveUV_var = RotateUV(scrolledUV, rotateVelocity, float2(0.5, 0.5), _Is_PingPong_Base_var);
    float4 _Emissive_Tex_var = tex2D(_Emissive_Tex,TRANSFORM_TEX(Set_UV0, _Emissive_Tex));
    float emissiveMask = _Emissive_Tex_var.a;
    _Emissive_Tex_var = tex2D(_Emissive_Tex,TRANSFORM_TEX(_rotate_EmissiveUV_var, _Emissive_Tex));
    float _colorShift_Speed_var = 1.0 - cos(_time_var.g*_ColorShift_Speed);
    float viewShift_var = smoothstep( 0.0, 1.0, max(0,dot(normalDirection,viewDirection)));
    float4 colorShift_Color = lerp(_Emissive_Color, lerp(_Emissive_Color, _ColorShift, _colorShift_Speed_var), _Is_ColorShift);
    float4 viewShift_Color = lerp(_ViewShift, colorShift_Color, viewShift_var);
    float4 emissive_Color = lerp(colorShift_Color, viewShift_Color, _Is_ViewShift);
    emissive = emissive_Color.rgb * _Emissive_Tex_var.rgb * emissiveMask;
#endif
//
    //v.2.0.6: GI_Intensity with Intensity Multiplier Filter
    float3 envLightColor = DecodeLightProbe(normalDirection) < float3(1,1,1) ? DecodeLightProbe(normalDirection) : float3(1,1,1);
    float envLightIntensity = 0.299*envLightColor.r + 0.587*envLightColor.g + 0.114*envLightColor.b <1 ? (0.299*envLightColor.r + 0.587*envLightColor.g + 0.114*envLightColor.b) : 1;
    //Final Composition
    finalColor =  saturate(finalColor) + (envLightColor*envLightIntensity*_GI_Intensity*smoothstep(1,0,envLightIntensity/2)) + emissive;


#elif _IS_PASS_FWDDELTA
    //v.2.0.4.4
    _1st_ShadeColor_Step = saturate(_1st_ShadeColor_Step + _StepOffset);
    _2nd_ShadeColor_Step = saturate(_2nd_ShadeColor_Step + _StepOffset);
    //
    //v.2.0.5: If Added lights is directional, set 0 as _LightIntensity
    float _LightIntensity = lerp(0,(0.299*_MainLightColor.r + 0.587*_MainLightColor.g + 0.114*_MainLightColor.b)*attenuatedLightColor,_MainLightPosition.w) ;
    //v.2.0.5: Filtering the high intensity zone of PointLights
    float3 Set_LightColor = lerp(lightColor,lerp(lightColor,min(lightColor,_MainLightColor.rgb*attenuatedLightColor*_1st_ShadeColor_Step),_MainLightPosition.w),_Is_Filter_HiCutPointLightColor);
    //
    float3 Set_BaseColor = lerp( (_MainTex_var.rgb*_BaseColor.rgb*_LightIntensity), ((_MainTex_var.rgb*_BaseColor.rgb)*Set_LightColor), _Is_LightColor_Base );
    //v.2.0.5
    float4 _1st_ShadeMap_var = lerp(tex2D(_1st_ShadeMap,TRANSFORM_TEX(Set_UV0, _1st_ShadeMap)),_MainTex_var,_Use_BaseAs1st);
    float3 _Is_LightColor_1st_Shade_var = lerp( (_1st_ShadeMap_var.rgb*_1st_ShadeColor.rgb*_LightIntensity), ((_1st_ShadeMap_var.rgb*_1st_ShadeColor.rgb)*Set_LightColor), _Is_LightColor_1st_Shade );
    float _HalfLambert_var = 0.5*dot(lerp( i.normalDir, normalDirection, _Is_NormalMapToBase ),lightDirection)+0.5; // Half Lambert
    //v.2.0.6
    float4 _ShadingGradeMap_var = tex2Dlod(_ShadingGradeMap,float4(TRANSFORM_TEX(Set_UV0, _ShadingGradeMap),0.0,_BlurLevelSGM));
    //v.2.0.6
    float _ShadingGradeMapLevel_var = _ShadingGradeMap_var.r < 0.95 ? _ShadingGradeMap_var.r+_Tweak_ShadingGradeMapLevel : 1;
    float Set_ShadingGrade = saturate(_ShadingGradeMapLevel_var)*lerp( _HalfLambert_var, (_HalfLambert_var*saturate(1.0+_Tweak_SystemShadowsLevel)), _Set_SystemShadowsToBase );
    //
    float Set_FinalShadowMask = saturate((1.0 + ( (Set_ShadingGrade - (_1st_ShadeColor_Step-_1st_ShadeColor_Feather)) * (0.0 - 1.0) ) / (_1st_ShadeColor_Step - (_1st_ShadeColor_Step-_1st_ShadeColor_Feather)))); // Base and 1st Shade Mask
    float3 _BaseColor_var = lerp(Set_BaseColor,_Is_LightColor_1st_Shade_var,Set_FinalShadowMask);
    //v.2.0.5
    float4 _2nd_ShadeMap_var = lerp(tex2D(_2nd_ShadeMap,TRANSFORM_TEX(Set_UV0, _2nd_ShadeMap)),_1st_ShadeMap_var,_Use_1stAs2nd);
    float Set_ShadeShadowMask = saturate((1.0 + ( (Set_ShadingGrade - (_2nd_ShadeColor_Step-_2nd_ShadeColor_Feather)) * (0.0 - 1.0) ) / (_2nd_ShadeColor_Step - (_2nd_ShadeColor_Step-_2nd_ShadeColor_Feather)))); // 1st and 2nd Shades Mask
    //Composition: 3 Basic Colors as finalColor
    float3 finalColor = lerp(_BaseColor_var,lerp(_Is_LightColor_1st_Shade_var,lerp( (_2nd_ShadeMap_var.rgb*_2nd_ShadeColor.rgb*_LightIntensity), ((_2nd_ShadeMap_var.rgb*_2nd_ShadeColor.rgb)*Set_LightColor), _Is_LightColor_2nd_Shade ),Set_ShadeShadowMask),Set_FinalShadowMask);

    //v.2.0.6: Add HighColor if _Is_Filter_HiCutPointLightColor is False
    float4 _Set_HighColorMask_var = tex2D(_Set_HighColorMask,TRANSFORM_TEX(Set_UV0, _Set_HighColorMask));
    float _Specular_var = 0.5*dot(halfDirection,lerp( i.normalDir, normalDirection, _Is_NormalMapToHighColor ))+0.5; // Specular
    float _TweakHighColorMask_var = (saturate((_Set_HighColorMask_var.g+_Tweak_HighColorMaskLevel))*lerp( (1.0 - step(_Specular_var,(1.0 - pow(_HighColor_Power,5)))), pow(_Specular_var,exp2(lerp(11,1,_HighColor_Power))), _Is_SpecularToHighColor ));
    float4 _HighColor_Tex_var = tex2D(_HighColor_Tex,TRANSFORM_TEX(Set_UV0, _HighColor_Tex));
    float3 _HighColor_var = (lerp( (_HighColor_Tex_var.rgb*_HighColor.rgb), ((_HighColor_Tex_var.rgb*_HighColor.rgb)*Set_LightColor), _Is_LightColor_HighColor )*_TweakHighColorMask_var);
    finalColor = finalColor + lerp(lerp( _HighColor_var, (_HighColor_var*((1.0 - Set_FinalShadowMask)+(Set_FinalShadowMask*_TweakHighColorOnShadow))), _Is_UseTweakHighColorOnShadow ),float3(0,0,0),_Is_Filter_HiCutPointLightColor);
    //

    finalColor = saturate(finalColor);
#else
    float3 finalColor = 1;
#endif


//v.2.0.4
#ifdef _IS_TRANSCLIPPING_OFF
#ifdef _IS_PASS_FWDBASE
	    half4 finalRGBA = half4(finalColor,1);
#elif _IS_PASS_FWDDELTA
	    half4 finalRGBA = half4(finalColor,0);
    #else
        half4 finalRGBA = half4(finalColor,1);
#endif
#elif _IS_TRANSCLIPPING_ON
	    float Set_Opacity = saturate((_Inverse_Clipping_var+_Tweak_transparency));
#ifdef _IS_PASS_FWDBASE
	    half4 finalRGBA = half4(finalColor,Set_Opacity);
#elif _IS_PASS_FWDDELTA
	    half4 finalRGBA = half4(finalColor * Set_Opacity,0);
    #else
        half4 finalRGBA = half4(finalColor,Set_Opacity);
#endif
#endif

    finalColor.rgb = MixFog(finalColor, i.fogFactorAndVertexLight.x);   
    //UNITY_APPLY_FOG(i.fogCoord, finalRGBA);
    return finalRGBA;
}
#endif
