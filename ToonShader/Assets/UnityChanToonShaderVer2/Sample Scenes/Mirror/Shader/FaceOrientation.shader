Shader "URP_Unlit/FaceOrientation"
{
    Properties
    {
        _ColorFront ("Front Color", Color) = (1,0.7,0.7,1)
        _ColorBack ("Back Color", Color) = (0.7,1,0.7,1)
    }
    SubShader
    {
        Tags {
            //"Queue"="AlphaTest-1"   //StencilMask Opaque and _Clipping
            //"RenderType"="TransparentCutout"
            "RenderPipeline" = "UniversalPipeline"
        }
        Pass
        {
            Name "FaceOrientation"
            Tags {
                //"LightMode" = "UniversalForward"
                "LightMode" = "UniversalForward"
            }
            Cull Off // 裏向きのカリングをオフにします

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/API/D3D11.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/SpaceTransforms.hlsl"
            
            float4 vert (float4 vertex : POSITION) : SV_POSITION
            {
                return TransformObjectToHClip(vertex);
            }

            half4 _ColorFront;
            half4 _ColorBack;

            half4 frag (half facing : VFACE) : SV_Target
            {
                // VFACE 入力は正面向きでは負の値、
                // 裏向きでは負の値です。その値によって 
                // 2 色のうちの 1 つを出力します。
                return facing > 0 ? _ColorFront : _ColorBack;
            }
            ENDHLSL
        }
    }
}