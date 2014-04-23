#ifdef SHADER_MODEL // make safe to include in resource file to enforce dependency

float4 GetConfig()
{
	return float4( %s, %s, %s, 1.0 );
}

#if SHADER_MODEL >= 0x400

Texture2D Texture;
SamplerState Sampler;

cbuffer cb0
{
	float2 ZrH;
	float hH;
	float fSaturation;
};

struct PS_INPUT
{
	float4 p : SV_Position;
	float2 t : TEXCOORD0;
};

float4 ps_main0(PS_INPUT input) : SV_Target0
{
	clip(frac(input.t.y * hH) - 0.5);

	float4 c1 = Texture.Sample(Sampler, input.t);
	float4 c2 = c1;
	float4 c3 = c1;
	float4 c4 = c1;
	float4 c5 = c1;
	float4 c0=GetConfig();

	//Gens32 Filter Copyrights 2004-2011 DarkDancer
	/////////////////////////////////////////////////////////////////////
	float gY=c1.r*0.299+c1.g*0.587+c1.b*0.114;

	if( c0.z>0 )
	{
		float4 fA0 = Texture.Sample(Sampler, input.t - ZrH);
		float4 fA1 = Texture.Sample(Sampler, input.t + ZrH);

		//c2 = min( fA0,fA1 );
		//c3 = max( fA0,fA1 );

		////c2 = (fA0+fA1+fA2+fA3)/4;
		////c3 = (fA0+fA1+fA2+fA3)/4;

		//float gMin = c2.r*0.299+c2.g*0.587+c2.b*0.114; 
		//float gMax = c3.r*0.299+c3.g*0.587+c3.b*0.114;

		//if( gY < (gMin+gMax)/2 )
		//	c1 = c1*gY/gMin;
		//if( gY>(gMin+gMax)/2 )
		//	c1 = c1*gY/gMax;
		//if( gY<(gMin+gMax)/2 )
		//	c1=c1*0.975;
		//else
		//	c1=c1*1.025;
		c2 =( max( fA0,fA1 )*2+c1)/3;
		float gYC = c2.r*0.299+c2.g*0.587+c2.b*0.114; 
		c1=(c1*gY/gYC);

		//c1 = c2;
		//float gY = c3.r*0.299+c3.g*0.587+c3.b*0.114;
		gY = c1.r*0.299+c1.g*0.587+c1.b*0.114; 
	}
	////////////////////////////////////////////////////////////////////////
	//float gY = c1.r*0.299+c1.g*0.587+c1.b*0.114;

	if( fSaturation<0 )
	{
		return c1;
	}

	if( fSaturation>4 && fSaturation<6 )	//5黑白模式。
	{
		c2.b = gY;
		c2.g = gY;
		c2.r = gY;
		//亮度调节;

		c2 = c0.x*c2;
		return c2;
	}

	//float fat = c2.g/gY*0.245272;
	//if( c2.g<(c2.r+c2.b)*0.5 )
	//	fat = -c2.g/gY*0.245272;

	float fat = 0;

	if( fSaturation>9 && fSaturation<11 )	//G mode.
	{
		//c2.b = gY+1.403*gCr+0.344*gCb;
		//c2.g = gY*(1.0+(gCb+gCr))- 0.344*gCb + 0.344*gCr;
		//c2.r = gY+1.770*gCb+0.714*gCr;

		//c2.b = ( c2.b + c1.b )/2;
		//c2.g = max( c2.g , c1.g );
		//c2.r = ( c2.r + c1.r )/2;

		//c2.b = gY*0.309724+0.690276*c1.b;
		//c2.g = gY*1.59656 - 0.245272*c1.r  - 0.351288*c1.b;
		//c2.r = 1.26201*c1.r-0.26201*gY;

		//Good color.
		//fat = -c2.b/gY*c0.y;
		//c2.b = gY*(0.309724+fat)+(0.690276-fat)*c1.b;
		//fat = c2.g/gY*c0.y;
		//c2.g = gY*(1.59656+fat) - (0.245272+fat*0.245272/0.59656)*c1.r  - (0.351288+fat*0.351288/0.59656)*c1.b;
		//fat = c2.r/gY*c0.y;
		//c2.r = (1.26201+fat)*c1.r-(0.26201+fat)*gY;

		//蓝色取向。
		fat = -c2.b/gY*c0.y;
		c3.b = gY*(0.309724+fat)+(0.690276-fat)*c1.b;
		fat = c2.g/gY*c0.y;
		c3.g = gY*(1.59656+fat-(0.351288+fat*0.351288/0.59656)*2) - (0.245272+fat*0.245272/0.59656)*c1.r  + (0.351288+fat*0.351288/0.59656)*c1.b;
		fat = c2.r/gY*c0.y;
		c3.r = (1.26201+fat)*c1.r-(0.26201+fat)*gY;

		//红色取向
		c4.b = c3.b;	//简化B值。
		fat = c2.r/gY*c0.y;
		c4.r = gY*(1.59656+fat) - (0.245272+fat*0.245272/0.59656)*c1.g  - (0.351288+fat*0.351288/0.59656)*c1.b;
		fat = c2.g/gY*c0.y;
		c4.g = (1.26201+fat)*c1.g-(0.26201+fat)*gY;

		c2.b = min(c3.b,c4.b);
		c2.g = max(c3.g,c4.g);
		c2.r = (c3.r+c4.r)/2;

		//亮度调节;
		return c0.x*c2;
	}

	if( fSaturation>0 && fSaturation<2 )	//Advance模式。
	{
		//c1 = c2;
		//float gY = c3.r*0.299+c3.g*0.587+c3.b*0.114;
		gY = c1.b*0.299+c1.r*0.587+c1.g*0.114; 

		//9超彩模式。
		fat = -(c1.b/gY)*c0.y;
		c3.b = gY*(0.309724+fat)+(0.690276-fat)*c1.b;
		//fat = sin(c1.g/gY)*c0.y;
		//c2.g = gY*(1.59656+fat) - (0.245272+fat*0.245272/0.59656)*c1.r  - (0.351288+fat*0.351288/0.59656)*c1.b;
		fat = (c1.r/gY)*c0.y;
		c3.r = (1.26201+fat)*c1.r-(0.26201+fat)*gY;

		c3=c2;

		gY = c1.r*0.299+c1.b*0.587+c1.g*0.114; 
		//9超彩模式。
		fat = -(c1.b/gY)*c0.y;
		c4.b = gY*(0.309724+fat)+(0.690276-fat)*c1.b;
		//fat = sin(c1.g/gY)*c0.y;
		//c2.g = gY*(1.59656+fat) - (0.245272+fat*0.245272/0.59656)*c1.r  - (0.351288+fat*0.351288/0.59656)*c1.b;
		fat = (c1.r/gY)*c0.y;
		c4.r = (1.26201+fat)*c1.r-(0.26201+fat)*gY;

		c2.b = (c3.b+c4.b)/2;
		c2.g = c1.g;
		c2.r = (c3.r+c4.r)/2;

		//c2=(c2+gY)/2;
		//亮度调节;
		return c0.x*c2;
	}

	if( fSaturation>2 && fSaturation<4 )	//3,柔合模式
	{
		//蓝色取向
		fat = -c1.b/gY*c0.y;
		c3.r = gY*(0.309724+fat)+(0.690276-fat)*c1.r;
		fat = c1.g/gY*c0.y;
		c3.g = gY*(1.59656+fat-(0.351288+fat*0.351288/0.59656)*2) + (0.245272+fat*0.245272/0.59656)*c1.b  - (0.351288+fat*0.351288/0.59656)*c1.r;
		fat = c1.b/gY*c0.y;
		c3.b = (1.26201+fat)*c1.b-(0.26201+fat)*gY;

		//红色取向
		fat = -c1.b/gY*c0.y;
		c4.b = gY*(0.309724+fat)+(0.690276-fat)*c1.b;
		fat = c1.r/gY*c0.y;
		c4.r = gY*(1.59656+fat) - (0.245272+fat*0.245272/0.59656)*c1.g  - (0.351288+fat*0.351288/0.59656)*c1.b;
		fat = c1.g/gY*c0.y;
		c4.g = (1.26201+fat)*c1.g-(0.26201+fat)*gY;

		c2.b = min(c3.b,c4.b);
		c2.g = max(c3.g,c4.g);
		c2.r = (c3.r+c4.r)/2;

		//c2=(c2+gY)/2;
		//亮度调节;
		return c0.x*c2;
	}


	//9超彩模式。
	fat = -sin(c2.b/gY)*c0.y;
	c2.b = gY*(0.309724+fat)+(0.690276-fat)*c1.b;
	fat = sin(c2.g/gY)*c0.y;
	c2.g = gY*(1.59656+fat) - (0.245272+fat*0.245272/0.59656)*c1.r  - (0.351288+fat*0.351288/0.59656)*c1.b;
	fat = sin(c2.r/gY)*c0.y;
	c2.r = (1.26201+fat)*c1.r-(0.26201+fat)*gY;

	//亮度调节;
	return c0.x*c2;
}

