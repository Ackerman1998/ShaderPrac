Shader "Ackerman/AlphaBlendShader"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("主贴图", 2D) = "white" {}
        _AlphaScale ("透明度", Range(0,1)) = 0.0
    }
    SubShader
    {
        Tags { "RenderType"="ForwardBase" "Queue"="Transparent"}
        LOD 200
        Pass{
            ZWrite On
            ColorMask 0
        }
        Pass{
            ZWrite Off//关闭深度写入
            Blend SrcAlpha OneMinusSrcAlpha
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Lighting.cginc"
            fixed4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _AlphaScale;
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
                o.worldPos = (mul(unity_ObjectToWorld,i.pos));
                o.worldNormal = normalize(UnityObjectToWorldNormal(i.normal));
                o.uv = i.uv.xy*_MainTex_ST.xy+_MainTex_ST.zw;
                return o;
            }
            fixed4 frag(v2f i): SV_TARGET{
                float4 pixel = tex2D(_MainTex,i.uv);
                fixed3 lightDir = UnityWorldSpaceLightDir(i.worldPos);
                fixed3 albeo = pixel.rgb*_Color.rgb;
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz*albeo;
                fixed3 diffuse = _LightColor0.rgb*albeo*max(0,dot(lightDir,i.worldNormal));
                return fixed4(ambient+diffuse,pixel.a*_AlphaScale);
            }
            ENDCG
        }
        
    }
    FallBack "Diffuse"
}
