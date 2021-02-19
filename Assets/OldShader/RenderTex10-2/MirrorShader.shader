Shader "Render/MirrorShader"
{
    Properties
    {
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
    }
    SubShader
    {
        Pass{

            CGPROGRAM
                #pragma vertex vrt
                #pragma fragment frag
                #include "UnityCG.cginc"
                #include "Lighting.cginc"
                sampler2D _MainTex;
                struct a2v{
                        float4 vertex : POSITION;
                        float2 uv : TEXCOORD0;
                    };
                    struct v2f{
                        float4 pos : SV_POSITION;
                        float2 uv : TEXCOORD0;
                    };
                    v2f vrt(a2v i){
                        v2f o;
                        o.pos=UnityObjectToClipPos(i.vertex);
                        o.uv=i.uv;
                        o.uv.x=1-o.uv.x;
                        return o;

                    }
                    fixed4 frag(v2f i) : SV_TARGET{
                        return tex2D(_MainTex,i.uv);
                    }
            ENDCG
        }
      
    }
}
