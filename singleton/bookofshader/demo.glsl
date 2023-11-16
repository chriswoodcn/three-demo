precision mediump float;

uniform float u_time;
uniform vec2 u_resolution;
#define PI 3.1415926
highp float rand_1to1(highp float x){
    // 0 ~ 1
    return(fract(sin(x*123.93742)*10000.)+1.)/2.;
}

highp float rand_2to1(vec2 uv){
    // 0 - 1
    const highp float a=12.9898,b=78.233,c=43758.5453;
    highp float dt=dot(uv.xy,vec2(a,b)),sn=mod(dt,PI);
    return fract(sin(sn)*c);
}

highp vec2 rand_2to2(vec2 uv){
    float a=rand_2to1(uv);
    float b=(rand_1to1(a)+1.)/2.;
    return vec2(a,b);
}

float circle(vec2 uv,vec2 center,float d){
    return length(uv-center)-d;
}

float cloud(vec2 uv,vec2 center,float d){
    float step=1.2;
    float c1=circle(uv,vec2(center.x-d*.9*1.*step,center.y),d*.9);
    float c2=circle(uv,vec2(center.x-d*.8*2.*step,center.y),d*.8);
    float c3=circle(uv,vec2(center.x,center.y),d);
    
    float c4=circle(uv,vec2(center.x+d*.9*1.*step,center.y),d*.9);
    float c5=circle(uv,vec2(center.x+d*.8*2.*step,center.y),d*.8);
    return min(c5,min(c4,min(c3,min(c1,c2))));
}

float water(vec2 uv,float A,float w,float p,float offset){
    return uv.y-A*sin(w*uv.x+p)-offset;
}

float sinNorm(float a){
    return sin(a)*.5+.5;
}

#define CLOUD_POS_LEN 5
vec2 cloudPos[CLOUD_POS_LEN];

void main(){
    cloudPos[0]=vec2(sin(.6+u_time*.5)*.5+.5,.5);
    cloudPos[1]=vec2(sin(.85+u_time*.3)*.5+.5,.65);
    cloudPos[2]=vec2(sin(.15+u_time*.1)*.5+.5,.7);
    cloudPos[3]=vec2(sin(.38+u_time*.2)*.5+.5,.8);
    cloudPos[4]=vec2(sin(.8+u_time*.2)*.5+.5,.9);
    vec3 cloudCol=vec3(1.,1.,1.);
    vec3 shadowCol=vec3(.5);
    vec3 riverCol=vec3(.1059,.4157,.8824);
    vec3 riverCol2=vec3(.2078,.3686,.8941);
    vec3 riverCol3=vec3(.3686,.8824,.9098);
    vec3 sunInnerCol=vec3(1.);
    vec3 sunLightCol=vec3(.9529,1.,.5451);
    
    vec2 v_uv=gl_FragCoord.xy/u_resolution;
    float asp=u_resolution.x/u_resolution.y;
    vec2 uv=v_uv;
    if(asp<1.){
        uv.y=(uv.y-.5)/asp+.5;
    }else{
        uv.x=(uv.x-.5)*asp+.5;
    }
    vec3 backCol1=vec3(.2078,.7216,1.);
    vec3 backCol2=vec3(.9804,1.,.4314);
    float gradient=1.-smoothstep(-.3,1.,uv.y);
    // drawCloud
    float cloudSDF=cloud(uv,cloudPos[0],.04);
    float cloudShadowSDF=cloud(uv,cloudPos[0]-vec2(0.,.007),.04);
    for(int i=1;i<CLOUD_POS_LEN;i++){
        cloudSDF=min(cloudSDF,cloud(uv,cloudPos[i],.04));
        cloudShadowSDF=min(cloudShadowSDF,cloud(uv,cloudPos[i]-vec2(0.,.007),.04));
    }
    float cdClound=smoothstep(.002,-.002,cloudSDF);
    float cdCloudShadow=smoothstep(.01,-.01,cloudShadowSDF);
    
    // draw river
    float riverFrontSDF=water(uv,.01*sinNorm(u_time*.8)+.02,27.,u_time*3.,.05);
    float riverMidSDF=water(uv,.034,17.,u_time*1.5,.07);
    float riverBackSDF2=water(uv,.03,12.,0.+u_time*.75,.1);
    float cdRiverFront=smoothstep(.002,-.001,riverFrontSDF);
    float cdWaveFront=smoothstep(.01,.005,abs(riverFrontSDF));
    float frontShadow=smoothstep(.015,.001,riverFrontSDF);
    
    float cdRiverMid=smoothstep(.002,-.001,riverMidSDF);
    float cdWaveMid=smoothstep(.01,.005,abs(riverMidSDF));
    float midShadow=smoothstep(.015,.001,riverMidSDF);
    float cdRiverBack=smoothstep(.002,-.001,riverBackSDF2);
    float cdWaveBack=smoothstep(.01,.005,abs(riverBackSDF2));
    float backShadow=smoothstep(.015,.001,riverBackSDF2);
    
    // draw sun
    vec2 sunCenter=vec2(pow(sinNorm(u_time*.1),2.),1.-abs(pow(sinNorm(u_time*.1),2.)*2.-1.));
    float sunSDF=circle(uv,sunCenter,.1);
    float cdSun=smoothstep(.001,0.,sunSDF);
    float cdSunLight=smoothstep(.2,-0.,sunSDF);
    cdSunLight=pow(cdSunLight,2.+5.*(sin(u_time*1.)*.5+.5));
    
    vec3 col=mix(backCol1,backCol2,gradient);
    
    col=mix(col,sunLightCol,cdSunLight);
    col=mix(col,sunInnerCol,cdSun);
    
    col=mix(col,shadowCol,backShadow);
    col=mix(col,riverCol2,cdRiverBack);
    col=mix(col,vec3(1.),cdWaveBack);
    
    col=mix(col,shadowCol,midShadow);
    col=mix(col,riverCol,cdRiverMid);
    col=mix(col,vec3(1.),cdWaveMid);
    
    col=mix(col,shadowCol,frontShadow);
    col=mix(col,riverCol3,cdRiverFront);
    col=mix(col,vec3(1.),cdWaveFront);
    
    col=mix(col,shadowCol,cdCloudShadow);
    col=mix(col,cloudCol,cdClound);
    
    gl_FragColor=vec4(col,1.);
}