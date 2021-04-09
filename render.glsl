vec3 RotateX(vec3 v,float rad)
{
    float cos=cos(rad);
    float sin=sin(rad);
    return vec3(v.x,cos*v.y+sin*v.z,-sin*v.y+cos*v.z);
}
vec3 RotateY(vec3 v,float rad)
{
    float cos=cos(rad);
    float sin=sin(rad);
    return vec3(cos*v.x-sin*v.z,v.y,sin*v.x+cos*v.z);
}
vec3 RotateZ(vec3 v,float rad)
{
    float cos=cos(rad);
    float sin=sin(rad);
    return vec3(cos*v.x+sin*v.y,-sin*v.x+cos*v.y,v.z);
}

// from iq
float sdTriangle(in vec2 p,in vec2 p0,in vec2 p1,in vec2 p2)
{
    vec2 e0=p1-p0;
    vec2 e1=p2-p1;
    vec2 e2=p0-p2;
    
    vec2 v0=p-p0;
    vec2 v1=p-p1;
    vec2 v2=p-p2;
    
    vec2 pq0=v0-e0*clamp(dot(v0,e0)/dot(e0,e0),0.,1.);
    vec2 pq1=v1-e1*clamp(dot(v1,e1)/dot(e1,e1),0.,1.);
    vec2 pq2=v2-e2*clamp(dot(v2,e2)/dot(e2,e2),0.,1.);
    
    float s=e0.x*e2.y-e0.y*e2.x;
    vec2 d=min(min(vec2(dot(pq0,pq0),s*(v0.x*e0.y-v0.y*e0.x)),
    vec2(dot(pq1,pq1),s*(v1.x*e1.y-v1.y*e1.x))),
    vec2(dot(pq2,pq2),s*(v2.x*e2.y-v2.y*e2.x)));
    
    return-sqrt(d.x)*sign(d.y);
}

vec3 hash(vec3 p)// replace this by something better. really. do
{
    p=vec3(dot(p,vec3(127.1,311.7,74.7)),
    dot(p,vec3(269.5,183.3,246.1)),
    dot(p,vec3(113.5,271.9,124.6)));
    
    return-1.+2.*fract(sin(p)*43758.5453123);
}

// return value noise (in x) and its derivatives (in yzw)
vec4 noised(in vec3 x)
{
    // grid
    vec3 i=floor(x);
    vec3 w=fract(x);
    
    #if 1
    // quintic interpolant
    vec3 u=w*w*w*(w*(w*6.-15.)+10.);
    vec3 du=30.*w*w*(w*(w-2.)+1.);
    #else
    // cubic interpolant
    vec3 u=w*w*(3.-2.*w);
    vec3 du=6.*w*(1.-w);
    #endif
    
    // gradients
    vec3 ga=hash(i+vec3(0.,0.,0.));
    vec3 gb=hash(i+vec3(1.,0.,0.));
    vec3 gc=hash(i+vec3(0.,1.,0.));
    vec3 gd=hash(i+vec3(1.,1.,0.));
    vec3 ge=hash(i+vec3(0.,0.,1.));
    vec3 gf=hash(i+vec3(1.,0.,1.));
    vec3 gg=hash(i+vec3(0.,1.,1.));
    vec3 gh=hash(i+vec3(1.,1.,1.));
    
    // projections
    float va=dot(ga,w-vec3(0.,0.,0.));
    float vb=dot(gb,w-vec3(1.,0.,0.));
    float vc=dot(gc,w-vec3(0.,1.,0.));
    float vd=dot(gd,w-vec3(1.,1.,0.));
    float ve=dot(ge,w-vec3(0.,0.,1.));
    float vf=dot(gf,w-vec3(1.,0.,1.));
    float vg=dot(gg,w-vec3(0.,1.,1.));
    float vh=dot(gh,w-vec3(1.,1.,1.));
    
    // interpolations
    return vec4(va+u.x*(vb-va)+u.y*(vc-va)+u.z*(ve-va)+u.x*u.y*(va-vb-vc+vd)+u.y*u.z*(va-vc-ve+vg)+u.z*u.x*(va-vb-ve+vf)+(-va+vb+vc-vd+ve-vf-vg+vh)*u.x*u.y*u.z,// value
    ga+u.x*(gb-ga)+u.y*(gc-ga)+u.z*(ge-ga)+u.x*u.y*(ga-gb-gc+gd)+u.y*u.z*(ga-gc-ge+gg)+u.z*u.x*(ga-gb-ge+gf)+(-ga+gb+gc-gd+ge-gf-gg+gh)*u.x*u.y*u.z+// derivatives
    du*(vec3(vb,vc,ve)-va+u.yzx*vec3(va-vb-vc+vd,va-vc-ve+vg,va-vb-ve+vf)+u.zxy*vec3(va-vb-ve+vf,va-vb-vc+vd,va-vc-ve+vg)+u.yzx*u.zxy*(-va+vb+vc-vd+ve-vf-vg+vh)));
}

