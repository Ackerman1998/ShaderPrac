//漫反射实现
Shader "Ackerman/DiffuseShader"
{
    Properties
    {
        _Diffuse ("漫反射颜色", Color) = (1,1,1,1)//入射光线的颜色
        _DiffuseScale("漫反射强度",float)=1
    }
    SubShader
    {
        Pass{
            Tags{"LightMode"="ForwardBase"}
            CGPROGRAM 
            #pragma vertex vert
            #pragma fragment frag
            #include "Lighting.cginc"
            fixed4 _Diffuse;
            float _DiffuseScale;
            //定义一个结构体获取模型的顶点坐标，法线矢量(模型空间下)
            struct a2v{
                float4 vertex : POSITION;
                float4 normal : NORMAL;
            };
            //定义一个结构体存储光照的颜色，裁剪空间下的顶点坐标
            struct v2f{
                float4 pos : SV_POSITION;
                float3 worldNormal : NORMAL;
                fixed3 color : COLOR;
            };

            /*逐顶点光照
            v2f vert(a2v a){
                v2f o;
                o.pos=UnityObjectToClipPos(a.vertex);//模型顶点坐标变换到裁剪空间
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;//得到环境光
                fixed3 worldNormal = normalize(mul(a.normal,(fixed3x3)unity_WorldToObject));//模型空间的法线与模型变换矩阵乘积
                fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);//得到平行光的世界方向向量
                fixed3 diffuse = _LightColor0.rgb*_Diffuse.rgb*saturate(dot(worldNormal,worldLight))*_DiffuseScale;
                o.color = ambient+diffuse;
                return o;
            }
            fixed4 frag(v2f v) : SV_TARGET{          
                return fixed4(v.color,1);
            }
            */

            //逐片元光照
            // v2f vert(a2v a){
            //     v2f o;
            //     o.pos=UnityObjectToClipPos(a.vertex);
            //     o.worldNormal=normalize(mul(a.normal,(fixed3x3)unity_WorldToObject));
            //     return o;
            // }
            // fixed4 frag(v2f v) : SV_TARGET{
            //     fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
            //     fixed3 worldLight=normalize(_WorldSpaceLightPos0.xyz);
            //     fixed3 diffuse = _LightColor0.rgb*_Diffuse.rgb*saturate(dot(v.worldNormal,worldLight))*_DiffuseScale;
            //     v.color=ambient+diffuse;
            //     return fixed4(v.color,1);
            // }

            //半兰伯特模型
            v2f vert(a2v a){
                v2f o;
                o.pos=UnityObjectToClipPos(a.vertex);
                o.worldNormal=normalize(mul(a.normal,(fixed3x3)unity_WorldToObject));
                return o;
            }
            fixed4 frag(v2f v) : SV_TARGET{
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                fixed3 worldLightDir=normalize(_WorldSpaceLightPos0.xyz);
                fixed3 diffuse = _LightColor0.rgb*_Diffuse.rgb*(dot(v.worldNormal,worldLightDir)*0.5+0.5)*_DiffuseScale;
                v.color=ambient+diffuse;
                return fixed4(v.color,1);
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
/*
Shader:Ackerman/DiffuseShader
漫反射实现过程:(逐顶点光照)
1.变换顶点坐标到裁剪空间
2.获取环境光的方向向量
3.将模型的法线向量变换到世界空间下，并归一化
4.获取场景中的灯光(例如平行光)的方向向量，并归一化.
常用变量/函数:

(fixed3x3)unity_WorldToObject：模型变换矩阵
UNITY_LIGHTMODEL_AMBIENT：环境光
_WorldSpaceLightPos0：平行光
_LightColor0：场景中灯光的颜色
POSITION:模型空间下的顶点位置
NORMAL:顶点法线
TANGENT:顶点切线
TEXCOORDn比如:TEXCOORD0:该顶点的纹理坐标,第一组纹理坐标
COLOR:顶点颜色
SV_POSITION:裁剪空间的顶点坐标
SV_TARGET:输出的值将会存放在渲染目标中.
_WorldSpaceCameraPos:相机在世界空间下的坐标



3种数据精度类型:
float 最高精度的浮点，通常使用32位存储
half  中等精度的浮点，通常使用16位存储，范围[-60000,+60000]
fixed 最低精度的浮点，通常使用11位存储,范围[-2,+2]
漫反射计算:diffuse=灯光颜色*可调颜色*投影方向向量

半兰伯特模型计算漫反射光照与之前两种计算方式对比：
模型背光面不会颜色都是一样黑，像一个平面一样，模型细节表现不出来。
在计算方向矢量时应该作归一化
*/