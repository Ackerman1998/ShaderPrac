// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/TagentNormal"
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
					
					return o;
				}
				fixed4 frag(v2f i):SV_TARGET{
					fixed4 packedNormal=tex2D(_BumpMap,i.uv.zw);
					fixed3 tangentNormal;
				
					tangentNormal.xy=(packedNormal.xy*2-1);
				
					tangentNormal=UnpackNormal(packedNormal);//对法线纹理进行反映射
					tangentNormal.xy*=_BumpScale;
					tangentNormal.z=sqrt(1-saturate(dot(tangentNormal.xy,tangentNormal.xy)));
					fixed3 albedo = tex2D(_MainTex,i.uv.xy).rgb*_Color.rgb;//将主纹理的颜色与面板颜色混合
					fixed3 ambient=UNITY_LIGHTMODEL_AMBIENT.rgb*albedo;//得到环境光照并且和上面的颜色混合
					fixed3 diffuse=_LightColor0.rgb*albedo*max(0,dot(tangentNormal,i.viewDir));
					//fixed3 diffuse=_LightColor0.rgb*albedo*max(0,dot(tangentNormal,i.lightDir));
					fixed3 halfDir=normalize(i.lightDir+i.viewDir);
					fixed3 specular=_LightColor0.rgb*_Specular.rgb*pow(max(0,dot(tangentNormal,halfDir)),_Gloss);
					return fixed4(ambient+diffuse+specular,1.0);
					//return fixed4(11,1,1,1);
				}
			ENDCG
			
		}
		
	}
}
/*
shader笔记
========
基础知识
=========================================================================================================
cg中的基本数据类型
float 32位浮点数
half 16位浮点数
int   32位整形数
fixed 12位定点数
bool  布尔数据
float3x3 3x3阶矩阵
sampler 纹理对象的句柄 共有：sampler、sampler1D、sampler2D、sampler3D、samplerCUBE、和samplerRECT六种。
==========================================================================================================
什么是UV
https://blog.csdn.net/qq_36251561/article/details/94397629
tex2D(sampler2D tex,float)
===========================================================================================================
裁剪空间: https://blog.csdn.net/ad88282284/article/details/78245719
相机：观察空间->裁剪空间 
透视投影矩阵公式演示及推导参考:https://www.cnblogs.com/bluebean/p/5276111.html
裁剪空间坐标 x y z w w坐标是将 x y z 约束在一个范围内
======================================================================================================
half4 c = tex2D (_MainTex, IN.uv_MainTex);  
o.Albedo = c.rgb;  
o.Alpha = c.a;  
tex2D(sampler2D tex, float2 s)函数，这是CG程序中用来在一张贴图中对一个点进行采样的方法，
返回一个float4。这里对 _MainTex在输入点上进行了采样，并将其颜色的rbg值赋予了输出的像素颜色，
将a值赋予透明度。于是，着色器就明白了应当怎样工作：即找到贴图上 对应的uv点，直接使用颜色
信息来进行着色，over。
axb 向量的叉积：
可以理解为a与b包围构成的平行四边形的面积
叉积的向量垂直于a和b，axb=-bxa
sqrt求平方根
saturate(a)将a的值限制在[0,1]范围内
==========================================================================================================
在切线空间下计算法线：
光照计算：
	1.漫反射光照计算diffuse
	diffuse=_LightColor0.rgb(平行光颜色)*主纹理颜色*max(0,dot(法线,灯光方向+相机方向(或者使用半兰伯特)))
	使用灯光方向做点积，面向灯光的面发亮，背向的比较暗；若使用相机方向做点积，则视觉范围内的区域都比较亮。
	2.高光光照计算specular
	specular=_LightColor0.rgb*高光颜色*pow(max(0,dot(法线向量，光照方向)),光泽度) pow(a,b)=求a的b次幂
	3.环境光照计算ambient
	ambient=UNITY_LIGHTMODEL_AMBIENT.xyz*主纹理颜色
	光照计算=环境光+高光+漫反射
实现调节3D物体透明度：	
	加上 Blend SrcAlpha OneMinusSrcAlpha
	就可以通过调节color.a来控制物体的透明度
ZWrite 深度写入
off 代表关闭，Unity的Render Queue被重写了，面板调节该值无效
===========================================================================================================
Shader深度渲染队列Queue预定义值：Background（1000）、Geometry（2000）、AlphaTest（2450）、Transparent（3000）、
Overlay（4000）。
渲染优先顺序： Queue值越小越先渲染，后渲染的物体会覆盖先渲染的物体。
texCube(天空盒,反射方向) : 对天空盒进行反射方向进行采样 返回的类型:float4
tex2D(纹理图片,光照方向+相机方向) 返回的类型:float4
===========================================================================================================
lerp函数
=========
先说一下CG语言中的lerp函数
lerp(a, b, w);
a与b为同类形，即都是float或者float2之类的，那lerp函数返回的结果也是与ab同类型的值。
w是比重，在0到1之间
当w为0时返回a，为1时返回b，在0,1之间时，以比重w将ab进行线性插值计算。
===========================================================================================================
GrabPass
=========
GrabPass是Unity用来获取屏幕图像，并将当前屏幕图像绘制在一张纹理上的一个方法，
使用方法: 定义 GrabPass { "_RefractionTex" } ,      sampler2D _RefractionTex;
===========================================================================================================
float4 _MainTex_ST:
声明_MainTex是一张采样图，也就是会进行UV运算,如果没有这句话，是不能进行TRANSFORM_TEX的运算的

_RefractionTex_TexelSize
可以让我们得到该像素的纹理大小，例如一个大小为256×512的纹理，它的像素大小为（1/256,1/512）。我们
需要在对屏幕图像的采样坐标进行偏移时使用该量。

uv的计算
 	uv=TRANSFORM_TEX(vertex(模型顶点),_MainTex(贴图))
	或写做:uv=vertex.xy*_MainTex_ST.xy+_MainTex_ST.zw;
	_MainTex_ST.xy:贴图的缩放tiling , _MainTex_ST.zw：贴图的偏移offset

o.scrPos = ComputeGrabScreenPos(o.pos); //输入模型顶点在裁剪空间下的坐标.得到模型顶点在屏幕空间下的坐标

实现玻璃效果:
主纹理贴图,法线贴图,cubemap


总结：
顶点着色器：一般对模型进行处理，对模型的顶点，法线，切线，uv进行变换
像素着色器:





UnityCG.cginc
#if UNITY_UV_STARTS_AT_TOP 可以用来判断我们是否是在 Direct3D 平台下。
点 w 值=1
方向矢量 w 值 =0
*/