vec3 fold(vec3 p){
    return vec3(abs(p.x),p.y,abs(p.z));
}

float sdPyramid(in vec3 p,float h){
    vec3 top=vec3(0.);
    //base if above the point
    vec3 base=top+vec3(0.,h,0.);
    float epsilon=.0001;
    vec3 corner;
    vec3 cornerx;
    vec3 cornerz;
    
    float final=100.;
    p=fold(p);
    
    corner=vec3(base.x+h/2.,base.y,base.z+h/2.);
    cornerx=vec3(base.x-h/2.,base.y,base.z+h/2.);
    cornerz=vec3(base.x+h/2.,base.y,base.z-h/2.);
    float d1=sdTriangle(p.xy,top.xy,cornerx.xy,corner.xy);
    float d2=sdTriangle(p.zy,top.zy,cornerz.zy,corner.zy);
    float d=max(d1,d2);
    
    return d;
    
}
float D;
void initD(){
    D=iResolution.y>400.?4.:3.;
}

// calc normal
// signed distance to a pyramid of base 1x1 and height h

// TO speed up:
// replace sdtriangle with wave functions.
vec4 sdSerp(in vec3 p,in float h)
{
    vec3 top=vec3(0.);
    //base if above the point
    vec3 base=top+vec3(0.,h,0.);
    float epsilon=.0001;
    vec3 corner;
    vec3 cornerx;
    vec3 cornerz;
    vec3 norm;
    
    float d1;
    float d2;
    
    float final=100.;
    vec3 prefold=p;
    p=fold(p);
    for(float i=0.;i<D;i++){
        float h2=h/2.+0.;
        corner=vec3(base.x+h2,base.y,base.z+h2);
        cornerx=vec3(base.x-h2,base.y,base.z+h2);
        cornerz=vec3(base.x+h2,base.y,base.z-h2);
        d1=sdTriangle(p.xy,top.xy,cornerx.xy,corner.xy);
        d2=sdTriangle(p.zy,top.zy,cornerz.zy,corner.zy);
        float d=max(d1,d2);
        
        if(d>epsilon){
            return vec4(d,vec3(0.));
        }
        
        float topd=length(p-top);
        float cornerd=length(p-corner);
        
        final=min(final,d);
        // calc normal
        if(final<.0001){
            if(abs(p.y-base.y)-.00005<.0001){
                norm=vec3(0.,1.,0.);
            }else{
                if(p.x>p.z){
                    norm=normalize(vec3(sign(prefold.x)*1.,-1.,0.));
                }else{
                    norm=normalize(vec3(0.,-1.,sign(prefold.z)*1.));
                }
            }
        }
        
        // TODO matmin instead of if
        if(topd<cornerd){
            top=top;
            h/=2.;
            base=top+vec3(0.,h,0.);
        }else{
            h/=2.;
            top=top+vec3(h/2.,h,h/2.);
            base=top+vec3(0.,h,0.);
            
            p=fold(p-top)+top;
        }
        
        prefold=p;
    }
    
    return vec4(final,norm);
    
}

