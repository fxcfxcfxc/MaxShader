
string ParamID = "0x003";


//// UN-TWEAKABLES - AUTOMATICALLY-TRACKED TRANSFORMS ////////////////

//世界矩阵的逆矩阵转置矩阵
float4x4 WorldITXf : WorldInverseTranspose < string UIWidget="None"; >;
//物体空间-》裁剪空间
float4x4 WvpXf : WorldViewProjection < string UIWidget="None"; >;
//物体矩阵：物体空间-》世界矩阵
float4x4 WorldXf : World < string UIWidget="None"; >;
//观察矩阵：世界空间-》观察空间
float3x3 ViewXf : View < string UIWidget="None"; >;
//投影矩阵：观察空间-》裁剪空间
float4x4 ProjectionXf : Projection < string UIWidget="None"; >;

//观察矩阵 的逆矩阵
float4x4 ViewIXf : ViewInverse < string UIWidget="None"; >;

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

//// TWEAKABLE PARAMETERS ////////////////////

/// Point Lamp 0 ////////////
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


//------------------------------------参数-----------------------
int k_test <
	string UIName = "Vertex RGBA";
	string UIWidget = "slider";
	float UIMin = 0.0f;
	float UIMax = 4.0f;
	
> = 0; 




float ShadowRange <
    string UIName = "Shadow -> Range";
    string UIWidget = "slider";
    float UIMin = 0.0f;
    float UIMax = 1.0f;
    float UIStep = 0.01;
> = 0.5f;


float4 outlineCol <
    string UIName = "Outline -> Color";
    string UIWidget = "Color";
> = float4(0.0f, 0.0f, 0.0f, 1.0f);

float outlineSize <
    string UIName = "Outline -> Size";
    string UIWidget = "slider";
    float UIMin = 0.0f;
    float UIMax = 20.0f;
    float UIStep = 0.01;
> = 1.0f;






bool g_OneColor <
	string UIName = "-------------------Enable OneColor----------------------";
> = true;


float4 OneColor <
    string UIName = "One -> Color";
    string UIWidget = "Color";
> = float4(0.8f, 0.8f, 0.4f, 1.0f);

float4 ShadowCol <
    string UIName = "Shadow -> Color";
    string UIWidget = "Color";
> = float4(0.5f, 0.5f, 0.5f, 1.0f);



bool g_Texture <
	string UIName = "-------------------Enable Texture--------------------------------";
> = true;



//------------------------纹理申明---------------

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





Texture2D <float4> g_SssTexture : DiffuseMap< 
	string UIName = "SSS Texture";
	string ResourceType = "2D";
	int Texcoord = 0;
	int MapChannel =1;
	
>;


SamplerState g_SssSampler
{
	MinFilter = Linear;
	MagFilter = Linear;
	MipFilter = Linear;
	AddressU = Wrap;
    AddressV = Wrap;
};



//输入结构
struct appdata {
	float4 Position		: POSITION;
	float3 Normal		: NORMAL;
	float3 Tangent		: TANGENT;
	float3 Binormal		: BINORMAL;
	float2 UV0		: TEXCOORD0;	
	float3 Colour		: TEXCOORD1;
	float3 Alpha		: TEXCOORD2;
	float3 Illum		: TEXCOORD3;
	float3 UV1		: TEXCOORD4;
	float3 UV2		: TEXCOORD5;
	float3 UV3		: TEXCOORD6;
	float3 UV4		: TEXCOORD7;
};

//---光照pass1
//-----------------------------pass1 输出结构----------------------------------
struct vertexOutput {
    float4 HPosition	: SV_Position;
    float4 UV0		: TEXCOORD0;
    // The following values are passed in "World" coordinates since
    //   it tends to be the most flexible and easy for handling
    //   reflections, sky lighting, and other "global" effects.
    float3 LightVec	: TEXCOORD1;
    float3 WorldNormal	: TEXCOORD2;
    float3 WorldTangent	: TEXCOORD3;
    float3 WorldBinormal : TEXCOORD4;
    float3 WorldView	: TEXCOORD5;
	float4 UV1		: TEXCOORD6;
	float4 UV2		: TEXCOORD7;
	float4 wPos		: TEXCOORD8;
};

