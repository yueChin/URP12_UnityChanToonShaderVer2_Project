Shader "URP_Hidden/UnityChan/MirrorReflection"
{
	Properties
	{
		_MainTex ("Base (RGB)", 2D) = "white" {}
		[HideInInspector] _ReflectionTex ("", 2D) = "white" {}
	}
	SubShader
	{
		Tags 
		{ 
			"RenderType"="Opaque" 
			"RenderPipeline" = "UniversalPipeline"
		}
		LOD 100
 
		Pass 
		{
			Name "FaceOrientation"
            Tags {
                //"LightMode" = "UniversalForward"
                "LightMode" = "UniversalForward"
            }
			HLSLPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			//#include "UnityCG.cginc"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/API/D3D11.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/SpaceTransforms.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Macros.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderVariablesFunctions.deprecated.hlsl"

			#define UNITY_PROJ_COORD(a) a
			
			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 refl : TEXCOORD1;
				float4 pos : SV_POSITION;
			};
			
			float4 _MainTex_ST;
			
			v2f vert(float4 pos : POSITION, float2 uv : TEXCOORD0)
			{
				v2f o;
				o.pos = TransformObjectToHClip (pos);
				o.uv = TRANSFORM_TEX(uv, _MainTex);
				o.refl = ComputeScreenPos (o.pos);
				return o;
			}
			sampler2D _MainTex;
			sampler2D _ReflectionTex;
			half4 frag(v2f i) : SV_Target
			{
				half4 wcoord = (i.refl.xyzw/i.refl.w);
				half4 tex = tex2D(_MainTex, i.uv);
				half4 refl = tex2Dproj(_ReflectionTex, UNITY_PROJ_COORD(wcoord));
				return tex * refl;
			}
			ENDHLSL
	    }
	}
}