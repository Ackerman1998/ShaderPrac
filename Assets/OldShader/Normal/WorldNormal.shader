// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Custom/WorldNormal"
{
     Properties{
		_Color("Color Tint",Color)=(1,1,1,1)
		_MainTex("Main Tex",2D)="white"{}
		_BumpMap("Bump Map",2D)="white"{}
		_BumpScale("Bump Scale",float)=1
		_Specular("Specular",Color)=(1,1,1,1)
		_Gloss("Gloss",Range(8,256))=8
	}
	SubShader{
        //世界空间下计算
		Pass{
			CGPROGRAM
				#pragma vertex vrt
				#pragma fragment frag
				#include "UnityCG.cginc"
				#include "Lighting.cginc"
				fixed4 _Color;
				sampler2D _MainTex;
				float4 _MainTex_ST;
				sampler2D _BumpMap;
				float4 _BumpMap_ST;
				float _BumpScale;
				fixed4 _Specular;
				float _Gloss;
				struct av2{
					float4 vertex : POSITION;
					float3 normal :NORMAL;
					float4 tangent : TANGENT;
					float4 uv : TEXCOORD0;
					
				};
				struct v2f{
					float4 pos : SV_POSITION;
					float4 uv : TEXCOORD0;
					float3 lightDir : TEXCOORD1;
					float3 viewDir : TEXCOORD2;
				};
				v2f vrt(av2 i){
					v2f o;
					 o.pos=UnityObjectToClipPos(i.vertex);//变换为裁剪空间
					 o.uv.xy=i.uv.xy*_MainTex_ST.xy+_MainTex_ST.zw;//对第一张图片进行uv缩放
					 o.uv.zw=i.uv.xy*_BumpMap_ST.xy+_BumpMap_ST.zw;
					float3 y=cross(normalize(i.normal),normalize(i.tangent.xyz))*i.tangent.w;//根据切线x，法线z求得副切线y
					float3x3 rotation=float3x3(i.tangent.xyz,y,i.normal);//求出由切线，法线，副切线构成的3阶矩阵
					o.lightDir=normalize(mul(rotation,ObjSpaceLightDir(i.vertex).xyz));//求灯光方向得模
					o.viewDir=normalize(mul(rotation,ObjSpaceViewDir(i.vertex).xyz));//求相机方向得模
                    // float3 worldPos=mul(unity_ObjectToWorld,i.vertex).xyz;
                    // fixed3 worldNormal=UnityObjectToWorldNormal(i.normal);
                    // fixed3 worldTangent=UnityObjectToWorldDir(i.tangent.xyz);
                    // fixed3 worldBinomal=cross(worldNormal,worldBinomal)*i.tangent.w;
                    // o.TtoW0=float4(worldNormal.x,worldBinomal.x,worldTangent.x,worldPos.x);
                    // o.TtoW1=float4(worldNormal.y,worldBinomal.y,worldTangent.y,worldPos.y);
                    // o.TtoW2=float4(worldNormal.z,worldBinomal.z,worldTangent.z,worldPos.z);
					return o;
				}
				fixed4 frag(v2f i):SV_TARGET{
					fixed4 packedNormal=tex2D(_BumpMap,i.uv.zw);
					fixed3 tangentNormal;
				
					tangentNormal.xy=(packedNormal.xy*2-1);
				
					tangentNormal=UnpackNormal(packedNormal);//对法线纹理进行反映射,得到正确的法线
					tangentNormal.xy*=_BumpScale;
					tangentNormal.z=sqrt(1-saturate(dot(tangentNormal.xy,tangentNormal.xy)));
					fixed3 albedo = tex2D(_MainTex,i.uv.xy).rgb*_Color.rgb;//将主纹理的颜色与面板颜色混合
					fixed3 ambient=UNITY_LIGHTMODEL_AMBIENT.rgb*albedo;//得到环境光照并且和上面的颜色混合
					fixed3 diffuse=_LightColor0.rgb*albedo*max(0,dot(tangentNormal,i.viewDir));
					//fixed3 diffuse=_LightColor0.rgb*albedo*max(0,dot(tangentNormal,i.lightDir));
					fixed3 halfDir=normalize(i.lightDir+i.viewDir);
					fixed3 specular=_LightColor0.rgb*_Specular.rgb*pow(max(0,dot(tangentNormal,halfDir)),_Gloss);
					return fixed4(ambient+diffuse+specular,1.0);
					// return fixed4(1,1,1,1);
				}
			ENDCG
			
		}
		
	}
}