// sierpinski inverted
vec4 sdSerpInv(in vec3 p,in float h)
{
    vec3 top=vec3(0.);
    //base if above the point
    vec3 base=top+vec3(0.,h,0.);
    float epsilon=.0001;
    vec3 corner;
    vec3 cornerx;
    vec3 cornerz;
    vec3 norm;
    
    float d1;
    float d2;
    
    float final=100.;
    vec3 prefold=p;
    p=fold(p);
    for(float i=0.;i<D-1.;i++){
        float h2=h/2.+0.;
        float h4=h2/2.;
        
        corner=vec3(base.x+h2,base.y,base.z+h2);
        vec3 base2=base-vec3(0.,h2,0.);
        
        vec3 midcorner=vec3(base2.x+h4,base2.y,base2.z+h4);
        cornerx=vec3(base2.x-h4,base2.y,base2.z+h4);
        cornerz=vec3(base2.x+h4,base2.y,base2.z-h4);
        float d1=sdTriangle(p.xy,base.xy,cornerx.xy,midcorner.xy);
        float d2=sdTriangle(p.zy,base.zy,cornerz.zy,midcorner.zy);
        float d=max(d1,d2);
        
        float topd=length(p-top);
        float cornerd=length(p-corner);
        
        final=min(final,d);
        
        // calc normal
        if(d<epsilon){
            if(abs(p.y-base2.y)-.00005<.0001){
                norm=vec3(0.,-1.,0.);
            }else{
                // TODO(gold edition): round corners with banded equality and rounded normal
                if(p.x>p.z){
                    norm=normalize(vec3(sign(p.x),1.,0.));
                }else{
                    norm=normalize(vec3(0.,1.,sign(p.z)));
                }
            }
            
            return vec4(d,norm);
        }
        
        norm=vec3(1.);
        corner=vec3(base.x+h2,base.y,base.z+h2);
        // TODO matmin instead of if
        if(topd<cornerd){
            top=top;
            h/=2.;
            base=top+vec3(0.,h,0.);
        }else{
            h/=2.;
            top=top+vec3(h/2.,h,h/2.);
            base=top+vec3(0.,h,0.);
            prefold=p;
            p=fold(p-top)+top;
        }
        
    }
    norm=vec3(0.,0.,0.);
    
    return vec4(final,norm);
}

// does the less distance of two d+norm vecs)
float[5]dmin(vec4 v1,vec4 v2){
if(v2.x<v1.x){
    return float[5](v2.x,v2.y,v2.z,v2.w,2.);
}else{
    return float[5](v1.x,v1.y,v1.z,v1.w,1.);
}
}

float[5]withN(vec4 v2,float N){
return float[5](v2.x,v2.y,v2.z,v2.w,N);
}

float H=2.1;

float swing(float x){
return(3.*(x/.8)*(x/.8)-2.*pow(x/.8,3.))*1.2;
}

const float pi=atan(1.)*4.;

float spring(float s,float e,float t)
{
t=clamp((t-s)/(e-s),0.,1.);
return 1.-cos(t*pi*6.)*exp(-t*6.5);
}

float f1(float x){
return smoothstep(.34,.89,x+3.1);
}

float f2(float x){
return smoothstep(.34,.89,x+2.2);
}

float[5]map(in vec3 pos,vec3 ro)
{
float t=iTime;
vec3 p=pos;

float starty=1.4;

float stillT=1.5;
if(t<stillT){
    D=1.;
    
    //  pos = RotateY(pos, 0.1*(iMouse.x - iResolution.x)/iResolution.x);
    
    vec4 r1=sdSerp(p+vec3(0.,starty,0.),H);
    
    return withN(r1,3.);
}

float pct=spring(1.5,2.2,t-stillT+.03);

vec3 rs1=vec3(0.,starty-pct*H/2.,0.);
vec3 rs2=vec3(0.,starty+pct*H/2.,0.);

// Pyramid Paths

vec4 r1=sdSerp(p+rs1,H);
vec4 r2=sdSerpInv(p+rs2,H);

vec3 nor=r1.yzw;

// This is a hack to remove stray plane intersection rays.
if(nor.y==1.&&nor.x==0.&&nor.z==0.){
    if(ro.y<pos.y){
        r1.z=-1.;
    }
}
nor=r2.yzw;
if(nor.y==-1.&&nor.x==0.&&nor.z==0.){
    if(ro.y>pos.y){
        r2.z=1.;
    }
}

float[5]final;
final=dmin(r1,r2);
//return dmin(dmin(r1, r2), vec4(length(pos - vec3(1.5,0.0,0.0)) - 0.2, 0., 0.,0.));
return final;
}

// http://iquilezles.org/www/articles/intersectors/intersectors.htm
vec2 iSphere(in vec3 ro,in vec3 rd,in float rad)
{
float b=dot(ro,rd);
float c=dot(ro,ro)-rad*rad;
float h=b*b-c;
if(h<0.)return vec2(-1.);
h=sqrt(h);
return vec2(-b-h,-b+h);
}

#define AA 2

