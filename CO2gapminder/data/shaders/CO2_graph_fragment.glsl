in vec2 TexCoord;
uniform float uv_fade;
uniform float alpha;
uniform int uv_simulationtimeDays;
uniform sampler2D countryLabels;
uniform sampler2D Numbers;
uniform sampler2D co2Lab;
uniform sampler2D gdpLab;
uniform sampler2D co2pcData;
uniform sampler2D co2totData;
uniform sampler2D gdpData;
uniform int showMask;
uniform bool breadCrumbs;
uniform float highlight;
out vec4 fragColor;

void main(void)
{
    vec4 yearColor = vec4(1.0,1.0,1.0,1.0);
    vec4 labelColor = vec4(1.0,1.0,1.0,0.0);
	float CO2pcMaxVal=25.;
	float CO2totMaxVal=10000000.;
	float GDPpcMaxVal=60000.;
	int yearDigits[4]=int[](1,9,5,0);
	vec4 colorlist[4]=vec4[](vec4(0.2,0.3,1.0,1.0),vec4(1.0,0.2,0.3,1.0),vec4(1.0,1.0,0.0,1.0),vec4(0.2,1.0,0.2,1.0));
	int countryColors[11]=int[](3,2,1,1,3,1,2,1,0,2,2);
	float labelOffset[11]=float[](1.0,1.0,-0.95,-0.75,1.0,1.0,1.0,1.0,1.0,1.0,1.0);
	float years = clamp(uv_simulationtimeDays/365.25+1970.,1950.,2011.999);
	
	// Draw background
	fragColor=vec4(0.5,0.5,0.5,0.5);
	
	// Draw Labels;
	float yTop=0.6;
	float yBottom=0.95;
	float yLeft=0.35;
	float yRight=0.85;
	yearDigits[0]=int(years/1000.);
	yearDigits[1]=int(mod(years,1000)/100.);
	yearDigits[2]=int(mod(years,100)/10.);
	yearDigits[3]=int(mod(years,10));
	if ((gl_FrontFacing ? TexCoord[0] : 1- TexCoord[0])>yLeft&&(gl_FrontFacing ? TexCoord[0] : 1- TexCoord[0])<yRight&&TexCoord[1]>yTop&&TexCoord[1]<yBottom){
		int iDigit=int(4.0*((gl_FrontFacing ? TexCoord[0] : 1- TexCoord[0])-yLeft)/(yRight-yLeft));
		vec4 digitColor=textureGrad(Numbers, 
		vec2(yearDigits[iDigit]*0.1+0.1*mod(4.*((gl_FrontFacing ? TexCoord[0] : 1- TexCoord[0])-yLeft)/(yRight-yLeft),1.),
			(TexCoord[1]-yTop)/(yBottom-yTop)),vec2(0),vec2(0));
		fragColor=mix(fragColor,digitColor,digitColor.a);
	}
	if ((gl_FrontFacing ? TexCoord[0] : 1- TexCoord[0])<0.1&&TexCoord[1]>0.4&&TexCoord[1]<0.8){
		vec4 labelColor=texture(co2Lab, 
		vec2((gl_FrontFacing ? TexCoord[0] : 1- TexCoord[0])/0.1,(TexCoord[1]-0.4)/0.4));
		fragColor=mix(fragColor,labelColor,labelColor.a);
	}
	if (TexCoord[1]<0.16&&(gl_FrontFacing ? TexCoord[0] : 1- TexCoord[0])>0.3&&(gl_FrontFacing ? TexCoord[0] : 1- TexCoord[0])<0.8){
		vec4 labelColor=texture(gdpLab, 
		vec2(((gl_FrontFacing ? TexCoord[0] : 1- TexCoord[0])-0.3)/0.5,TexCoord[1]/0.16));
		fragColor=mix(fragColor,labelColor,labelColor.a);
	}
	float yearFrag = mix(1950.0,2012.0,(gl_FrontFacing ? TexCoord[0] : 1- TexCoord[0]));
	if (!gl_FrontFacing) yearFrag = mix(2012.0,1950.0,(gl_FrontFacing ? TexCoord[0] : 1- TexCoord[0]));
	float yearCoord = clamp((years-1950.)/(2012.-1950.),0.,1.);
    float countryCoord = 0.5/11.;
	vec4 CO2pcColor,CO2totColor; 
	vec4 GDPColor;
    float CO2pc,CO2tot;
    float GDP;
    float size=0.1;
	float circleBorder=0.001;
	float labelWidth=0.125;
	float labelHeight=0.04;
	float spotDist = 0.0;
	float minCO2 = 1000000000.;
	
	//Draw breadcrumbs
	if (breadCrumbs){
		float crumbYear=int(years)-0.5;
		float crumbCoord; 
		while (crumbYear > 1950.0){
			crumbCoord = clamp((crumbYear-1950.)/(2012.-1950.),0.,1.);
			for (int i=0; i<11; i++) {
			    int maskBit=int(pow(2,i));
				if ((showMask&maskBit)>0){
					countryCoord = (i+0.5)/11.;
					CO2pcColor = texture(co2pcData,vec2(crumbCoord,1.-countryCoord));
					GDPColor = texture(gdpData,vec2(crumbCoord,1.-countryCoord));
					CO2totColor = texture(co2totData,vec2(crumbCoord,1.-countryCoord));
					CO2pc =CO2pcColor.r+CO2pcColor.g/256.+CO2pcColor.b/(256.*256.);
					CO2tot =CO2totColor.r+CO2totColor.g/256.+CO2totColor.b/(256.*256.);
					GDP =GDPColor.r+GDPColor.g/256.+GDPColor.b/(256.*256.);
					spotDist=sqrt((TexCoord[1]-CO2pc)*0.25*(TexCoord[1]-CO2pc)
							   +((gl_FrontFacing ? TexCoord[0] : 1- TexCoord[0])-GDP)*((gl_FrontFacing ? TexCoord[0] : 1- TexCoord[0])-GDP));
					if (spotDist < size*sqrt(CO2tot) /*&& CO2tot < minCO2*/) {
					  yearColor=colorlist[countryColors[i]];
					  yearColor.a=highlight;
					  fragColor=mix(fragColor,yearColor,yearColor.a);;
					  //minCO2 = CO2tot;
					} else if (spotDist-(size*sqrt(CO2tot))<circleBorder /*&& CO2tot < minCO2*/){
					  fragColor=mix(fragColor,vec4(0.2,0.2,0.2,1.0),highlight);
					  //minCO2 = CO2tot;
					}
				}
			}
			crumbYear-=1.0;
		}
	}
	
	//Draw current bubbles and country labels
	circleBorder*=2.;
	for (int i=0; i<11; i++) {
		int maskBit=int(pow(2,i));
		countryCoord = (i+0.5)/11.;
		CO2pcColor = texture(co2pcData,vec2(yearCoord,1.-countryCoord));
		GDPColor = texture(gdpData,vec2(yearCoord,1.-countryCoord));
		CO2totColor = texture(co2totData,vec2(yearCoord,1.-countryCoord));
		CO2pc =CO2pcColor.r+CO2pcColor.g/256.+CO2pcColor.b/(256.*256.);
		CO2tot =CO2totColor.r+CO2totColor.g/256.+CO2totColor.b/(256.*256.);
		GDP =GDPColor.r+GDPColor.g/256.+GDPColor.b/(256.*256.);
		spotDist=sqrt((TexCoord[1]-CO2pc)*0.25*(TexCoord[1]-CO2pc)
				   +((gl_FrontFacing ? TexCoord[0] : 1- TexCoord[0])-GDP)*((gl_FrontFacing ? TexCoord[0] : 1- TexCoord[0])-GDP));
		if (spotDist < size*sqrt(CO2tot) && CO2tot < minCO2) {
		  yearColor=colorlist[countryColors[i]];
		  if ((showMask&maskBit)==0&&showMask!=0) {yearColor.a=1.-highlight;}
		  fragColor=mix(fragColor,yearColor,1-highlight);;
		  minCO2 = CO2tot;
		} else if (spotDist-(size*sqrt(CO2tot))<circleBorder && CO2tot < minCO2){
		  fragColor=mix(fragColor,vec4(0.0,0.0,0.0,1.0),0.75);
		  minCO2 = CO2tot;
		}
		if ((CO2pc-TexCoord[1])>2.*labelOffset[i]*size*sqrt(CO2tot) && (CO2pc-TexCoord[1])<(2.*labelOffset[i]*size*sqrt(CO2tot)+labelHeight) && abs(GDP-(gl_FrontFacing ? TexCoord[0] : 1- TexCoord[0]))<(labelWidth/2.) ){
		int labelNum =i;
		if (i==1&&years<1992.0){labelNum=11;}
		labelColor=texture(countryLabels,vec2(0.5+((gl_FrontFacing ? TexCoord[0] : 1- TexCoord[0])-GDP)/labelWidth,
		          1.-((CO2pc-TexCoord[1])-2.*labelOffset[i]*size*sqrt(CO2tot)) /(12.*labelHeight)-labelNum/12.));
			fragColor=mix(fragColor,labelColor,labelColor.a);
		}
	}	
	fragColor.a=alpha*uv_fade;
}