float4 ps_main1(PS_INPUT input) : SV_Target0
{
	clip(0.5 - frac(input.t.y * hH));

	//return Texture.Sample(Sampler, input.t);

	float4 c1 = Texture.Sample(Sampler, input.t);
	float4 c2 = c1;
	float4 c3 = c1;
	float4 c4 = c1;
	float4 c5 = c1;

	float4 c0=GetConfig();

	//Gens32 Filter Copyrights 2004-2011 DarkDancer
	/////////////////////////////////////////////////////////////////////
	float gY=c1.r*0.299+c1.g*0.587+c1.b*0.114;

	if( c0.z>0 )
	{
		float4 fA0 = Texture.Sample(Sampler, input.t - ZrH);
		float4 fA1 = Texture.Sample(Sampler, input.t + ZrH);

		//c2 = min( fA0,fA1 );
		//c3 = max( fA0,fA1 );

		////c2 = (fA0+fA1+fA2+fA3)/4;
		////c3 = (fA0+fA1+fA2+fA3)/4;

		//float gMin = c2.r*0.299+c2.g*0.587+c2.b*0.114; 
		//float gMax = c3.r*0.299+c3.g*0.587+c3.b*0.114;

		//if( gY < (gMin+gMax)/2 )
		//	c1 = c1*gY/gMin;
		//if( gY>(gMin+gMax)/2 )
		//	c1 = c1*gY/gMax;
		//if( gY<(gMin+gMax)/2 )
		//	c1=c1*0.975;
		//else
		//	c1=c1*1.025;
		c2 =( max( fA0,fA1 )*2+c1)/3;
		float gYC = c2.r*0.299+c2.g*0.587+c2.b*0.114; 
		c1=(c1*gY/gYC);

		//c1 = c2;
		//float gY = c3.r*0.299+c3.g*0.587+c3.b*0.114;
		gY = c1.r*0.299+c1.g*0.587+c1.b*0.114; 
	}
	////////////////////////////////////////////////////////////////////////
	//float gY = c1.r*0.299+c1.g*0.587+c1.b*0.114;

	if( fSaturation<0 )
	{
		return c1;
	}

	if( fSaturation>4 && fSaturation<6 )	//5黑白模式。
	{
		c2.b = gY;
		c2.g = gY;
		c2.r = gY;
		//亮度调节;

		c2 = c0.x*c2;
		return c2;
	}
	//float fat = c2.g/gY*0.245272;
	//if( c2.g<(c2.r+c2.b)*0.5 )
	//	fat = -c2.g/gY*0.245272;

	float fat = 0;

	if( fSaturation>9 && fSaturation<11 )	//G mode.
	{
		//c2.b = gY+1.403*gCr+0.344*gCb;
		//c2.g = gY*(1.0+(gCb+gCr))- 0.344*gCb + 0.344*gCr;
		//c2.r = gY+1.770*gCb+0.714*gCr;

		//c2.b = ( c2.b + c1.b )/2;
		//c2.g = max( c2.g , c1.g );
		//c2.r = ( c2.r + c1.r )/2;

		//c2.b = gY*0.309724+0.690276*c1.b;
		//c2.g = gY*1.59656 - 0.245272*c1.r  - 0.351288*c1.b;
		//c2.r = 1.26201*c1.r-0.26201*gY;

		//Good color.
		//fat = -c2.b/gY*c0.y;
		//c2.b = gY*(0.309724+fat)+(0.690276-fat)*c1.b;
		//fat = c2.g/gY*c0.y;
		//c2.g = gY*(1.59656+fat) - (0.245272+fat*0.245272/0.59656)*c1.r  - (0.351288+fat*0.351288/0.59656)*c1.b;
		//fat = c2.r/gY*c0.y;
		//c2.r = (1.26201+fat)*c1.r-(0.26201+fat)*gY;

		//蓝色取向。
		fat = -c2.b/gY*c0.y;
		c3.b = gY*(0.309724+fat)+(0.690276-fat)*c1.b;
		fat = c2.g/gY*c0.y;
		c3.g = gY*(1.59656+fat-(0.351288+fat*0.351288/0.59656)*2) - (0.245272+fat*0.245272/0.59656)*c1.r  + (0.351288+fat*0.351288/0.59656)*c1.b;
		fat = c2.r/gY*c0.y;
		c3.r = (1.26201+fat)*c1.r-(0.26201+fat)*gY;

		//红色取向
		c4.b = c3.b;	//简化B值。
		fat = c2.r/gY*c0.y;
		c4.r = gY*(1.59656+fat) - (0.245272+fat*0.245272/0.59656)*c1.g  - (0.351288+fat*0.351288/0.59656)*c1.b;
		fat = c2.g/gY*c0.y;
		c4.g = (1.26201+fat)*c1.g-(0.26201+fat)*gY;

		c2.b = min(c3.b,c4.b);
		c2.g = max(c3.g,c4.g);
		c2.r = (c3.r+c4.r)/2;

		//亮度调节;
		return c0.x*c2;
	}

	if( fSaturation>0 && fSaturation<2 )	//Advance模式。
	{
		//c1 = c2;
		//float gY = c3.r*0.299+c3.g*0.587+c3.b*0.114;
		gY = c1.b*0.299+c1.r*0.587+c1.g*0.114; 

		//9超彩模式。
		fat = -(c1.b/gY)*c0.y;
		c3.b = gY*(0.309724+fat)+(0.690276-fat)*c1.b;
		//fat = sin(c1.g/gY)*c0.y;
		//c2.g = gY*(1.59656+fat) - (0.245272+fat*0.245272/0.59656)*c1.r  - (0.351288+fat*0.351288/0.59656)*c1.b;
		fat = (c1.r/gY)*c0.y;
		c3.r = (1.26201+fat)*c1.r-(0.26201+fat)*gY;

		c3=c2;

		gY = c1.r*0.299+c1.b*0.587+c1.g*0.114; 
		//9超彩模式。
		fat = -(c1.b/gY)*c0.y;
		c4.b = gY*(0.309724+fat)+(0.690276-fat)*c1.b;
		//fat = sin(c1.g/gY)*c0.y;
		//c2.g = gY*(1.59656+fat) - (0.245272+fat*0.245272/0.59656)*c1.r  - (0.351288+fat*0.351288/0.59656)*c1.b;
		fat = (c1.r/gY)*c0.y;
		c4.r = (1.26201+fat)*c1.r-(0.26201+fat)*gY;

		c2.b = (c3.b+c4.b)/2;
		c2.g = c1.g;
		c2.r = (c3.r+c4.r)/2;

		//c2=(c2+gY)/2;
		//亮度调节;
		return c0.x*c2;
	}

	if( fSaturation>2 && fSaturation<4 )	//3,柔合模式
	{
		//蓝色取向
		fat = -c1.b/gY*c0.y;
		c3.r = gY*(0.309724+fat)+(0.690276-fat)*c1.r;
		fat = c1.g/gY*c0.y;
		c3.g = gY*(1.59656+fat-(0.351288+fat*0.351288/0.59656)*2) + (0.245272+fat*0.245272/0.59656)*c1.b  - (0.351288+fat*0.351288/0.59656)*c1.r;
		fat = c1.b/gY*c0.y;
		c3.b = (1.26201+fat)*c1.b-(0.26201+fat)*gY;

		//红色取向
		fat = -c1.b/gY*c0.y;
		c4.b = gY*(0.309724+fat)+(0.690276-fat)*c1.b;
		fat = c1.r/gY*c0.y;
		c4.r = gY*(1.59656+fat) - (0.245272+fat*0.245272/0.59656)*c1.g  - (0.351288+fat*0.351288/0.59656)*c1.b;
		fat = c1.g/gY*c0.y;
		c4.g = (1.26201+fat)*c1.g-(0.26201+fat)*gY;

		c2.b = min(c3.b,c4.b);
		c2.g = max(c3.g,c4.g);
		c2.r = (c3.r+c4.r)/2;

		//c2=(c2+gY)/2;
		//亮度调节;
		return c0.x*c2;
	}


	//9超彩模式。
	fat = -sin(c2.b/gY)*c0.y;
	c2.b = gY*(0.309724+fat)+(0.690276-fat)*c1.b;
	fat = sin(c2.g/gY)*c0.y;
	c2.g = gY*(1.59656+fat) - (0.245272+fat*0.245272/0.59656)*c1.r  - (0.351288+fat*0.351288/0.59656)*c1.b;
	fat = sin(c2.r/gY)*c0.y;
	c2.r = (1.26201+fat)*c1.r-(0.26201+fat)*gY;

	//亮度调节;
	return c0.x*c2;
}

