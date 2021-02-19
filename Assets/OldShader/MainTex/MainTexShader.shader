// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'
//单张纹理(将2D图片作为纹理贴在材质上)
Shader "Custom/MainTexShader"
{
	Properties{
		_Color("Color Tint",Color) = (1,1,1,1)
		_MainTex("Main Tex", 2D) = "white"{}
		_Specular("Specular", Color) = (1,1,1,1)
		_Gloss("Gloss",Range(8,256))=20
	}
	SubShader{
		Pass{
			Tags  {"LightMode"="ForwardBase"}
			CGPROGRAM
				#pragma vertex vrt
				#pragma fragment frag
				#include "Lighting.cginc"
				fixed4 _Color;
				sampler2D _MainTex;
				float4 _MainTex_ST;
				fixed4 _Specular;
				float _Gloss;
				//获取模型数据
				struct input {
					float4 vertex : POSITION;//模型顶点
					float3 normal: NORMAL;//模型法线
					fixed4 texcoord : TEXCOORD0;//模型纹理数据
				};
				//定义模型输出数据
				struct output {
					float4 pos :SV_POSITION;
					float3 worldnormal: TEXCOORD0;
					float3 worldPos: TEXCOORD1;
					float2 uv: TEXCOORD2;
				};
				output vrt(input i) {
					output o; 
					o.pos = UnityObjectToClipPos(i.vertex);
					//o.worldnormal = normalize(mul(i.normal,(float3x3)_Object2World));
					o.worldnormal = UnityObjectToWorldNormal(i.normal);
					o.worldPos = mul(unity_ObjectToWorld, i.vertex).xyz;
					o.uv = i.texcoord.xy*_MainTex_ST.xy + _MainTex_ST.zw;
					return o;
				}
				fixed4 frag(output op) :SV_Target{
					//先不计算光照，实现将2D贴图根据uv贴到材质
					//fixed3 worldnormal = normalize(op.worldnormal);//模型法线世界坐标的模
					//fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(op.worldPos));//模型到光源的方向
					fixed3 albedo = tex2D(_MainTex, op.uv).rgb*_Color.rgb;//获取图片的uv并赋到output的uv，将图片的颜色与面板输入的颜色混合
					// fixed3 ambient = albedo*UNITY_LIGHTMODEL_AMBIENT.xyz;;//将上面的颜色与环境光混合
					// fixed3 diffuse = _LightColor0.rgb*albedo*max(0, dot(worldnormal, worldLightDir));
					// fixed3 viewDir = normalize(UnityWorldSpaceViewDir(op.worldPos));
					// fixed3 halfDir = normalize(worldLightDir+viewDir);
					// fixed3 specular = _LightColor0.rgb*_Specular.rgb*pow(max(0, dot(worldnormal, halfDir)), _Gloss);
					//return fixed4(ambient+diffuse+specular,1); 
					return fixed4(albedo,1); 
					//return fixed4(1,1,1,1); 
				}
			ENDCG
		}
	}

}
/*
	tex2D(sampler2D tex, float2 s)函数，这是CG程序中用来在一张贴图中对一个点进行采样的方法，返回一个float4。这里对 _MainTex在
	输入点上进行了采样，并将其颜色的rbg值赋予了输出的像素颜色，将a值赋予透明度。于是，着色器就明白了应当怎样工作：即找到贴图上 
	对应的uv点，直接使用颜色信息来进行着色


*/