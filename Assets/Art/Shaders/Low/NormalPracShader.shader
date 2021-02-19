Shader "Ackerman/NormalPracShader"
{
    Properties{
        _Color("Color",Color)=(1,1,1,1)
        _MainTex("主贴图",2D)="white"{}
        _NormalTex("法线",2D)="bump"{}
        _NormalScale("normalScale",float)=1

    }
    SubShader{
        Pass{
             Tags{"LightMode"="ForwardBase"}
            CGPROGRAM
                #pragma vertex vert
                #pragma fragment frag
                #include "Lighting.cginc"
                fixed4 _Color;
                sampler2D _MainTex;
                float4 _MainTex_ST;
                sampler2D _NormalTex;
                float4 _NormalTex_ST;
                float _NormalScale;
                struct a2v{
                    float4 posObj : POSITION;
                    float3 normal : NORMAL;
                    float4 tangent : TANGENT;
                    float2 uv : TEXCOORD0;
                };
                struct v2f{
                    float4 clipPos : SV_POSITION;
                    fixed4 uv : TEXCOORD0;
                    fixed3 lightDir : TEXCOORD1;
                    fixed3 ViewDir : TEXCOORD2;
                    
                };
                v2f vert(a2v i){
                    v2f o;
                    o.clipPos = UnityObjectToClipPos(i.posObj);
                    o.uv.xy = i.uv.xy*_MainTex_ST.xy+_MainTex_ST.zw;
                    o.uv.zw = i.uv.xy*_NormalTex_ST.xy+_NormalTex_ST.zw;
                    float3 binormal = cross(normalize(i.normal.xyz),normalize(i.tangent.xyz))*i.tangent.w;
                    float3x3 rotation = float3x3(i.tangent.xyz,binormal,i.normal);
                    o.lightDir = normalize(mul(rotation,ObjSpaceLightDir(i.posObj)));
                    o.ViewDir =normalize(mul(rotation,ObjSpaceViewDir(i.posObj)));
                    return o;
                }
                fixed4 frag(v2f i):SV_TARGET{
                    fixed4 pixelNormal = tex2D(_NormalTex,i.uv.zw);//获取法线像素
                    fixed4 tangentNormal;//计算切线空间下的法线向量
                    tangentNormal.xy = (pixelNormal.xy*2- 1)*_NormalScale;
                    tangentNormal.z = sqrt(1-saturate(dot(pixelNormal.xy,pixelNormal.xy)));
                    fixed3 albeo = tex2D(_MainTex,i.uv.xy).rgb*_Color.rgb;//获取主贴图的颜色
                    fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz*albeo;//获取环境光照
                    fixed3 diffuse = _LightColor0.rgb*albeo*max(0,dot(tangentNormal,i.lightDir));//获取漫反射
                    fixed3 color = ambient+diffuse;
                    return fixed4(color,1);
                }
            ENDCG
        }

    }
}
