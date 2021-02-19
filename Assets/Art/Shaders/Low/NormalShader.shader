Shader "Ackerman/NormalShader"
{
   //-------------在切线空间下计算光照-----------------
   Properties{
       _Color("Color",Color)=(1,1,1,1)
       _MainTex("MainTexture",2D)="white"{}
       _BumpMap("NormalTexture",2D)="bump"{}
       _BumpScale("Normal Scale",float)=1
       _Specular("Specular",Color)=(1,1,1,1)
       _Gloss("Gloss",Range(8,256))=20
   }
   SubShader{
       Pass{
           
           Tags{"LightMode"="ForwardBase"}
           CGPROGRAM
           #pragma vertex vert
           #pragma fragment frag
           #include "Lighting.cginc"
           float4 _Color;
           sampler2D _MainTex;
           float4 _MainTex_ST;
           sampler2D _BumpMap;
           float4 _BumpMap_ST;
           float _BumpScale;
           float4 _Specular;
           float _Gloss;
           struct a2v{
               float4 position : POSITION;
               float3 normal : NORMAL;
               float4 tangent : TANGENT;
               float2 uv : TEXCOORD0;
           };
           struct v2f{
               float4 clipPos : SV_POSITION;
               float4 uv : TEXCOORD0;
               float3 lightDir : TEXCOORD1;
               float3 viewDir : TEXCOORD2;
           };
           v2f vert(a2v i){
               v2f o;
               o.clipPos = UnityObjectToClipPos(i.position);
               o.uv.xy = i.uv.xy*_MainTex_ST.xy+_MainTex_ST.zw;
               o.uv.zw = i.uv.xy*_BumpMap_ST.xy+_BumpMap_ST.zw;
               //这一过程存放了面板上的偏移量和缩放量到v2f中，xy是主帖图的偏移缩放，zw是法线贴图的偏移缩放
               float3 binormal = cross(normalize(i.normal),normalize(i.tangent.xyz))*i.tangent.w;//计算副法线
               float3x3 rotate = float3x3(i.tangent.xyz,binormal,i.normal);//模型空间到切线空间的变换矩阵
               o.lightDir = mul(rotate,ObjSpaceLightDir(i.position)).xyz;//切线空间下的光照方向
               o.viewDir = mul(rotate,ObjSpaceViewDir(i.position)).xyz;//切线空间下的视线方向
               return o;
           }
           fixed4 frag(v2f i):SV_TARGET{
               //归一化切线空间下的灯光，视线向量
               fixed3 tangentLight = normalize(i.lightDir);
               fixed3 tangetnView = normalize(i.viewDir);
               //对法线贴图进行采样,并返回一个颜色
               fixed4 packNormal = tex2D(_BumpMap,i.uv.zw);//获取法线贴图上的像素
            //    fixed3 tangentNormal;
            //    packNormal.xy*=_BumpScale;
            //    packNormal.z=1;
               //得到正确的法线方向
               fixed3 tangentNormal;
               tangentNormal.xy = packNormal.xy*_BumpScale;
               tangentNormal.z = sqrt(1-saturate(dot(tangentNormal.xy,tangentNormal.xy)));

               //没勾选normal map
               //tangentNormal = UnpackNormal(packNormal);
               //tangentNormal.xy *= _BumpScale;
               //tangentNormal.z = sqrt(1-saturate(dot(tangentNormal.xy,tangentNormal.xy)));
               //tangentNormal.z =1;
               //计算环境光，漫反射，
               fixed3 albeo = tex2D(_MainTex,i.uv.xy).rgb*_Color.rgb;
               fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz*albeo;
               fixed3 diffuse = _LightColor0*albeo*max(0,dot(tangentNormal,tangentLight));
               fixed4 color = fixed4(ambient+diffuse,1);
               return color;
           }
           ENDCG
       }
   }
}
/*
#准备工作
顶点着色器：
1.将顶点从模型空间变换到裁剪空间
2.将主贴图和法线贴图的偏移，缩放值存放到片元结构体中
3.计算副法线
4.计算变换矩阵（模型->切线）
5.将灯光方向和视线方向变换到切线空间,最好归一化处理



*/