float4 ps_main2(PS_INPUT input) : SV_Target0
{
	float4 c0 = Texture.Sample(Sampler, input.t - ZrH);
	float4 c1 = Texture.Sample(Sampler, input.t);
	float4 c2 = Texture.Sample(Sampler, input.t + ZrH);

	return (c0 + c1 * 2 + c2) / 4;
}

float4 ps_main3(PS_INPUT input) : SV_Target0
{
	//return Texture.Sample(Sampler, input.t);

	float4 c1 = Texture.Sample(Sampler, input.t);
	float4 c2 = c1;
	float4 c3 = c1;
	float4 c4 = c1;
	float4 c5 = c1;

	float4 c0=GetConfig();


	//Gens32 Filter Copyrights 2004-2011 DarkDancer
	/////////////////////////////////////////////////////////////////////
	float gY=c1.r*0.299+c1.g*0.587+c1.b*0.114;

	if( c0.z>0 )
	{
		float4 fA0 = Texture.Sample(Sampler, input.t - ZrH);
		float4 fA1 = Texture.Sample(Sampler, input.t + ZrH);

		//c2 = min( fA0,fA1 );
		//c3 = max( fA0,fA1 );

		////c2 = (fA0+fA1+fA2+fA3)/4;
		////c3 = (fA0+fA1+fA2+fA3)/4;

		//float gMin = c2.r*0.299+c2.g*0.587+c2.b*0.114; 
		//float gMax = c3.r*0.299+c3.g*0.587+c3.b*0.114;

		//if( gY < (gMin+gMax)/2 )
		//	c1 = c1*gY/gMin;
		//if( gY>(gMin+gMax)/2 )
		//	c1 = c1*gY/gMax;
		//if( gY<(gMin+gMax)/2 )
		//	c1=c1*0.975;
		//else
		//	c1=c1*1.025;
		c2 =( max( fA0,fA1 )*2+c1)/3;
		float gYC = c2.r*0.299+c2.g*0.587+c2.b*0.114; 
		c1=(c1*gY/gYC);

		//c1 = c2;
		//float gY = c3.r*0.299+c3.g*0.587+c3.b*0.114;
		gY = c1.r*0.299+c1.g*0.587+c1.b*0.114; 
	}
	////////////////////////////////////////////////////////////////////////
	//float gY = c1.r*0.299+c1.g*0.587+c1.b*0.114;

	if( fSaturation<0 )
	{
		return c1;
	}

	if( fSaturation>4 && fSaturation<6 )	//5黑白模式。
	{
		c2.b = gY;
		c2.g = gY;
		c2.r = gY;
		//亮度调节;

		c2 = c0.x*c2;
		return c2;
	}
	//float fat = c2.g/gY*0.245272;
	//if( c2.g<(c2.r+c2.b)*0.5 )
	//	fat = -c2.g/gY*0.245272;

	float fat = 0;

	if( fSaturation>9 && fSaturation<11 )	//G mode.
	{
		//c2.b = gY+1.403*gCr+0.344*gCb;
		//c2.g = gY*(1.0+(gCb+gCr))- 0.344*gCb + 0.344*gCr;
		//c2.r = gY+1.770*gCb+0.714*gCr;

		//c2.b = ( c2.b + c1.b )/2;
		//c2.g = max( c2.g , c1.g );
		//c2.r = ( c2.r + c1.r )/2;

		//c2.b = gY*0.309724+0.690276*c1.b;
		//c2.g = gY*1.59656 - 0.245272*c1.r  - 0.351288*c1.b;
		//c2.r = 1.26201*c1.r-0.26201*gY;

		//Good color.
		//fat = -c2.b/gY*c0.y;
		//c2.b = gY*(0.309724+fat)+(0.690276-fat)*c1.b;
		//fat = c2.g/gY*c0.y;
		//c2.g = gY*(1.59656+fat) - (0.245272+fat*0.245272/0.59656)*c1.r  - (0.351288+fat*0.351288/0.59656)*c1.b;
		//fat = c2.r/gY*c0.y;
		//c2.r = (1.26201+fat)*c1.r-(0.26201+fat)*gY;

		//蓝色取向。
		fat = -c2.b/gY*c0.y;
		c3.b = gY*(0.309724+fat)+(0.690276-fat)*c1.b;
		fat = c2.g/gY*c0.y;
		c3.g = gY*(1.59656+fat-(0.351288+fat*0.351288/0.59656)*2) - (0.245272+fat*0.245272/0.59656)*c1.r  + (0.351288+fat*0.351288/0.59656)*c1.b;
		fat = c2.r/gY*c0.y;
		c3.r = (1.26201+fat)*c1.r-(0.26201+fat)*gY;

		//红色取向
		c4.b = c3.b;	//简化B值。
		fat = c2.r/gY*c0.y;
		c4.r = gY*(1.59656+fat) - (0.245272+fat*0.245272/0.59656)*c1.g  - (0.351288+fat*0.351288/0.59656)*c1.b;
		fat = c2.g/gY*c0.y;
		c4.g = (1.26201+fat)*c1.g-(0.26201+fat)*gY;

		c2.b = min(c3.b,c4.b);
		c2.g = max(c3.g,c4.g);
		c2.r = (c3.r+c4.r)/2;

		//亮度调节;
		return c0.x*c2;
	}

	if( fSaturation>0 && fSaturation<2 )	//Advance模式。
	{
		//c1 = c2;
		//float gY = c3.r*0.299+c3.g*0.587+c3.b*0.114;
		gY = c1.b*0.299+c1.r*0.587+c1.g*0.114; 

		//9超彩模式。
		fat = -(c1.b/gY)*c0.y;
		c3.b = gY*(0.309724+fat)+(0.690276-fat)*c1.b;
		//fat = sin(c1.g/gY)*c0.y;
		//c2.g = gY*(1.59656+fat) - (0.245272+fat*0.245272/0.59656)*c1.r  - (0.351288+fat*0.351288/0.59656)*c1.b;
		fat = (c1.r/gY)*c0.y;
		c3.r = (1.26201+fat)*c1.r-(0.26201+fat)*gY;

		c3=c2;

		gY = c1.r*0.299+c1.b*0.587+c1.g*0.114; 
		//9超彩模式。
		fat = -(c1.b/gY)*c0.y;
		c4.b = gY*(0.309724+fat)+(0.690276-fat)*c1.b;
		//fat = sin(c1.g/gY)*c0.y;
		//c2.g = gY*(1.59656+fat) - (0.245272+fat*0.245272/0.59656)*c1.r  - (0.351288+fat*0.351288/0.59656)*c1.b;
		fat = (c1.r/gY)*c0.y;
		c4.r = (1.26201+fat)*c1.r-(0.26201+fat)*gY;

		c2.b = (c3.b+c4.b)/2;
		c2.g = c1.g;
		c2.r = (c3.r+c4.r)/2;

		//c2=(c2+gY)/2;
		//亮度调节;
		return c0.x*c2;
	}

	if( fSaturation>2 && fSaturation<4 )	//3,柔合模式
	{
		//蓝色取向
		fat = -c1.b/gY*c0.y;
		c3.r = gY*(0.309724+fat)+(0.690276-fat)*c1.r;
		fat = c1.g/gY*c0.y;
		c3.g = gY*(1.59656+fat-(0.351288+fat*0.351288/0.59656)*2) + (0.245272+fat*0.245272/0.59656)*c1.b  - (0.351288+fat*0.351288/0.59656)*c1.r;
		fat = c1.b/gY*c0.y;
		c3.b = (1.26201+fat)*c1.b-(0.26201+fat)*gY;

		//红色取向
		fat = -c1.b/gY*c0.y;
		c4.b = gY*(0.309724+fat)+(0.690276-fat)*c1.b;
		fat = c1.r/gY*c0.y;
		c4.r = gY*(1.59656+fat) - (0.245272+fat*0.245272/0.59656)*c1.g  - (0.351288+fat*0.351288/0.59656)*c1.b;
		fat = c1.g/gY*c0.y;
		c4.g = (1.26201+fat)*c1.g-(0.26201+fat)*gY;

		c2.b = min(c3.b,c4.b);
		c2.g = max(c3.g,c4.g);
		c2.r = (c3.r+c4.r)/2;

		//c2=(c2+gY)/2;
		//亮度调节;
		return c0.x*c2;
	}


	//9超彩模式。
	fat = -sin(c1.b/gY)*c0.y;
	c2.b = gY*(0.309724+fat)+(0.690276-fat)*c1.b;
	fat = sin(c1.g/gY)*c0.y;
	c2.g = gY*(1.59656+fat) - (0.245272+fat*0.245272/0.59656)*c1.r  - (0.351288+fat*0.351288/0.59656)*c1.b;
	fat = sin(c1.r/gY)*c0.y;
	c2.r = (1.26201+fat)*c1.r-(0.26201+fat)*gY;

	//亮度调节;
	return c0.x*c2;
}

