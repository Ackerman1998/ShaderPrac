// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "Ackerman/SpecularShader"
{
    Properties{
        _Diffuse("漫反射颜色",Color)=(1,1,1,1)
        _SpecularScale("高光反射颜色",Color)=(1,1,1,1)
        _Gloss("Gloss",Range(8,256))=20
    }
    SubShader{
        Pass{
            Tags{"LightMode"="ForwardBase"}
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Lighting.cginc"
            float4 _Diffuse;
            float4 _SpecularScale;
            float _Gloss;
            struct a2v{
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };
           
        //     // 逐顶点计算
        //     struct v2f{
        //         float4 pos : SV_POSITION;
        //         fixed3 color : COLOR;
        //     };
        //    
        //     v2f vert(a2v a){
        //         v2f o;
        //         o.pos=UnityObjectToClipPos(a.vertex);
        //         fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
        //         fixed3 worldNormal=normalize(mul(a.normal,(fixed3x3)unity_WorldToObject));
        //         fixed3 worldLightDir=normalize(_WorldSpaceLightPos0.xyz);
        //         fixed3 diffuse = _LightColor0.rgb*_Diffuse.rgb*saturate(dot(worldNormal,worldLightDir)*0.5+0.5);
        //         fixed3 reflectDir = normalize(reflect(-worldLightDir,worldNormal));
        //         fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz-mul(unity_ObjectToWorld,a.vertex).xyz);
        //         fixed3 specular = _LightColor0.rgb*_SpecularScale.rgb*pow(saturate(dot(reflectDir,viewDir)),_Gloss);
        //         o.color = ambient+diffuse+specular;
        //         return o;
        //     }
        //     fixed4 frag(v2f v) :SV_TARGET{
        //         return fixed4(v.color,1);
        //     }
            
            //逐片元计算
            struct v2f{
                float4 pos : SV_POSITION;//模型顶点在裁剪空间的位置
                float3 worldPos : TEXCOORD0;//世界空间下的模型顶点位置
                float3 worldNormal : TEXCOORD1;//世界空间下的法线向量
            };
            v2f vert(a2v a){
                v2f o;
                o.pos=UnityObjectToClipPos(a.vertex);
                o.worldPos=mul(unity_ObjectToWorld,a.vertex).xyz;
                o.worldNormal =normalize( mul(a.normal,(fixed3x3)unity_ObjectToWorld));
                return o;
            }
            fixed4 frag(v2f v) :SV_TARGET{
                //获取环境光
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                //获取平行光方向
                fixed3 lightWorldDir = _WorldSpaceLightPos0.xyz; 
                //获取相机视线方向
                fixed3 cameraViewDir =normalize(_WorldSpaceCameraPos.xyz-v.worldPos);
                //计算反射光线方向
                fixed3 reflectDir = normalize(reflect(-lightWorldDir,v.worldNormal));
                //计算漫反射光照
                fixed3 diffuse = _LightColor0.rgb*_Diffuse.rgb*(saturate(dot(v.worldNormal,lightWorldDir)*0.5+0.5));
                //计算高光反射
                fixed3 specular = _LightColor0.rgb*_SpecularScale.rgb*pow(saturate(dot(reflectDir,cameraViewDir)),_Gloss);
                fixed3 colorFinal = ambient+diffuse;
                return fixed4(colorFinal,1);
            }
            ENDCG
        }

    }
    FallBack "Diffuse"
}
/*
Shader "Ackerman/SpecularShader"高光反射光照模型
不完全符合真实世界中的高光反射现象，用于计算那些沿着完全镜面反射方向被反射的光线，可以让物体看起来有光泽，比如金属材质。
求法：灯光颜色*自定义颜色*(反射方向向量和视角方向向量的点积);视角方向向量：相机世界坐标-模型顶点的世界坐标
pow(a,b)=求a的b次幂
saturate(a)将a的值限制在[0,1]范围内
reflect(a,b)求向量a在b作为法线下得到的反射向量
dot(a,b)求向量b在a上的投影

*/