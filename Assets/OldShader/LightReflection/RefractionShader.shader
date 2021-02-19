//环境映射--折射
Shader "Custom/RefractionShader"
{
   Properties{
       _Color("Color Tint",Color)=(1,1,1,1)
       _RefractColor("Refract Color",Color)=(1,1,1,1)
       _RefractAmount("Refract amount",Range(0,1))=1
       _RefractRatio("Refract Ratio",Range(0.1,1))=0.5
       _Cube("Refraction CubeMap",Cube)="_Skybox"{}
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
                fixed4 _RefractColor;
                float _RefractAmount;
                float _RefractRatio;
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
                    o.worldReflection=refract(-o.worldViewDir,o.worldNormal,_RefractRatio);
                    TRANSFER_SHADOW(o);
                    return o;

                }
                fixed4 frag(v2f i) : SV_TARGET{
                    //计算环境光
                    fixed3 ambient=UNITY_LIGHTMODEL_AMBIENT.xyz;
                    //计算漫反射
                    fixed3 diffuse=_LightColor0.rgb*_Color.rgb*max(0,dot(i.worldNormal,normalize(UnityWorldSpaceLightDir(i.worldPos))));
                    fixed3 refraction=texCUBE(_Cube,i.worldReflection).rgb*_RefractColor.rgb;
                    fixed3 finalColor=ambient+lerp(diffuse,refraction,_RefractAmount);
                    return fixed4(finalColor,1);
                }
           ENDCG

       }

   }
}
