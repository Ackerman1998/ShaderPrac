Shader "Custom/ImgAnimShader"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Speed("Speed",float)=40
        _row("row",float)=8
        _column("column",float)=8
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" }
        LOD 200
        ZWrite Off
        Blend SrcAlpha OneMinusSrcAlpha
        Pass{

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            float4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Speed;
            float _row;
            float _column;
            struct a2v{
                float4 vertex : POSITION;
                float4 uv : TEXCOORD0;
            };
            struct v2f{
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
            };
            v2f vert(a2v i){
                v2f o;
                o.pos = UnityObjectToClipPos(i.vertex);
                o.uv.xy = i.uv.xy*_MainTex_ST.xy+_MainTex_ST.zw;
                return o;
            }
            fixed4 frag(v2f i) : SV_TARGET{
                float time = floor(_Time.y*_Speed);//通过_Speed控制时间的快慢
                float row = floor(time/_row);//表示当前时间应该跑到第几行了
                float col = time - row*_column;//表示当前时间应该跑到第几列了
                half2 uv = i.uv+half2(col,-row);//往右走列数增加，往下走行数减少，
                uv.x/=_column;//将原本采样UV的x缩小_RowAmount倍
                uv.y/=_row;//将原本采样UV的y缩小_ColumnAmount倍
                fixed4 c = tex2D(_MainTex,uv);
                c.rgb*=_Color;
                return c;
            }
            ENDCG
        }
        
    }
    FallBack "Diffuse"
}
