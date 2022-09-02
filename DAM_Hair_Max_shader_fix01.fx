/*
基于max版本：2022编写，其他版本未测试
顶点色与切线副切线存在数据干扰，目前只能通过手动计算切线方式避免问题
*/
string ParamID = "0x003";


//----------------------------------------------变换矩阵（自动）-------------------

//世界矩阵的逆矩阵转置矩阵
float4x4 WorldITXf : WorldInverseTranspose < string UIWidget="None"; >;
//物体空间-》裁剪空间
float4x4 WvpXf : WorldViewProjection < string UIWidget="None"; >;
//物体矩阵：物体空间-》世界矩阵
float4x4 WorldXf : World < string UIWidget="None"; >;

float4x4 WorldIXf : WorldInverse < string UIWidget="None"; >;
//观察矩阵：世界空间-》观察空间
float3x3 ViewXf : View < string UIWidget="None"; >;
//投影矩阵：观察空间-》裁剪空间
float4x4 ProjectionXf : Projection < string UIWidget="None"; >;

//观察矩阵 的逆矩阵
float4x4 ViewIXf : ViewInverse < string UIWidget="None"; >;


//-------------------------------max中mapchannl  映射--------------------------
#ifdef _MAX_
int texcoord1 : Texcoord
<
	int Texcoord = 1;
	int MapChannel = 0;
	string UIWidget = "None";
>;


int texcoord2 : Texcoord
<
	int Texcoord = 2;
	int MapChannel = -2;
	string UIWidget = "None";
>;

int texcoord3 : Texcoord
<
	int Texcoord = 3;
	int MapChannel = -1;
	string UIWidget = "None";
>;
#endif

///--------------------灯光参数-----------------
float3 Lamp0Pos : POSITION <
    string Object = "PointLight0";
    string UIName =  "Light Position";
    string Space = "World";
	int refID = 0;
> = {-0.5f,2.0f,1.25f};


#ifdef _MAX_
float3 Lamp0Color : LIGHTCOLOR
<
	int LightRef = 0;
	string UIWidget = "None";
> = float3(1.0f, 1.0f, 1.0f);
#else
float3 Lamp0Color : Specular <
    string UIName =  "Lamp 0";
    string Object = "Pointlight0";
    string UIWidget = "Color";
> = {1.0f,1.0f,1.0f};
#endif


//--------------------------------------------全局变量参数----------------------------------
int k_test <
	string UIName = "Vertex RGBA";
	string UIWidget = "slider";
	float UIMin = 0.0f;
	float UIMax = 5.0f;
	
> = 0;


/////////////////////////////////调整颜色


float4 _MainColor <
    string UIName = "MainColor";
    string UIWidget = "Color";
> = float4(1.0f, 1.0f, 1.0f, 1.0f);


float4 _ShadowColor <
    string UIName = "ShadowColor";
    string UIWidget = "Color";
> = float4(0.35f, 0.35f, 0.5f, 1.0f);


////////////////////////////////第一层高光数据

bool g_specular <
	string UIName = "-------------------specular--------------------------------";
> = true;

float _TangentValue <
    string UIName = "TangentValue";
    string UIWidget = "slider";
    float UIMin = 0.0f;
    float UIMax = 10.0f;
    float UIStep = 0.01;
> = 0.6f;

float4 _specularColor <
    string UIName = "specularColor1";
    string UIWidget = "Color";
> = float4(1.0f, 0.8f, 0.6f, 1.0f);


float _specularStrength <
    string UIName = "specularStrength";
    string UIWidget = "slider";
    float UIMin = 0.0f;
    float UIMax = 500.0f;
    float UIStep = 0.01;
> = 250.0f;



float _Shift1 <
    string UIName = "Shift1";
    string UIWidget = "slider";
    float UIMin = -3.0f;
    float UIMax = 3.0f;
    float UIStep = 0.01;
> = -0.99f;



float _SpecularOffsetA <
    string UIName = "SpecularOffsetA";
    string UIWidget = "slider";
    float UIMin = 0.0f;
    float UIMax = 1.0f;
    float UIStep = 0.01;
