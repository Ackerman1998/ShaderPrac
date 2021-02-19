// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/MainTexPracShader"
{
   Properties{
	   _Color("Color Tint",Color)=(1,1,1,1)
	   _MainTex("MainTexture",2D)="white"{}
   }
   SubShader{
	   Pass{
		   CGPROGRAM
		  	    //顶点
				#pragma vertex vrt
				//片元
				#pragma fragment frag
				#include "UnityCG.cginc"
				fixed4 _Color;
				float4 _MainTex_ST;
				sampler2D _MainTex;
				struct a2v{
					float4 vertex : POSITION;
					float4 uv : TEXCOORD0;
					
				};
				struct v2f{
					float4 pos: SV_POSITION;
					float2 uv : TEXCOORD1;
				};
				v2f vrt(a2v v){
					v2f o;
					o.pos=UnityObjectToClipPos(v.vertex);
					o.uv=v.uv.xy*_MainTex_ST.xy+_MainTex_ST.zw;
					return o;
					
				}
				fixed4 frag(v2f i) : SV_TARGET{
					//fixed4 f=tex2D(_MainTex,i.uv);//*_Color.rgb;
					fixed3 ff=tex2D(_MainTex,i.uv).rgb*_Color.rgb;
					//f.a=1;
					return fixed4(ff,1);
				}
		   ENDCG
		   
	   }
	   
   }
}
/*
模型空间
 世界空间
 观察空间 摄像机所看到的空间，也称摄像机空间
 裁剪空间 
 屏幕空间
UNITY_MATRIX_MVP等定义
M代表Model 模型，V代表View 观察，P代表Projection 投影
矩阵变换：
		MATRIX：矩阵
		模型变换：从模型空间转换到世界空间
		观察变换：从世界空间转换到观察空间
		投影变换：从观察空间转换到裁剪空间
UNITY_MATRIX_M	模型变换矩阵
UNITY_MATRIX_V	观察变换矩阵
UNITY_MATRIX_P	投影变换矩阵
UNITY_MATRIX_MV	
UNITY_MATRIX_VP	
UNITY_MATRIX_MVP	
https://my.oschina.net/u/918889/blog/1858627
*/