#elif SHADER_MODEL <= 0x300

sampler s0 : register(s0);

float4 Params1 : register(c0);

#define ZrH (Params1.xy)
#define hH  (Params1.z)
#define fSaturation (Params1.w)

float4 ps_main0(float2 tex : TEXCOORD0) : COLOR
{
	clip(frac(tex.y * hH) - 0.5);

	//return tex2D(s0, tex);

	float4 c1 = tex2D(s0, tex);
	float4 c2 = c1;
	float4 c3 = c1;
	float4 c4 = c1;
	float4 c5 = c1;

	float4 c0=GetConfig();

	//Gens32 Filter Copyrights 2004-2011 DarkDancer
	/////////////////////////////////////////////////////////////////////
	float gY=c1.r*0.299+c1.g*0.587+c1.b*0.114;

	if( c0.z>0 )
	{
		float4 fA0 = tex2D(s0, tex - ZrH);
		float4 fA1 = tex2D(s0, tex + ZrH);

		//c2 = min( fA0,fA1 );
		//c3 = max( fA0,fA1 );

		////c2 = (fA0+fA1+fA2+fA3)/4;
		////c3 = (fA0+fA1+fA2+fA3)/4;

		//float gMin = c2.r*0.299+c2.g*0.587+c2.b*0.114; 
		//float gMax = c3.r*0.299+c3.g*0.587+c3.b*0.114;

		//if( gY < (gMin+gMax)/2 )
		//	c1 = c1*gY/gMin;
		//if( gY>(gMin+gMax)/2 )
		//	c1 = c1*gY/gMax;
		//if( gY<(gMin+gMax)/2 )
		//	c1=c1*0.975;
		//else
		//	c1=c1*1.025;
		c2 =( max( fA0,fA1 )*2+c1)/3;
		float gYC = c2.r*0.299+c2.g*0.587+c2.b*0.114; 
		c1=(c1*gY/gYC);

		//c1 = c2;
		//float gY = c3.r*0.299+c3.g*0.587+c3.b*0.114;
		gY = c1.r*0.299+c1.g*0.587+c1.b*0.114; 
	}
	////////////////////////////////////////////////////////////////////////
	//float gY = c1.r*0.299+c1.g*0.587+c1.b*0.114;

	if( fSaturation<0 )
	{
		return c1;
	}

	if( fSaturation>4 && fSaturation<6 )	//5黑白模式。
	{
		c2.b = gY;
		c2.g = gY;
		c2.r = gY;
		//亮度调节;

		c2 = c0.x*c2;
		return c2;
	}
	//float fat = c2.g/gY*0.245272;
	//if( c2.g<(c2.r+c2.b)*0.5 )
	//	fat = -c2.g/gY*0.245272;

	float fat = 0;

	if( fSaturation>9 && fSaturation<11 )	//G mode.
	{
		//c2.b = gY+1.403*gCr+0.344*gCb;
		//c2.g = gY*(1.0+(gCb+gCr))- 0.344*gCb + 0.344*gCr;
		//c2.r = gY+1.770*gCb+0.714*gCr;

		//c2.b = ( c2.b + c1.b )/2;
		//c2.g = max( c2.g , c1.g );
		//c2.r = ( c2.r + c1.r )/2;

		//c2.b = gY*0.309724+0.690276*c1.b;
		//c2.g = gY*1.59656 - 0.245272*c1.r  - 0.351288*c1.b;
		//c2.r = 1.26201*c1.r-0.26201*gY;

		//Good color.
		//fat = -c2.b/gY*c0.y;
		//c2.b = gY*(0.309724+fat)+(0.690276-fat)*c1.b;
		//fat = c2.g/gY*c0.y;
		//c2.g = gY*(1.59656+fat) - (0.245272+fat*0.245272/0.59656)*c1.r  - (0.351288+fat*0.351288/0.59656)*c1.b;
		//fat = c2.r/gY*c0.y;
		//c2.r = (1.26201+fat)*c1.r-(0.26201+fat)*gY;

		//蓝色取向。
		fat = -c2.b/gY*c0.y;
		c3.b = gY*(0.309724+fat)+(0.690276-fat)*c1.b;
		fat = c2.g/gY*c0.y;
		c3.g = gY*(1.59656+fat-(0.351288+fat*0.351288/0.59656)*2) - (0.245272+fat*0.245272/0.59656)*c1.r  + (0.351288+fat*0.351288/0.59656)*c1.b;
		fat = c2.r/gY*c0.y;
		c3.r = (1.26201+fat)*c1.r-(0.26201+fat)*gY;

		//红色取向
		c4.b = c3.b;	//简化B值。
		fat = c2.r/gY*c0.y;
		c4.r = gY*(1.59656+fat) - (0.245272+fat*0.245272/0.59656)*c1.g  - (0.351288+fat*0.351288/0.59656)*c1.b;
		fat = c2.g/gY*c0.y;
		c4.g = (1.26201+fat)*c1.g-(0.26201+fat)*gY;

		c2.b = min(c3.b,c4.b);
		c2.g = max(c3.g,c4.g);
		c2.r = (c3.r+c4.r)/2;

		//亮度调节;
		return c0.x*c2;
	}

	if( fSaturation>0 && fSaturation<2 )	//Advance模式。
	{
		//c1 = c2;
		//float gY = c3.r*0.299+c3.g*0.587+c3.b*0.114;
		gY = c1.b*0.299+c1.r*0.587+c1.g*0.114; 

		//9超彩模式。
		fat = -(c1.b/gY)*c0.y;
		c3.b = gY*(0.309724+fat)+(0.690276-fat)*c1.b;
		//fat = sin(c1.g/gY)*c0.y;
		//c2.g = gY*(1.59656+fat) - (0.245272+fat*0.245272/0.59656)*c1.r  - (0.351288+fat*0.351288/0.59656)*c1.b;
		fat = (c1.r/gY)*c0.y;
		c3.r = (1.26201+fat)*c1.r-(0.26201+fat)*gY;

		c3=c2;

		gY = c1.r*0.299+c1.b*0.587+c1.g*0.114; 
		//9超彩模式。
		fat = -(c1.b/gY)*c0.y;
		c4.b = gY*(0.309724+fat)+(0.690276-fat)*c1.b;
		//fat = sin(c1.g/gY)*c0.y;
		//c2.g = gY*(1.59656+fat) - (0.245272+fat*0.245272/0.59656)*c1.r  - (0.351288+fat*0.351288/0.59656)*c1.b;
		fat = (c1.r/gY)*c0.y;
		c4.r = (1.26201+fat)*c1.r-(0.26201+fat)*gY;

		c2.b = (c3.b+c4.b)/2;
		c2.g = c1.g;
		c2.r = (c3.r+c4.r)/2;

		//c2=(c2+gY)/2;
		//亮度调节;
		return c0.x*c2;
	}

	if( fSaturation>2 && fSaturation<4 )	//3,柔合模式
	{
		//蓝色取向
		fat = -c1.b/gY*c0.y;
		c3.r = gY*(0.309724+fat)+(0.690276-fat)*c1.r;
		fat = c1.g/gY*c0.y;
		c3.g = gY*(1.59656+fat-(0.351288+fat*0.351288/0.59656)*2) + (0.245272+fat*0.245272/0.59656)*c1.b  - (0.351288+fat*0.351288/0.59656)*c1.r;
		fat = c1.b/gY*c0.y;
		c3.b = (1.26201+fat)*c1.b-(0.26201+fat)*gY;

		//红色取向
		fat = -c1.b/gY*c0.y;
		c4.b = gY*(0.309724+fat)+(0.690276-fat)*c1.b;
		fat = c1.r/gY*c0.y;
		c4.r = gY*(1.59656+fat) - (0.245272+fat*0.245272/0.59656)*c1.g  - (0.351288+fat*0.351288/0.59656)*c1.b;
		fat = c1.g/gY*c0.y;
		c4.g = (1.26201+fat)*c1.g-(0.26201+fat)*gY;

		c2.b = min(c3.b,c4.b);
		c2.g = max(c3.g,c4.g);
		c2.r = (c3.r+c4.r)/2;

		//c2=(c2+gY)/2;
		//亮度调节;
		return c0.x*c2;
	}


	//9超彩模式。
	fat = -sin(c2.b/gY)*c0.y;
	c2.b = gY*(0.309724+fat)+(0.690276-fat)*c1.b;
	fat = sin(c2.g/gY)*c0.y;
	c2.g = gY*(1.59656+fat) - (0.245272+fat*0.245272/0.59656)*c1.r  - (0.351288+fat*0.351288/0.59656)*c1.b;
	fat = sin(c2.r/gY)*c0.y;
	c2.r = (1.26201+fat)*c1.r-(0.26201+fat)*gY;

	//亮度调节;
	return c0.x*c2;
}

