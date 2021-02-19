// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Ackerman/SimpleShader"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
    }
    SubShader
    {
        Pass{
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Lighting.cginc"
            fixed4 _Color;
            struct a2v{
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 texcoord : TEXCOORD0;
            };
            struct v2f{
                float4 pos : SV_POSITION;
                fixed3 color : COLOR0;
            };
            v2f vert(a2v a){
                v2f o;
                o.pos=UnityObjectToClipPos(a.vertex);//模型空间变换到裁剪空间的变换矩阵与模型顶点做乘积,即将模型顶点做裁剪变换
                o.color=a.normal*0.5+fixed3(0.5,0.5,0.5);
                return o;
            }
            fixed4 frag(v2f i) : SV_TARGET{
                fixed3 c=i.color;
                c*=_Color.rgb;
                return fixed4(c,1.0);
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
