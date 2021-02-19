Shader "Ackerman/MainTexShader"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("主纹理", 2D) = "white" {}
        _Specular ("Specular", Color) = (1,1,1,1)
        _Diffuse ("Diffuse", Color) = (1,1,1,1)
        _Gloss ("_Gloss", Range(8,256)) = 20
    }
    SubShader
    {
        Pass{
            Tags { "RenderType"="Opaque" }
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Lighting.cginc"
            float4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _Specular;
            float4 _Diffuse;
            float _Gloss;
            struct a2v{
                float4 pos : POSITION;
                float3 normal : NORMAL;
                float4 texcoord0 : TEXCOORD0;
            };
            struct v2f{
                float4 clipPos : SV_POSITION;
                float4 worldPos : TEXCOORD0;
                float4 worldNormal : TEXCOORD1;
                float2 uv : TEXCOORD2;
            };
            v2f vert(a2v a){
                v2f o;
                o.clipPos=UnityObjectToClipPos(a.pos);
                o.worldNormal = normalize(mul(a.normal,unity_WorldToObject));
                o.worldPos = normalize(mul(a.pos,unity_WorldToObject));
                //赋值uv
                o.uv=a.texcoord0.xy*_MainTex_ST.xy+_MainTex_ST.zw;
                return o;
            }
            fixed4 frag(v2f v):SV_TARGET{
                //计算反射率
                float3 albedo =_Color.rgb*tex2D(_MainTex,v.uv).rgb;
                float3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz*albedo;
                //获取场景灯光方向
                float3 lightDir = normalize(UnityWorldSpaceLightDir(v.worldPos).xyz);
                //计算漫反射
                float3 diffuse = _LightColor0.rgb*_Diffuse.rgb*albedo*saturate(dot(v.worldNormal,lightDir)*0.5+0.5);
                //获取相机视线方向
                float3 viewDir = normalize(_WorldSpaceCameraPos.xyz - v.worldPos.xyz);
                //获取反射光线方向
                float3 reflectDir = normalize(reflect(-lightDir,v.worldNormal));
                //计算高光反射
                float3 specular =_LightColor0.rgb*_Specular.rgb*pow(saturate(dot(reflectDir,viewDir)),_Gloss);
                fixed3 color = ambient + diffuse + specular;
                return fixed4(color,1);
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
