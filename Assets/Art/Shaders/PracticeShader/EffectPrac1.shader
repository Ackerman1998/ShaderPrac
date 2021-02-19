Shader "Custom/EffectPrac1"
{
    Properties
    {
        _ColorUp ("_ColorUp", Color) = (1,1,1,1)//红色
        _ColorDown ("_ColorDown", Color) = (1,1,1,1)//绿色
        _ColorControl("Control",float)=1
    
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
      
        Pass{
            CGPROGRAM
                #pragma vertex vert
                #pragma fragment frag
                #include "Lighting.cginc"
                #include "UnityCG.cginc"
                float4 _ColorUp;
                float4 _ColorDown;
                float _ColorControl;
                struct a2v{
                    float4 vertex : POSITION;
                    float4 uv : TEXCOORD0;
                };
                
                struct v2f{
                    float4 clipPos : SV_POSITION;
                    float2 uv : TEXCOORD0;
                };
                v2f vert(a2v i){
                    v2f o;
                    o.clipPos = UnityObjectToClipPos(i.vertex);
                    o.uv.xy = i.uv.xy;
                    return o;
                }
                fixed4 frag(v2f i):SV_TARGET{
                    float y = i.uv.y;
                    fixed4 col = lerp(_ColorUp,_ColorDown,y*_ColorControl);
                    return col;
                }
            ENDCG
        }
        
    }
    FallBack "Diffuse"
}
//1.一个模型，上半部分为红色，下半部分为绿色