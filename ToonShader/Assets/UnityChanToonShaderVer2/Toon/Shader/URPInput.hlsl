#ifndef URP_INPUT_INCLUDED
#define URP_INPUT_INCLUDED

half3 UnpackScaleNormalRGorAG(half4 packednormal, half bumpScale)
{
    #if defined(UNITY_NO_DXT5nm)
    half3 normal = packednormal.xyz * 2 - 1;
    #if (SHADER_TARGET >= 30)
    // SM2.0: instruction count limitation
    // SM2.0: normal scaler is not supported
    normal.xy *= bumpScale;
    #endif
    return normal;
    #else
    // This do the trick
    packednormal.x *= packednormal.w;

    half3 normal;
    normal.xy = (packednormal.xy * 2 - 1);
    #if (SHADER_TARGET >= 30)
    // SM2.0: instruction count limitation
    // SM2.0: normal scaler is not supported
    normal.xy *= bumpScale;
    #endif
    normal.z = sqrt(1.0 - saturate(dot(normal.xy, normal.xy)));
    return normal;
    #endif
}

half3 UnpackScaleNormal(half4 packednormal, half bumpScale)
{
    return UnpackScaleNormalRGorAG(packednormal, bumpScale);
}

#endif