vec3 up=vec3(0.,1.,0.);
void mainImage(out vec4 fragColor,in vec2 fragCoord)
{
// camera movement
float an=.7*iTime;
//vec3 ro = vec3( 3.0*cos(an), 3.4*sin(iTime), 3.0*sin(an) );
//vec3 ro = vec3( 3.0*cos(an), 1.8*sin(0.2*iTime), 3.0*sin(an) );
vec3 ro=vec3(3.,1.92,3.)*1.3;
vec3 ta=vec3(0.,.44,0.);
// camera matrix
vec3 ww=normalize(ta-ro);
vec3 uu=normalize(cross(ww,vec3(0.,1.,0.)));
vec3 vv=normalize(cross(uu,ww));
float time=iTime;

initD();
vec3 tot=vec3(0.);
vec2 mo=(iMouse.xy-iResolution.xy/2.)/iResolution.xy;

#if AA>1
for(int m=0;m<AA;m++)
for(int n=0;n<AA;n++)
{
    // pixel coordinates
    vec2 o=vec2(float(m),float(n))/float(AA)-.5;
    vec2 p=(-iResolution.xy+2.*(fragCoord+o))/iResolution.y;
    #else
    vec2 p=(-iResolution.xy+2.*fragCoord)/iResolution.y;
    #endif
    
    // create view ray
    vec3 rd=normalize(p.x*uu+p.y*vv+2.5*ww);
    float[5]result;
    vec3 pos;
    
    // raymarch
    const float tmax=60.;
    float t=0.;
    for(int i=0;i<1024;i++)
    {
        pos=ro+t*rd;
        
        // nod
        pos=RotateX(pos,-.05*mo.y);
        pos=RotateZ(pos,.05*mo.y);
        
        pos=RotateX(pos,-.05*mo.x);
        pos=RotateZ(pos,-.05*mo.x);
        
        result=map(pos,ro);
        //unpack
        float h=result[0];
        if(h<.0001||t>tmax)break;
        t+=h;
    }
    
    // shading/lighting
    vec3 col=vec3(0.);
    if(t<tmax)
    {
        
        vec3 light=normalize(vec3(1.2,.7,1.5));
        vec3 nor=vec3(result[1],result[2],result[3]);
        
        vec3 gold=vec3(1.,.3,.02);
        vec3 mate=.12*gold*1.;
        
        vec3 base=vec3(.380,.380,.380);
        
        vec3 A=vec3(255./255.,0./255.,96./255.);
        vec3 B=vec3(255./255.,243./255.,10./255.);
        vec3 C=vec3(215./255.,0./255.,255./255.);
        
        vec3 D=vec3(10.,255.,27.)/255.;
        vec3 E=vec3(92.,0.,255.)/255.;
        
        float ID=result[4];
        float period=20.;
        
        if(ID==3.){
            float diff=dot(nor,light);
            base=vec3(.01);
            base+=diff*.7;
            float y=pos.y;
            
            if(nor!=vec3(0.,1.,0.)){
                //float shift = iMouse.x/iResolution.x - 0.2;
                float shift=-iTime*1.;
                float n1=noised(pos*4.+vec3(.1,0.,.14)).x;
                float noise=noised(3.*vec3(pos.x,pos.y,n1*t*.2)).x;
                pos+=noise*(1.-pos.y);
                
                float xband=1.*smoothstep(.8,1.,sin(pos.z*period+shift));
                float zband=1.*smoothstep(.67,.92,sin(pos.x*period+shift));
                float yband=1.*smoothstep(.8,1.,sin(pos.y*period+shift));
                //zband = 0.0;
                
                //float timing_band = smoothstep(0.64, 0.89, y - iTime*iTime*iTime*1.8 + 2.0);
                float timing_band=f1(y+.6-time*time*time)-f2(y+.6-time*time*time);
                // base += (vec3(0.0,yband,0.0) * (y + 1.62))*timing_band;
                //base += vec3(0.0,zband,0.0);
                base+=timing_band*vec3(0.,yband,0.);
                
                // plain top
            }
            
        }else if(ID==1.&&nor.x>0.){
            // top right
            base=B;
        }else if(nor==vec3(0.,1.,0.)){
            base=D;
        }else if(nor.z>0.&&ID==1.){
            base=C;
        }else if(nor.x>0.){
            base=E;
        }else{
            base=A;
        }
        
        col=base;
        
        //col = vec3(nor.x);
        //col = vec3(occ);
    }
    // vignetting
    // col *= 1.0-0.1*dot(p,p);
    
    // gamma
    //  tot += pow(col,vec3(0.45) );
    
    // background
    if(length(col)<.01){
        col=vec3(.322,.322,.322);
    }
    
    tot+=col;
    #if AA>1
}
tot/=float(AA*AA);
#endif

fragColor=vec4(tot,1.);
}