float4 ps_main1(float2 tex : TEXCOORD0) : COLOR
{
	clip(0.5 - frac(tex.y * hH));

	float4 c1 = tex2D(s0, tex);
	float4 c2 = c1;
	float4 c3 = c1;
	float4 c4 = c1;
	float4 c5 = c1;

	float4 c0=GetConfig();

	//Gens32 Filter Copyrights 2004-2011 DarkDancer
	/////////////////////////////////////////////////////////////////////
	float gY=c1.r*0.299+c1.g*0.587+c1.b*0.114;

	if( c0.z>0 )
	{
		float4 fA0 = tex2D(s0, tex - ZrH);
		float4 fA1 = tex2D(s0, tex + ZrH);

		//c2 = min( fA0,fA1 );
		//c3 = max( fA0,fA1 );

		////c2 = (fA0+fA1+fA2+fA3)/4;
		////c3 = (fA0+fA1+fA2+fA3)/4;

		//float gMin = c2.r*0.299+c2.g*0.587+c2.b*0.114; 
		//float gMax = c3.r*0.299+c3.g*0.587+c3.b*0.114;

		//if( gY < (gMin+gMax)/2 )
		//	c1 = c1*gY/gMin;
		//if( gY>(gMin+gMax)/2 )
		//	c1 = c1*gY/gMax;
		//if( gY<(gMin+gMax)/2 )
		//	c1=c1*0.975;
		//else
		//	c1=c1*1.025;
		c2 =( max( fA0,fA1 )*2+c1)/3;
		float gYC = c2.r*0.299+c2.g*0.587+c2.b*0.114; 
		c1=(c1*gY/gYC);

		//c1 = c2;
		//float gY = c3.r*0.299+c3.g*0.587+c3.b*0.114;
		gY = c1.r*0.299+c1.g*0.587+c1.b*0.114; 
	}
	////////////////////////////////////////////////////////////////////////
	//float gY = c1.r*0.299+c1.g*0.587+c1.b*0.114;


	if( fSaturation<0 )
	{
		return c1;
	}

	if( fSaturation>4 && fSaturation<6 )	//5黑白模式。
	{
		c2.b = gY;
		c2.g = gY;
		c2.r = gY;
		//亮度调节;

		c2 = c0.x*c2;
		return c2;
	}
	//float fat = c2.g/gY*0.245272;
	//if( c2.g<(c2.r+c2.b)*0.5 )
	//	fat = -c2.g/gY*0.245272;

	float fat = 0;

	if( fSaturation>9 && fSaturation<11 )	//G mode.
	{
		//c2.b = gY+1.403*gCr+0.344*gCb;
		//c2.g = gY*(1.0+(gCb+gCr))- 0.344*gCb + 0.344*gCr;
		//c2.r = gY+1.770*gCb+0.714*gCr;

		//c2.b = ( c2.b + c1.b )/2;
		//c2.g = max( c2.g , c1.g );
		//c2.r = ( c2.r + c1.r )/2;

		//c2.b = gY*0.309724+0.690276*c1.b;
		//c2.g = gY*1.59656 - 0.245272*c1.r  - 0.351288*c1.b;
		//c2.r = 1.26201*c1.r-0.26201*gY;

		//Good color.
		//fat = -c2.b/gY*c0.y;
		//c2.b = gY*(0.309724+fat)+(0.690276-fat)*c1.b;
		//fat = c2.g/gY*c0.y;
		//c2.g = gY*(1.59656+fat) - (0.245272+fat*0.245272/0.59656)*c1.r  - (0.351288+fat*0.351288/0.59656)*c1.b;
		//fat = c2.r/gY*c0.y;
		//c2.r = (1.26201+fat)*c1.r-(0.26201+fat)*gY;

		//蓝色取向。
		fat = -c2.b/gY*c0.y;
		c3.b = gY*(0.309724+fat)+(0.690276-fat)*c1.b;
		fat = c2.g/gY*c0.y;
		c3.g = gY*(1.59656+fat-(0.351288+fat*0.351288/0.59656)*2) - (0.245272+fat*0.245272/0.59656)*c1.r  + (0.351288+fat*0.351288/0.59656)*c1.b;
		fat = c2.r/gY*c0.y;
		c3.r = (1.26201+fat)*c1.r-(0.26201+fat)*gY;

		//红色取向
		c4.b = c3.b;	//简化B值。
		fat = c2.r/gY*c0.y;
		c4.r = gY*(1.59656+fat) - (0.245272+fat*0.245272/0.59656)*c1.g  - (0.351288+fat*0.351288/0.59656)*c1.b;
		fat = c2.g/gY*c0.y;
		c4.g = (1.26201+fat)*c1.g-(0.26201+fat)*gY;

		c2.b = min(c3.b,c4.b);
		c2.g = max(c3.g,c4.g);
		c2.r = (c3.r+c4.r)/2;

		//亮度调节;
		return c0.x*c2;
	}

	if( fSaturation>0 && fSaturation<2 )	//Advance模式。
	{
		//c1 = c2;
		//float gY = c3.r*0.299+c3.g*0.587+c3.b*0.114;
		gY = c1.b*0.299+c1.r*0.587+c1.g*0.114; 

		//9超彩模式。
		fat = -(c1.b/gY)*c0.y;
		c3.b = gY*(0.309724+fat)+(0.690276-fat)*c1.b;
		//fat = sin(c1.g/gY)*c0.y;
		//c2.g = gY*(1.59656+fat) - (0.245272+fat*0.245272/0.59656)*c1.r  - (0.351288+fat*0.351288/0.59656)*c1.b;
		fat = (c1.r/gY)*c0.y;
		c3.r = (1.26201+fat)*c1.r-(0.26201+fat)*gY;

		c3=c2;

		gY = c1.r*0.299+c1.b*0.587+c1.g*0.114; 
		//9超彩模式。
		fat = -(c1.b/gY)*c0.y;
		c4.b = gY*(0.309724+fat)+(0.690276-fat)*c1.b;
		//fat = sin(c1.g/gY)*c0.y;
		//c2.g = gY*(1.59656+fat) - (0.245272+fat*0.245272/0.59656)*c1.r  - (0.351288+fat*0.351288/0.59656)*c1.b;
		fat = (c1.r/gY)*c0.y;
		c4.r = (1.26201+fat)*c1.r-(0.26201+fat)*gY;

		c2.b = (c3.b+c4.b)/2;
		c2.g = c1.g;
		c2.r = (c3.r+c4.r)/2;

		//c2=(c2+gY)/2;
		//亮度调节;
		return c0.x*c2;
	}

	if( fSaturation>2 && fSaturation<4 )	//3,柔合模式
	{
		//蓝色取向
		fat = -c1.b/gY*c0.y;
		c3.r = gY*(0.309724+fat)+(0.690276-fat)*c1.r;
		fat = c1.g/gY*c0.y;
		c3.g = gY*(1.59656+fat-(0.351288+fat*0.351288/0.59656)*2) + (0.245272+fat*0.245272/0.59656)*c1.b  - (0.351288+fat*0.351288/0.59656)*c1.r;
		fat = c1.b/gY*c0.y;
		c3.b = (1.26201+fat)*c1.b-(0.26201+fat)*gY;

		//红色取向
		fat = -c1.b/gY*c0.y;
		c4.b = gY*(0.309724+fat)+(0.690276-fat)*c1.b;
		fat = c1.r/gY*c0.y;
		c4.r = gY*(1.59656+fat) - (0.245272+fat*0.245272/0.59656)*c1.g  - (0.351288+fat*0.351288/0.59656)*c1.b;
		fat = c1.g/gY*c0.y;
		c4.g = (1.26201+fat)*c1.g-(0.26201+fat)*gY;

		c2.b = min(c3.b,c4.b);
		c2.g = max(c3.g,c4.g);
		c2.r = (c3.r+c4.r)/2;

		//c2=(c2+gY)/2;
		//亮度调节;
		return c0.x*c2;
	}


	//9超彩模式。
	fat = -sin(c2.b/gY)*c0.y;
	c2.b = gY*(0.309724+fat)+(0.690276-fat)*c1.b;
	fat = sin(c2.g/gY)*c0.y;
	c2.g = gY*(1.59656+fat) - (0.245272+fat*0.245272/0.59656)*c1.r  - (0.351288+fat*0.351288/0.59656)*c1.b;
	fat = sin(c2.r/gY)*c0.y;
	c2.r = (1.26201+fat)*c1.r-(0.26201+fat)*gY;

	//亮度调节;
	return c0.x*c2;
}

