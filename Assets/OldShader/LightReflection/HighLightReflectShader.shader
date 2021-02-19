// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/HighLightReflectShader"
{
	//高光反射光照
		Properties{
			_Diffuse("Diffuse",Color) = (1,1,1,1)
			_Specular("Specular", Color) = (1,1,1,1)
			_Gloss("Gloss", Range(8.0,256)) = 20
		}
			SubShader{
				Pass{
					Tags{"LightMode" = "ForwardBase"}
					CGPROGRAM
						#pragma vertex vrt
						#pragma fragment frag
						#include "Lighting.cginc"
						fixed4 _Diffuse;
						fixed4 _Specular;
						float _Gloss;
						struct av2 {
							float4 vertex : POSITION;
							float3 normal: NORMAL;
						};
						struct v2f {
							float4 pos : SV_POSITION;
							float3 color: COLOR;
						};
						v2f vrt(av2 v) {
							v2f o;
							o.pos = UnityObjectToClipPos(v.vertex);
							fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;//获取环境光的颜色
							fixed3 worldNormal = normalize(mul(v.normal,(float3x3)unity_WorldToObject));//将模型法线变换到世界空间
							fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);//获取环境光的方向
							fixed3 diffuse = _LightColor0.rgb*_Diffuse.rgb*saturate(dot(worldNormal, worldLight));//漫反射
							fixed3 reflectDir = normalize(reflect(-worldLight,worldNormal));//求环境光的反射
							fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz-mul(unity_ObjectToWorld,v.vertex).xyz);//求视角方向：在世界坐标下，相机坐标减去模型坐标 
							fixed3 specular = _LightColor0.rgb*_Specular.rgb*pow(saturate(dot(reflectDir, viewDir)), _Gloss);
							o.color = ambient + diffuse + specular;
							return o;
						}
						fixed4 frag(v2f i) : SV_Target{
							return fixed4(i.color,1);
						}
					ENDCG
			}
			}
}
/*
	高光反射光照
	高光反射光照模型的公式如下：
　　Cspecular = Clight * mspecular * max(0, dot(v, r))gloss
	要计算高光反射需要知道4个参数：入射光线颜色Cspecular，材质高光反射系数gloss，视角方向v和反射方向r
	相机位置的变动，高光也会跟着变动
*/