> = 0.5f;


bool g_Outline <
	string UIName = "-------------------Outline--------------------------------";
> = true;


///////////////////////////////描边
float outlineSize <
    string UIName = "Outline -> Size";
    string UIWidget = "slider";
    float UIMin = 0.0f;
    float UIMax = 20.0f;
    float UIStep = 0.01;
> = 1.0f;


float4 outlineCol <
    string UIName = "Outline -> Color";
    string UIWidget = "Color";
> = float4(0.0f, 0.0f, 0.0f, 1.0f);

float _AOStrength <
    string UIName = "AOStrength";
    string UIWidget = "slider";
    float UIMin = 0.0f;
    float UIMax = 1.0f;
    float UIStep = 0.01;
> = 0.5f;




bool g_Texture <
	string UIName = "-------------------Enable Texture--------------------------------";
> = true;



//-----------------------------------------------纹理申明---------------------------

Texture2D <float4> g_DiffColorTexture : DiffuseMap< 
	string UIName = "Diffuse Texture";
	string ResourceType = "2D";
	int Texcoord = 0;
	int MapChannel =1;
	
>;



SamplerState g_DiffColorSampler
{
	MinFilter = Linear;
	MagFilter = Linear;
	MipFilter = Linear;
	AddressU = Wrap;
    AddressV = Wrap;
};



Texture2D <float4> g_MaskTexture : DiffuseMap< 
	string UIName = "Mask Texture";
	string ResourceType = "2D";
	int Texcoord = 0;
	int MapChannel =1;
	
>;


SamplerState g_MaskSampler
{
	MinFilter = Linear;
	MagFilter = Linear;
	MipFilter = Linear;
	AddressU = Wrap;
    AddressV = Wrap;
};



Texture2D <float4> g_offsetTexture : DiffuseMap< 
	string UIName = "offset Texture";
	string ResourceType = "2D";
	int Texcoord = 0;
	int MapChannel =1;
	
>;


SamplerState g_offsetSampler
{
	MinFilter = Linear;
	MagFilter = Linear;
	MipFilter = Linear;
	AddressU = Wrap;
    AddressV = Wrap;
};


////------------------------------------------------函数---------------------------------////
// funcion：按照法线方向 偏移 Tangent 方向
float3 ShiftTangent(float3 T,float3 N,float3 shift)
{
  return normalize(T + shift *N);
                
}
// funcion： 获取头发高光
float3 StrandSpecular(float3 T,float3 V,float3 L,float exponent)
{
   float3 H = normalize(L+V);//半角向量h
   float dotTH = dot(T,H);//副切线 和H dot
   float sinTH = sqrt(1-dotTH * dotTH);//sqrt平方根
   float dirAtten = smoothstep(-1, 0, dotTH);
   return dirAtten * pow(sinTH,exponent) * _TangentValue;
             
}


////-------------------------------------------输入结构------------------------------------////
struct appdata {
	float4 Position		: POSITION;
	float3 Normal		: NORMAL;
	float3 Tangent		: TANGENT;
	float3 Binormal		: BINORMAL;
	float2 UV0		    : TEXCOORD0;	
	float3 Colour		: TEXCOORD1;
	float3 Alpha		: TEXCOORD2;
	float3 Illum		: TEXCOORD3;
	float3 UV1		    : TEXCOORD4;

};


////-------------------------------------------光照pass1--------------------------------////
//-----------------------------pass1 输出结构
struct vertexOutput {
    float4 HPosition	: SV_Position;
    float4 UV0		: TEXCOORD0;
    float4 UV1      : TEXCOORD1;
    float3 nDirWS	: TEXCOORD2;
    float4 TtoW0	: TEXCOORD3;
    float4 TtoW1    : TEXCOORD4;
	float4 TtoW2	: TEXCOORD5;
	float3 posWS	: TEXCOORD6;
};

