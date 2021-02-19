// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Render/GlassShader"
{
    Properties {
		_MainTex ("Main Tex", 2D) = "white"{}  //基础纹理
		_BumpMap ("Normal Map", 2D) = "bump"{}  //法线纹理
		_Cubemap ("Environment Cubemap", Cube) = "_Skybox"{}  //立方体纹理
		_Distortion ("Distortion", Range(0, 1000)) = 100  //控制模拟折射时图像的扭曲程度
		_RefractAmount ("Refraction Amount", Range(0, 1)) = 1  //控制折射程度,透明程度
	}
    SubShader{
            Tags{"Queue"="Transparent" "RenderType"="Opaque"}
  	        GrabPass { "_RefractionTex" }
          Pass{
        
            CGPROGRAM
                    #pragma vertex vrt
                    #pragma fragment frag
                    
                    #include "UnityCG.cginc"
                    
                    sampler2D _MainTex;
                    float4 _MainTex_ST;
                    sampler2D _BumpMap;
                    float4 _BumpMap_ST;
                    samplerCUBE _Cubemap;
                    float _Distortion;
                    fixed _RefractAmount;
                    sampler2D _RefractionTex;
                    float4 _RefractionTex_TexelSize;
                    
                    struct a2v {
                        float4 vertex : POSITION;
                        float3 normal : NORMAL;
                        float4 tangent : TANGENT; 
                        float2 texcoord: TEXCOORD0;
                    };
                    
                    struct v2f {
                        float4 pos : SV_POSITION;
                        float4 scrPos : TEXCOORD0;
                        float4 uv : TEXCOORD1;
                        float4 TtoW0 : TEXCOORD2;  
                        float4 TtoW1 : TEXCOORD3;  
                        float4 TtoW2 : TEXCOORD4; 
                    };

                    v2f vrt(a2v v){
                             v2f o;
                            o.pos = UnityObjectToClipPos(v.vertex);
                            //  o.pos=UnityObjectToClipPos(float4(v.vertex.xy,v.vertex.z,0));
                            //输入模型顶点在裁剪空间下的坐标.得到模型顶点在屏幕空间下的坐标
                            o.scrPos = ComputeGrabScreenPos(o.pos);
                            
                            o.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex);//主纹理uv
                            //上面的写法等同于下面的写法
                            //o.uv.xy = v.texcoord.xy*_MainTex_ST.xy+_MainTex_ST.zw;
                            o.uv.zw = TRANSFORM_TEX(v.texcoord, _BumpMap);//法线uv
                            
                            float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;  
                            fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);  
                            fixed3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);  
                            fixed3 worldBinormal = cross(worldNormal, worldTangent) * v.tangent.w; //副切线
                            //float4(切线，副切线，法线，顶点)对应 x y z w
                            o.TtoW0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x);  
                            o.TtoW1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y);  
                            o.TtoW2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z);  
                            return o;

                    }
                    fixed4 frag(v2f i) : SV_TARGET{
			        	float3 worldPos = float3(i.TtoW0.w, i.TtoW1.w, i.TtoW2.w);
                        fixed3 worldViewDir = normalize(UnityWorldSpaceViewDir(worldPos));
                        
                        // Get the normal in tangent space
                        fixed3 bump = UnpackNormal(tex2D(_BumpMap, i.uv.zw));//变换法线	
                        
                        // Compute the offset in tangent space
                        float2 offset = bump.xy * _Distortion * _RefractionTex_TexelSize.xy;
                        i.scrPos.xy = offset * i.scrPos.z + i.scrPos.xy;
                        // fixed3 refrCol=fixed3(1,1,1);
                        // if(i.scrPos.w==1){
                        //     fixed3 refrCol = tex2D(_RefractionTex, i.scrPos.xy/i.scrPos.w).rgb;
                        // }
                        // else if(i.scrPos.w==-1){ 
                            fixed3 refrCol = tex2D(_RefractionTex, i.scrPos.xy/i.scrPos.w).rgb;
                        //}
                        //求折射方向 
                        // float3 dir=float3(i.TtoW0.z,i.TtoW1.z,i.TtoW2.z);
                        // float3 refraction=refract(-worldViewDir,normalize( dir),_RefractAmount);//tex2D(_RefractionTex,);
                        // fixed3 refrCol = tex2D(_RefractionTex, refraction).rgb;
                        
                        // Convert the normal to world space
                        bump = normalize(half3(dot(i.TtoW0.xyz, bump), dot(i.TtoW1.xyz, bump), dot(i.TtoW2.xyz, bump)));
                        //bump = normalize(half3(1, 1, dot(i.TtoW2.xyz, bump)));
                        fixed3 reflDir = reflect(-worldViewDir, bump);
                        fixed4 texColor = tex2D(_MainTex, i.uv.xy);
                        fixed3 reflCol = texCUBE(_Cubemap, reflDir).rgb * texColor.rgb;
                        
                        fixed3 finalColor = reflCol * (1 - _RefractAmount) + refrCol * _RefractAmount;
				
                        return fixed4(finalColor, 1.0);
                       // return fixed4(finalColor, 1.0);

                    }
            ENDCG
            
        }

    }
}
