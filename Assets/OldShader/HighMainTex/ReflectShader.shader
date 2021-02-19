// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
//环境映射--反射
Shader "HighMainTex/ReflectShader"
{
   Properties{
       _Color("Color Tint",Color)=(1,1,1,1)
       _ReflectColor("Reflect Color",Color)=(1,1,1,1)
       _ReflectAmount("Reflect amount",Range(0,1))=1
       _Cube("Reflection CubeMap",Cube)="_Skybox"{}
   }
   SubShader{
       Pass{
           CGPROGRAM
                #pragma vertex vrt
                #pragma fragment frag
                #include "Lighting.cginc"
                #include "UnityCG.cginc"
                  #include "AutoLight.cginc"
                fixed4 _Color;
                fixed4 _ReflectColor;
                float _ReflectAmount;
                samplerCUBE _Cube;
                struct a2v{
                    float4 vertex : POSITION;
                    float3 normal : NORMAL;
                };
                struct v2f{
                    float4 pos : SV_POSITION;
                    float3 worldPos : TEXCOORD0;
                    float3 worldNormal : TEXCOORD1;
                    float3 worldViewDir : TEXCOORD2;
                    float3 worldReflection : TEXCOORD3;
                };
                v2f vrt(a2v i){
                    v2f o;
                    o.pos=UnityObjectToClipPos(i.vertex);
                    o.worldPos=normalize(mul(unity_ObjectToWorld,i.vertex).xyz);
                    o.worldNormal=normalize(UnityObjectToWorldNormal(i.normal));
                    o.worldViewDir=normalize( UnityWorldSpaceViewDir(i.vertex));
                    //根据法线求得相机方向的反方向
                    o.worldReflection=reflect(-o.worldViewDir,o.worldNormal);
                    TRANSFER_SHADOW(o);
                    return o;

                }
                fixed4 frag(v2f i) : SV_TARGET{
                    //计算环境光
                    fixed3 ambient=UNITY_LIGHTMODEL_AMBIENT.xyz;
                    //计算漫反射
                    fixed3 diffuse=_LightColor0.rgb*_Color.rgb*max(0,dot(i.worldNormal,i.worldViewDir));
                    fixed3 reflection=texCUBE(_Cube,i.worldReflection).rgb*_ReflectColor.rgb;
                    fixed3 finalColor=ambient+lerp(diffuse,reflection,_ReflectAmount);
                    return fixed4(finalColor,1);
                }
           ENDCG

       }

   }
}
