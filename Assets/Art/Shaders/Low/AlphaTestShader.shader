// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
//透明度测试 AlphaTest 极端的透明效果，要么不透明，要么全透
Shader "Ackerman/AlphaTestShader"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _CutOff ("CutOff", Range(0,1)) = 0.5
    }
    SubShader
    {
        
        Tags{"Queue"="AlphaTest" "IgnoreProjector"="True" "RenderType"="TransparentCutout"}
        Pass{
            Tags { "LightMode"="ForwardBase" }
            CGPROGRAM
                #pragma vertex vert
                #pragma fragment frag
                #include "Lighting.cginc"
                float4 _Color;
                sampler2D _MainTex;
                float4 _MainTex_ST;
                float _CutOff;
                struct a2v{
                    float4 pos : POSITION;
                    float3 normal : NORMAL;
                    float4 uv : TEXCOORD0;
                };
                struct v2f{
                    float4 clipPos : SV_POSITION;
                    float3 worldNormal : TEXCOORD0;
                    float3 worldPos : TEXCOORD1;
                    float2 uv : TEXCOORD2;
                };
                v2f vert(a2v i){
                    v2f o;
                    o.clipPos = UnityObjectToClipPos(i.pos);
                    o.worldNormal =normalize(UnityObjectToWorldNormal(i.normal));
                    o.worldPos = mul(unity_ObjectToWorld,i.pos.xyz).xyz;
                    o.uv=TRANSFORM_TEX(i.uv,_MainTex);
                    return o;
                }
                fixed4 frag(v2f i):SV_TARGET{
                    fixed4 pixel = tex2D(_MainTex,i.uv);
                    //pixel.a=0.9;
                    clip(pixel.a-_CutOff);//当像素值的alpha值减去裁剪值小于0时就不显示该像素点
                  
                    //另一种实现方法
                    // if(pixed.a-_CutOff){
                    //     discard;
                    // }
                    fixed3 albeo = pixel.rgb*_Color.rgb;
                    fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz*albeo;
                    fixed3 lightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
                    fixed3 diffuse = _LightColor0.rgb*albeo*max(0,dot(i.worldNormal,lightDir));
                    return fixed4(ambient+diffuse,1);
                }
            ENDCG
        }
        
    }
    FallBack "Diffuse"
}
