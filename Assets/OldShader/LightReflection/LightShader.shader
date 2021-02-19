// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/LightShader"
{
		//逐顶点实现漫反射光照
		Properties{
			_Diffuse("Diffuse",Color) = (1,1,1,1)
		}
		SubShader{
			Pass{
				Tags{"LightMode" = "ForwardBase"}
				CGPROGRAM
					#pragma vertex vert
					#pragma fragment frag
					#include "Lighting.cginc"
					fixed4 _Diffuse;
				struct a2v {
					float4 vertex : POSITION;
					float3 normal : NORMAL;
				};
				struct v2f {
					float4 pos : SV_POSITION;
					float3 color: COLOR0;
				};
	 
				v2f vert(a2v v) {
					v2f o;
					o.pos = UnityObjectToClipPos(v.vertex);
					fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;//unity的环境光
					fixed3 worldNormal = normalize(mul(v.normal,(float3x3)unity_WorldToObject));
					//fixed3 worldNormal = normalize(mul(UNITY_MATRIX_MVP,v.normal));
					fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);
					fixed3 diffuse = _LightColor0.rgb*_Diffuse.rgb*saturate(dot(worldNormal, worldLight));
					o.color = ambient + diffuse;
					return o;
				}
				fixed4 frag(v2f i) : SV_Target {
					return fixed4(i.color,1);
				}
				ENDCG
			}
		
		}
}
/*
		cg函数
		normalize 归一化向量
		_WorldSpaceLightPos0光的方向向量
		mul(v.normal,(fixed3)_World2Object) 将法线从模型空间转换到世界空间
		===========================================================================================================
		当你想将颜色值规范到0~1之间时，你可能会想到使用saturate函数（saturate(x)的作用是如果x取值小于0，则返回值为0。
		如果x取值大于1，则返回值为1。若x在0到1之间，则直接返回x的值.），当然saturate也可以使用变量的swizzled版本，
		比如saturate(somecolor.rgb);
		漫反射公式：fixed3 diffuse = _LightColor0.rgb*_Diffuse.rgb*saturate(dot(worldNormal, worldLight)); dot点积
		点积的意义：dot(a,b)  = a和b乘积的余弦值 即：向量a在向量b上的投影  
*/