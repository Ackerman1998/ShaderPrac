// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/TestShader"
{
//    Properties {
//   //_MainTex ("Base (RGB)", 2D) = "white" {}
//  }
//  SubShader {
//   // 在所有不透明对象之后绘制自己，更加靠近屏幕
//   Tags { "Queue" = "Transparent" }
//   // 通道1：捕捉对象之后的屏幕内容放到_GrabTexture纹理中
//   GrabPass{}
//   // 通道2：设置材质
//   Pass{
//    // 使用上面产生的纹理，进行颜色反相(1-原材质色)
//    SetTexture[_GrabTexture]{combine one-texture}
//   }
//  }
//  FallBack "Diffuse"
Properties {
  //_MainTex ("Base (RGB)", 2D) = "white" {}
 }
 SubShader {
  // 在所有不透明对象之后绘制自己，更加靠近屏幕
  Tags{"Queue"="Transparent"}
  // 通道1：捕捉屏幕内容放到_GrabTexture纹理中
  GrabPass{} 
  // 通道2：设置材质
  Pass{
   Name "pass2"
   CGPROGRAM
   #pragma vertex vert
            #pragma fragment frag
   #include "UnityCG.cginc"

   sampler2D _GrabTexture;
   float4 _GrabTexture_ST;
   // 片段程序的输入
   struct v2f {
                float4  pos : POSITION;
                float2  uv : TEXCOORD0;
            };
   v2f vert (appdata_base v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
    o.uv = TRANSFORM_TEX(v.texcoord, _GrabTexture);
                return o;
            }
   float4 frag (v2f i) : COLOR
            {
    half4 texCol = tex2D(_GrabTexture, float2(1-i.uv.x , 1-i.uv.y));
    // 颜色反相，便于观察效果
                return 1 - texCol;
            }
   ENDCG
  }
 }
 FallBack "Diffuse"
}
