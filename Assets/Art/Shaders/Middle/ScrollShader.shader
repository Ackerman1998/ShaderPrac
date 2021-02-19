Shader "Custom/ScrollShader"
{
    Properties {
		_MainTex ("Base Layer (RGB)", 2D) = "white" {}
		_DetailTex ("2nd Layer (RGB)", 2D) = "white" {}
		_ScrollX ("Base layer Scroll Speed", Float) = 1.0
		_Scroll2X ("2nd layer Scroll Speed", Float) = 1.0
		_Multiplier ("Layer Multiplier", Float) = 1
	}
	SubShader {
		Tags { "RenderType"="Opaque" "Queue"="Geometry"}
		
		Pass { 
			Tags { "LightMode"="ForwardBase" }
			
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			
			sampler2D _MainTex;
			sampler2D _DetailTex;
			float4 _MainTex_ST;
			float4 _DetailTex_ST;
			float _ScrollX;
			float _Scroll2X;
			float _Multiplier;
			
			struct a2v {
				float4 vertex : POSITION;
				float4 texcoord : TEXCOORD0;
			};
			
			struct v2f {
				float4 pos : SV_POSITION;
				float4 uv : TEXCOORD0;
			};
			
			v2f vert (a2v v) {
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				
				//o.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex) + frac(float2(_ScrollX, 0.0) * _Time.y);
				//o.uv.zw = TRANSFORM_TEX(v.texcoord, _DetailTex) + frac(float2(_Scroll2X, 0.0) * _Time.y);
			
				o.uv.xy = v.texcoord.xy*_MainTex_ST.xy+_MainTex_ST.zw+frac(float2(_ScrollX,0)*_Time.y);
				o.uv.zw = v.texcoord.xy*_DetailTex_ST.xy+_DetailTex_ST.zw+frac(float2(_Scroll2X,0)*_Time.y);
                
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target {
				fixed4 firstLayer = tex2D(_MainTex, i.uv.xy);
				fixed4 secondLayer = tex2D(_DetailTex, i.uv.zw);
				
				fixed4 c = lerp(firstLayer, secondLayer, secondLayer.a);
				c.rgb *= _Multiplier;
				
				return c;
			}
			
			ENDCG
		}
	}
	FallBack "VertexLit"
}
// lerp(a, b, w);

// a与b为同类形，即都是float或者float2之类的，那lerp函数返回的结果也是与ab同类型的值。
// w是比重，在0到1之间
// 当w为0时返回a，为1时返回b，在01之间时，以比重w将ab进行线性插值计算。