float4 ps_main2(float2 tex : TEXCOORD0) : COLOR
{
	float4 c0 = tex2D(s0, tex - ZrH);
	float4 c1 = tex2D(s0, tex);
	float4 c2 = tex2D(s0, tex + ZrH);

	return (c0 + c1 * 2 + c2) / 4;
}

float4 ps_main3(float2 tex : TEXCOORD0) : COLOR
{
	//return tex2D(s0, tex);

	float4 c1 = tex2D(s0, tex);
	float4 c2 = c1;
	float4 c3 = c1;
	float4 c4 = c1;
	float4 c5 = c1;

	float4 c0=GetConfig();

	//Gens32 Filter Copyrights 2004-2011 DarkDancer
	/////////////////////////////////////////////////////////////////////
	float gY=c1.r*0.299+c1.g*0.587+c1.b*0.114;

	if( c0.z>0 )
	{
		float4 fA0 = tex2D(s0, tex - ZrH);
		float4 fA1 = tex2D(s0, tex + ZrH);

		//c2 = min( fA0,fA1 );
		//c3 = max( fA0,fA1 );

		////c2 = (fA0+fA1+fA2+fA3)/4;
		////c3 = (fA0+fA1+fA2+fA3)/4;

		//float gMin = c2.r*0.299+c2.g*0.587+c2.b*0.114; 
		//float gMax = c3.r*0.299+c3.g*0.587+c3.b*0.114;

		//if( gY < (gMin+gMax)/2 )
		//	c1 = c1*gY/gMin;
		//if( gY>(gMin+gMax)/2 )
		//	c1 = c1*gY/gMax;
		//if( gY<(gMin+gMax)/2 )
		//	c1=c1*0.975;
		//else
		//	c1=c1*1.025;
		c2 =( max( fA0,fA1 )*2+c1)/3;
		float gYC = c2.r*0.299+c2.g*0.587+c2.b*0.114; 
		c1=(c1*gY/gYC);

		//c1 = c2;
		//float gY = c3.r*0.299+c3.g*0.587+c3.b*0.114;
		gY = c1.r*0.299+c1.g*0.587+c1.b*0.114; 
	}
	////////////////////////////////////////////////////////////////////////
	//float gY = c1.r*0.299+c1.g*0.587+c1.b*0.114;


	if( fSaturation<0 )
	{
		return c1;
	}

	if( fSaturation>4 && fSaturation<6 )	//5黑白模式。
	{
		c2.b = gY;
		c2.g = gY;
		c2.r = gY;
		//亮度调节;

		c2 = c0.x*c2;
		return c2;
	}
	//float fat = c2.g/gY*0.245272;
	//if( c2.g<(c2.r+c2.b)*0.5 )
	//	fat = -c2.g/gY*0.245272;

	float fat = 0;

	if( fSaturation>9 && fSaturation<11 )	//G mode.
	{
		//c2.b = gY+1.403*gCr+0.344*gCb;
		//c2.g = gY*(1.0+(gCb+gCr))- 0.344*gCb + 0.344*gCr;
		//c2.r = gY+1.770*gCb+0.714*gCr;

		//c2.b = ( c2.b + c1.b )/2;
		//c2.g = max( c2.g , c1.g );
		//c2.r = ( c2.r + c1.r )/2;

		//c2.b = gY*0.309724+0.690276*c1.b;
		//c2.g = gY*1.59656 - 0.245272*c1.r  - 0.351288*c1.b;
		//c2.r = 1.26201*c1.r-0.26201*gY;

		//Good color.
		//fat = -c2.b/gY*c0.y;
		//c2.b = gY*(0.309724+fat)+(0.690276-fat)*c1.b;
		//fat = c2.g/gY*c0.y;
		//c2.g = gY*(1.59656+fat) - (0.245272+fat*0.245272/0.59656)*c1.r  - (0.351288+fat*0.351288/0.59656)*c1.b;
		//fat = c2.r/gY*c0.y;
		//c2.r = (1.26201+fat)*c1.r-(0.26201+fat)*gY;

		//蓝色取向。
		fat = -c2.b/gY*c0.y;
		c3.b = gY*(0.309724+fat)+(0.690276-fat)*c1.b;
		fat = c2.g/gY*c0.y;
		c3.g = gY*(1.59656+fat-(0.351288+fat*0.351288/0.59656)*2) - (0.245272+fat*0.245272/0.59656)*c1.r  + (0.351288+fat*0.351288/0.59656)*c1.b;
		fat = c2.r/gY*c0.y;
		c3.r = (1.26201+fat)*c1.r-(0.26201+fat)*gY;

		//红色取向
		c4.b = c3.b;	//简化B值。
		fat = c2.r/gY*c0.y;
		c4.r = gY*(1.59656+fat) - (0.245272+fat*0.245272/0.59656)*c1.g  - (0.351288+fat*0.351288/0.59656)*c1.b;
		fat = c2.g/gY*c0.y;
		c4.g = (1.26201+fat)*c1.g-(0.26201+fat)*gY;

		c2.b = min(c3.b,c4.b);
		c2.g = max(c3.g,c4.g);
		c2.r = (c3.r+c4.r)/2;

		//亮度调节;
		return c0.x*c2;
	}

	if( fSaturation>0 && fSaturation<2 )	//Advance模式。
	{
		//c1 = c2;
		//float gY = c3.r*0.299+c3.g*0.587+c3.b*0.114;
		gY = c1.b*0.299+c1.r*0.587+c1.g*0.114; 

		//9超彩模式。
		fat = -(c1.b/gY)*c0.y;
		c3.b = gY*(0.309724+fat)+(0.690276-fat)*c1.b;
		//fat = sin(c1.g/gY)*c0.y;
		//c2.g = gY*(1.59656+fat) - (0.245272+fat*0.245272/0.59656)*c1.r  - (0.351288+fat*0.351288/0.59656)*c1.b;
		fat = (c1.r/gY)*c0.y;
		c3.r = (1.26201+fat)*c1.r-(0.26201+fat)*gY;

		c3=c2;

		gY = c1.r*0.299+c1.b*0.587+c1.g*0.114; 
		//9超彩模式。
		fat = -(c1.b/gY)*c0.y;
		c4.b = gY*(0.309724+fat)+(0.690276-fat)*c1.b;
		//fat = sin(c1.g/gY)*c0.y;
		//c2.g = gY*(1.59656+fat) - (0.245272+fat*0.245272/0.59656)*c1.r  - (0.351288+fat*0.351288/0.59656)*c1.b;
		fat = (c1.r/gY)*c0.y;
		c4.r = (1.26201+fat)*c1.r-(0.26201+fat)*gY;

		c2.b = (c3.b+c4.b)/2;
		c2.g = c1.g;
		c2.r = (c3.r+c4.r)/2;

		//c2=(c2+gY)/2;
		//亮度调节;
		return c0.x*c2;
	}

	if( fSaturation>2 && fSaturation<4 )	//3,柔合模式
	{
		//蓝色取向
		fat = -c1.b/gY*c0.y;
		c3.r = gY*(0.309724+fat)+(0.690276-fat)*c1.r;
		fat = c1.g/gY*c0.y;
		c3.g = gY*(1.59656+fat-(0.351288+fat*0.351288/0.59656)*2) + (0.245272+fat*0.245272/0.59656)*c1.b  - (0.351288+fat*0.351288/0.59656)*c1.r;
		fat = c1.b/gY*c0.y;
		c3.b = (1.26201+fat)*c1.b-(0.26201+fat)*gY;

		//红色取向
		fat = -c1.b/gY*c0.y;
		c4.b = gY*(0.309724+fat)+(0.690276-fat)*c1.b;
		fat = c1.r/gY*c0.y;
		c4.r = gY*(1.59656+fat) - (0.245272+fat*0.245272/0.59656)*c1.g  - (0.351288+fat*0.351288/0.59656)*c1.b;
		fat = c1.g/gY*c0.y;
		c4.g = (1.26201+fat)*c1.g-(0.26201+fat)*gY;

		c2.b = min(c3.b,c4.b);
		c2.g = max(c3.g,c4.g);
		c2.r = (c3.r+c4.r)/2;

		//c2=(c2+gY)/2;
		//亮度调节;
		return c0.x*c2;
	}


	//9超彩模式。
	fat = -sin(c2.b/gY)*c0.y;
	c2.b = gY*(0.309724+fat)+(0.690276-fat)*c1.b;
	fat = sin(c2.g/gY)*c0.y;
	c2.g = gY*(1.59656+fat) - (0.245272+fat*0.245272/0.59656)*c1.r  - (0.351288+fat*0.351288/0.59656)*c1.b;
	fat = sin(c2.r/gY)*c0.y;
	c2.r = (1.26201+fat)*c1.r-(0.26201+fat)*gY;

	//亮度调节;
	return c0.x*c2;
}

#endif

#endif
