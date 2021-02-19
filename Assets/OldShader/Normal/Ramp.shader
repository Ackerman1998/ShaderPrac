// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Custom/Ramp"
{
    Properties{
        _Color("Color Tint",Color)=(1,1,1,1)
        _BampMap("Bamp Map",2D)="white"{}
        _Specular("Specular",Color)=(1,1,1,1)
        _Gloss("Gloss",Range(8,256))=8
    }
    SubShader{
        Pass{
            Tags{ "Queue"="AlphaTest" "LightMode"="ForwardBase"    "RenderType"="TransparentCutout"}
            CGPROGRAM
                #pragma vertex vrt
                #pragma fragment frag
                #include "Lighting.cginc"
                fixed4 _Color;
                sampler2D _BampMap;
                float4 _BampMap_ST;
                fixed4 _Specular;
                float _Gloss;
                struct a2v{
                    float4 vertex : POSITION;
                    float3 normal : NORMAL;
                    float2 uv : TEXCOORD0;
                };
                struct v2f{
                    float4 pos : SV_POSITION;
                    float2 uv : TEXCOORD0;
                    float3 worldNormal : TEXCOORD1;
                    float3 worldPos : TEXCOORD2;
                };
                v2f vrt(a2v i){
                    v2f o;
                    o.pos=UnityObjectToClipPos(i.vertex); 
                    o.uv=TRANSFORM_TEX(i.uv,_BampMap);
                    o.worldNormal=UnityObjectToWorldNormal(i.normal);
                    o.worldPos=mul(unity_ObjectToWorld,i.vertex).xyz;
                    return o;
                }
                fixed4 frag(v2f i) : SV_TARGET{
                    fixed3 worldNormal = normalize(i.worldNormal);
                    fixed3 worldLightDir= normalize(UnityWorldSpaceLightDir(i.worldPos));
                    //计算环境光照
                    fixed3 ambient= UNITY_LIGHTMODEL_AMBIENT.xyz;
                    //计算半兰伯特
                    fixed halfLambert=0.5*dot(worldNormal,worldLightDir)+0.5;
                    fixed3 diffuseColor=tex2D(_BampMap,fixed2(halfLambert,halfLambert)).rgb*_Color.rgb;
                    //计算漫反射
                    fixed3 diffuse=diffuseColor*_LightColor0.rgb;
                    fixed3 viewDir=normalize(UnityWorldSpaceViewDir(i.worldPos));
                    fixed3 halfDir=normalize(worldLightDir+viewDir);
                    //计算高光
                    fixed3 specular=_LightColor0.rgb*_Specular.rgb*pow(max(0,dot(worldNormal,halfDir)),_Gloss);
                    return fixed4(diffuse+specular+ambient,1);
                    
                }
            ENDCG
        }

    }
    FallBack "Diffuse"
}