//-----------------------------pass1 顶点着色器---------------------------
vertexOutput std_VS(appdata IN) {
    vertexOutput OUT = (vertexOutput)0;
    OUT.WorldNormal = mul(IN.Normal,WorldITXf).xyz;
    OUT.WorldTangent = mul(IN.Tangent,WorldITXf).xyz;
    OUT.WorldBinormal = mul(IN.Binormal,WorldITXf).xyz;
    float4 Po = float4(IN.Position.xyz,1);
    float3 Pw = mul(Po,WorldXf).xyz;
    OUT.LightVec = (Lamp0Pos - Pw);
    OUT.WorldView = normalize(ViewIXf[3].xyz - Pw);
    OUT.HPosition = mul(Po,WvpXf);
	OUT.wPos = mul(IN.Position, WorldXf);
	
// UV bindings
// Encode the color data
 	float4 colour;
   	colour.rgb = IN.Colour * IN.Illum;
   	colour.a = IN.Alpha.x;
   	OUT.UV0.z = colour.r;
   	OUT.UV0.a = colour.g;
  	OUT.UV1.z = colour.b;
   	OUT.UV1.a = colour.a;

// Pass through the UVs
	OUT.UV0.xy = IN.UV0.xy;
   	OUT.UV1.xy = IN.UV1.xy;
   	OUT.UV2.xyz = IN.UV2.xyz;
// 	OUT.UV3 = OUT.UV3;
// 	OUT.UV4 = OUT.UV4;
    return OUT;
}

//-----------------------------pass1 像素着色器--------------------------

float4 std_PS(vertexOutput IN) : SV_Target {
    //基本数据准备
    float3 diffContrib;
    float3 specContrib;
    float3 lDirWS = normalize(IN.LightVec);
    float3 vDirWS = normalize(IN.WorldView);//观察（相机）方向
    float3 nDirWS = normalize(IN.WorldNormal);
    float3 tDirWS = normalize(IN.WorldTangent);
    float3 bDirws = normalize(IN.WorldBinormal);
	float4 vertColour = float4(IN.UV0.z,IN.UV0.w,IN.UV1.z,IN.UV1.w);	
	//采样贴图数据，ILMTexture R：高光强度（区域）  G：阴影阈值    B：高光形状
    float3 diffColor = g_DiffColorTexture.Sample(g_DiffColorSampler,IN.UV0.xy);
    float3 sssColor = g_SssTexture.Sample(g_SssSampler,IN.UV0.xy);
    float2 filpUV = float2(-IN.UV0.x,IN.UV0.y);
    float3 filpSssColor = g_SssTexture.Sample(g_SssSampler,filpUV);
    //顶点B ：外描边  ， 顶点R ：AO阈值
    
    float3 upVec = float3(0,0,1);
    float3 frontVec = float3(0,-1,0);
    float3 rightVec = float3(1,0,0);

    float changeShadowTex = dot(lDirWS.xy,rightVec);
    float3 faceShadow = step(0,changeShadowTex) * sssColor + step(changeShadowTex,0) * filpSssColor;

    float shadowYZ = 1- (dot(lDirWS.xy,frontVec)*0.5 +0.5);

    float stepShadow =  step(shadowYZ,faceShadow);
    float3 faceColor  = lerp(diffColor * 0.5 ,diffColor,stepShadow);

    //-------------------------------颜色合并----------------------------
    float3 pixelColor = faceColor;
    if(g_OneColor)
    {
        pixelColor = lerp(ShadowCol,OneColor,stepShadow);

    }

    
           
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
    
    if (k_test == 0.0)
    {
    	
           return float4(pixelColor,1);
    }
   

    return float4(pixelColor,1);
}


//---描边pass0
 
//-----------------------------pass0描边 输出结构-----------------------
struct outlineOutput
{
    float4 posCS : SV_Position;
    

};
//-----------------------------pass0描边 顶点色器-----------------------
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

   
    OUT.posCS.xy = OUT.posCS.xy + nDirCS.xy *  outlineSize * 0.1 *IN.Colour.b;
   
    return OUT;   
}
//-----------------------------pass0描边 像素着色器---------------------
float4 outline_PS(outlineOutput IN) : SV_Target
{   
    
    return outlineCol;

}
//--------------------------------pass 相关标签设置-----------------------


RasterizerState RS_CullFront
{
    CullMode = Front;
};

RasterizerState RS_CullBack
{
    CullMode = Back;
};


//----------------------------设置双PASS------------------------------
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
/////////////////////////////////////// eof //