//-----------------------------pass1 顶点着色器
vertexOutput std_VS(appdata IN) {
    vertexOutput OUT = (vertexOutput)0;
    OUT.nDirWS = mul(IN.Normal,WorldITXf).xyz;
   // float3 tDirWS = mul(IN.Tangent,WorldXf).xyz;
    //float3 bDirWS = mul(IN.Binormal,WorldITXf).xyz;
    float4 Po = float4(IN.Position.xyz,1);
    float3 Pw = mul(Po,WorldXf).xyz;
    OUT.HPosition = mul(Po,WvpXf);
	OUT.posWS = mul(IN.Position, WorldXf);
	
	//顶点色与切线副切线 语义有冲突模型如果有顶点色，就会影响，暂时只试出来这样自己算一下切线数据，看起来效果没问题
	float3 tDirWS = mul(IN.Tangent,WorldITXf).xyz;
    //float3 bDirWS = mul(IN.Binormal,WorldITXf).xyz;
    //float3 bDirWS = mul(cross(OUT.nDirWS,tDirWS), WorldIXf).xyz;
    float3 bDirWS = IN.Binormal;
	

	OUT.TtoW0 = float4(tDirWS.x, bDirWS.x, OUT.nDirWS.x, OUT.posWS.x);
    OUT.TtoW1 = float4(tDirWS.y, bDirWS.y, OUT.nDirWS.y, OUT.posWS.y);
    OUT.TtoW2 = float4(tDirWS.z, bDirWS.z, OUT.nDirWS.z, OUT.posWS.z);
	
 	float4 colour;
   	colour.rgb = IN.Colour * IN.Illum;
 
   	colour.a = IN.Alpha.x;

   	OUT.UV0.z = colour.r;
   	OUT.UV0.a = colour.g;
  	OUT.UV1.z = colour.b;
   	OUT.UV1.a = colour.a;


	OUT.UV0.xy = IN.UV0.xy;
   	OUT.UV1.xy = IN.UV1.xy;

    return OUT;
}

//-----------------------------pass1 像素着色器

float4 std_PS(vertexOutput IN) : SV_Target {
    //准备基本数据
    float3 diffContrib;
    float3 specContrib;
    float3 lDirWS = normalize(Lamp0Pos -IN.posWS);
    float3 vDirWS = normalize(ViewIXf[3].xyz - IN.posWS);
    float3 nDirWS = normalize(IN.nDirWS);
    
    //构建新的T,B
    float3 posWS = float3(IN.TtoW0.w, IN.TtoW1.w, IN.TtoW2.w);   
    float3 tDirWS = normalize(float3(IN.TtoW0.x, IN.TtoW1.x, IN.TtoW2.x));
    float3 bDirWS = normalize(float3(IN.TtoW0.y, IN.TtoW1.y, IN.TtoW2.y));
    
    
	float4 vertColour = float4(IN.UV0.z,IN.UV0.w,IN.UV1.z,IN.UV1.w);
		
	float3 hDirWS = normalize(vDirWS + lDirWS);	
	float nDotl = saturate(dot(nDirWS,lDirWS)) *0.5 +0.5;
	float nDotv = saturate(dot(nDirWS,vDirWS));	
	
	//准备纹理数据
    float3 diffTexColor = g_DiffColorTexture.Sample(g_DiffColorSampler, IN.UV0.xy);
    float3 offsetTexColor = g_offsetTexture.Sample(g_offsetSampler, IN.UV0.xy);
    float3 MaskTexColor = g_MaskTexture.Sample(g_MaskSampler, IN.UV0.xy);
    
    
    //--------------------------------------明暗漫反射-----------------------//
    //明暗
    
    float aoMask = MaskTexColor.g;
    float3 aocolor = lerp( _ShadowColor ,  _MainColor,lerp(_AOStrength,1,step(0.5,aoMask *2)) );
    float lerpValue = smoothstep(0.48,0.52,nDotl);
    //float shadow = lerp(-0.8,  1, nDotl * aoMask *2);
    //float shadowMod = pow(saturate(shadow),0.25);
    //颜色
    float3 diffuse = lerp(_ShadowColor,aocolor,lerpValue);



    //-----------------------各向异性高光------------------------------------//
    //切线偏移方向强度
    float offsetT = lerp(0,_SpecularOffsetA ,offsetTexColor.g);
    float3 t1 = ShiftTangent(bDirWS,nDirWS,_Shift1 + offsetT);
        
    //高光权重
    float3 spec1 = StrandSpecular(t1, vDirWS, lDirWS, _specularStrength) *_specularColor;

    //高光遮罩
    float specularMask = MaskTexColor.r;
    float3 spec1Mod = spec1 * nDotl * specularMask;
 

    //-------------------------------------输出
    //合并颜色
    float3 merge = diffuse +  spec1Mod;
    float3 pixelColor = merge;   

    if (k_test == 1.0)
	{
        pixelColor = vertColour.r;
    }
    if (k_test == 2.0)
	{
	
        pixelColor = vertColour.g;
    }
	
    if (k_test == 3.0)
	{
	
        pixelColor = vertColour.b;
    }
	
	if (k_test == 4.0)
	{
	
        pixelColor = vertColour.a;
    }

    if (k_test == 5.0)
	{

        pixelColor = vertColour.rgb;
    }
    
    if (k_test == 0.0)
    {
    	
           return float4(pixelColor,1);
    }
   

    return float4(pixelColor,1);
}


