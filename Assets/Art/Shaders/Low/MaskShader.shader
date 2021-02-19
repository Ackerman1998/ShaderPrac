Shader "Ackerman/MaskShader"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("MainTex", 2D) = "white" {}
        _NormalMap ("NormalTex", 2D) = "white" {}
        _NormalScale("Normal Scale",float)=1
        _MaskMap ("MaskTex", 2D) = "white" {}
        _SpecularScale("Specular Scale",float)=1
        _Gloss("Gloss",Range(8,258))=20
    }
    SubShader
    {
        Pass{
            Tags { "RenderType"="ForwardBase" }
                CGPROGRAM
                #pragma vertex vert
                #pragma fragment frag
                #include "Lighting.cginc"
                float4 _Color;
                sampler2D _MainTex;
                float4 _MainTex_ST;
                sampler2D _NormalMap;
                sampler2D _MaskMap;
                float _SpecularScale;
                float _Gloss;
                struct a2v{
                    float4 pos : POSITION;
                    float3 normal : NORMAL;
                    float4 tangent : TANGENT;
                    float2 uv : TEXCOORD0;
                };
                struct v2f{
                    float4 clipPos : SV_POSITION;
                    float2 uv : TEXCOORD0;
                    fixed3 lightDir : TEXCOORD1;
                    fixed3 viewDir : TEXCOORD2;
                };
                v2f vert(a2v i){
                    v2f o;
                    o.clipPos = UnityObjectToClipPos(i.pos);//模型变换,将顶点模型空间变换到裁剪空间
                    o.uv = i.uv.xy*_MainTex_ST.xy+_MainTex_ST.zw;
                    float3 binormal = cross(normalize(i.tangent.xyz),normalize(i.normal.xyz))*i.tangent.w;//w决定副切线的方向
                    float3x3 rotation = float3x3(i.tangent.xyz,binormal,i.normal);
                    o.lightDir =normalize(mul(rotation,ObjSpaceLightDir(i.pos)));
                    o.viewDir =normalize(mul(rotation,ObjSpaceViewDir(i.pos)));
                    return o;
                }
                fixed4 frag(v2f i):SV_Target{
                    //法线取样
                    float4 pixel = tex2D(_NormalMap,i.uv);
                    //切线空间下的法线
                    fixed3 tangentNormal;
                    //根据取样得到像素映射得到切线空间下的法线
                    tangentNormal.xy = 2*pixel.xy - 1 ;
                    tangentNormal.z = sqrt(1-saturate(dot(tangentNormal.xy,tangentNormal.xy)));
                    fixed3 albeo = tex2D(_MainTex,i.uv).rgb*_Color.rgb;
                    fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz*albeo;
                    fixed3 diffuse = _LightColor0.rgb*albeo*max(0,dot(tangentNormal,i.lightDir));
                    fixed3 halfDir = normalize(i.lightDir+i.viewDir);
                    fixed specularMask = tex2D(_MaskMap,i.uv).r*_SpecularScale;
                    fixed3 specular = _LightColor0*pow(max(0,dot(tangentNormal,halfDir)),_Gloss)*specularMask;
                    return fixed4(ambient+diffuse+specular,1);
                }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