////---------------------------------------描边pass0-------------------------------------////
 
//-----------------------------pass0描边 输出结构
struct outlineOutput
{
    float4 posCS : SV_Position;
    

};
//-----------------------------pass0描边 顶点色器
outlineOutput outline_VS(appdata IN)
{
    
    outlineOutput OUT = (outlineOutput)0;
    //vertex -》 裁剪空间
    float4 po = float4(IN.Position.xyz,1);
    OUT.posCS = mul(po,WvpXf);

    //normal: world ->世界空间
    float3 nDirWS = mul(IN.Normal,WorldITXf).xyz;

    //世界空间 ->观察空间
    float3 nDirVS = mul(nDirWS,ViewXf);
    //观察 -> 裁剪 -> NDC
    float4 nDirVS4 = float4(nDirVS,1);
    float4 nDirCS = normalize(mul(nDirVS4,ProjectionXf));

    //屏幕
    float4 NearUpperRight = mul(float4(1,1,0,1),ProjectionXf);

    float Aspect = abs(NearUpperRight.y / NearUpperRight.x);
    nDirCS.x *= Aspect;

   
    OUT.posCS.xy = OUT.posCS.xy + nDirCS.xy *  outlineSize * 0.1 *IN.Colour.r;
    return OUT;   
}
//-----------------------------pass0描边 像素着色器
float4 outline_PS(outlineOutput IN) : SV_Target
{
    return outlineCol;

}
////-------------------------------------pass 相关渲染标签设置------------------------------------////


RasterizerState RS_CullFront
{
    CullMode = Front;
};

RasterizerState RS_CullBack
{
    CullMode = Back;
};


////----------------------------设置双PASS------------------------------////
fxgroup dx11
{
technique11 Main_11 <
	string Script = "Pass=p0; Pass=p1";
> {
    //-------------pass 0 

    pass p0 <
    string Script = "Draw=outline;";
    > 
    {   
        SetRasterizerState(RS_CullFront);
        SetVertexShader(CompileShader(vs_5_0,outline_VS()));
        SetGeometryShader( NULL );
    	SetPixelShader(CompileShader(ps_5_0,outline_PS()));
    }

	pass p1 <
	string Script = "Draw=geometry;";
    > 
    {   
        SetRasterizerState(RS_CullBack);
        SetVertexShader(CompileShader(vs_5_0,std_VS()));
        SetGeometryShader( NULL );
		SetPixelShader(CompileShader(ps_5_0,std_PS()));
    }
    
    //-------------------pass1
    
  }
}
fxgroup dx10
{
technique10 Main_10 <
	string Script = "Pass=p0;";
> {
	pass p0 <
	string Script = "Draw=geometry;";
    > 
    {
        SetVertexShader(CompileShader(vs_4_0,std_VS()));
        SetGeometryShader( NULL );
		SetPixelShader(CompileShader(ps_4_0,std_PS()));
    }
    
    
}
}

