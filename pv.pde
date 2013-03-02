// transform 
pt R(pt Q, float a) {float dx=Q.x, dy=Q.y, c=cos(a), s=sin(a); return new pt(c*dx+s*dy,-s*dx+c*dy); };  // Q rotated by angle a around the origin
pt R(pt Q, float a, pt C) {float dx=Q.x-C.x, dy=Q.y-C.y, c=cos(a), s=sin(a); return P(C.x+c*dx-s*dy, C.y+s*dx+c*dy); };  // Q rotated by angle a around point P
//pt P(pt P, vec V) {return P(P.x + V.x, P.y + V.y); }                                                 //  P+V (P transalted by vector V)
//pt P(pt P, float s, vec V) {return P(P,W(s,V)); }                                                    //  P+sV (P transalted by sV)
pt MoveByDistanceTowards(pt P, float d, pt Q) { return P(P,d,U(V(P,Q))); };                          //  P+dU(PQ) (transLAted P by *distance* s towards Q)!!!

// average 
pt P(pt A, pt B) {return P((A.x+B.x)/2.0,(A.y+B.y)/2.0); };                                          // (A+B)/2 (average)
pt P(pt A, pt B, pt C) {return P((A.x+B.x+C.x)/3.0,(A.y+B.y+C.y)/3.0); };                            // (A+B+C)/3 (average)
pt P(pt A, pt B, pt C, pt D) {return P(P(A,B),P(C,D)); };                                            // (A+B+C+D)/4 (average)

// weighted average 
//pt P(float a, pt A) {return P(a*A.x,a*A.y);}                                                      // aA  
//pt P(float a, pt A, float b, pt B) {return P(a*A.x+b*B.x,a*A.y+b*B.y);}                              // aA+bB, (a+b=1) 
//pt P(float a, pt A, float b, pt B, float c, pt C) {return P(a*A.x+b*B.x+c*C.x,a*A.y+b*B.y+c*C.y);}   // aA+bB+cC 
//pt P(float a, pt A, float b, pt B, float c, pt C, float d, pt D){return P(a*A.x+b*B.x+c*C.x+d*D.x,a*A.y+b*B.y+c*C.y+d*D.y);} // aA+bB+cC+dD 
     

// measure 
boolean isSame(pt A, pt B) {return (A.x==B.x)&&(A.y==B.y) ;}                                         // A==B
boolean isSame(pt A, pt B, float e) {return ((abs(A.x-B.x)<e)&&(abs(A.y-B.y)<e));}                   // ||A-B||<e
float d(pt P, pt Q) {return sqrt(d2(P,Q));  };                                                       // ||AB|| (Distance)
float d2(pt P, pt Q) {return sq(Q.x-P.x)+sq(Q.y-P.y); };                                             // AB*AB (Distance squared)

vec V(vec V) {return new vec(V.x,V.y); };                                                             // make copy of vector V
vec V(pt P) {return new vec(P.x,P.y); };                                                              // make vector from origin to P
vec V(float x, float y) {return new vec(x,y); };                                                      // make vector (x,y)
vec V(pt P, pt Q) {return new vec(Q.x-P.x,Q.y-P.y);};                                                 // PQ (make vector Q-P from P to Q
vec U(vec V) {float n = n(V); if (n==0) return new vec(0,0); else return new vec(V.x/n,V.y/n);};      // V/||V|| (Unit vector : normalized version of V)
vec U(pt P, pt Q) {return U(V(P,Q));};                                                                // PQ/||PQ| (Unit vector : from P towards Q)
vec MouseDrag() {return new vec(mouseX-pmouseX,mouseY-pmouseY);};                                      // vector representing recent mouse displacement

// Interpolation 
vec L(vec U, vec V, float s) {return new vec(U.x+s*(V.x-U.x),U.y+s*(V.y-U.y));};                      // (1-s)U+sV (Linear interpolation between vectors)
vec S(vec U, vec V, float s) {float a = angle(U,V); vec W = R(U,s*a); float u = n(U); float v=n(V); W(pow(v/u,s),W); return W; } // steady interpolation from U to V
pt L(pt A, pt B, float t) {return P(A.x+t*(B.x-A.x),A.y+t*(B.y-A.y));}

// measure 
//float dot(vec U, vec V) {return U.x*V.x+U.y*V.y; }                                                     // dot(U,V): U*V (dot product U*V)
float det(vec U, vec V) {return dot(R(U),V); }                                                         // det | U V | = scalar cross UxV 
float n(vec V) {return sqrt(dot(V,V));};                                                               // n(V): ||V|| (norm: length of V)
float n2(vec V) {return sq(V.x)+sq(V.y);};                                                             // n2(V): V*V (norm squared)
boolean parallel (vec U, vec V) {return dot(U,R(V))==0; }; 

float angle (vec U, vec V) {return atan2(det(U,V),dot(U,V)); };                                   // angle <U,V> (between -PI and PI)
float angle(vec V) {return(atan2(V.y,V.x)); };                                                       // angle between <1,0> and V (between -PI and PI)
float angle(pt A, pt B, pt C) {return  angle(V(B,A),V(B,C)); }                                       // angle <BA,BC>
float turnAngle(pt A, pt B, pt C) {return  angle(V(A,B),V(B,C)); }                                   // angle <AB,BC> (positive when right turn as seen on screen)
int toDeg(float a) {return int(a*180/PI);}                                                           // convert radians to degrees
float toRad(float a) {return(a*PI/180);}                                                             // convert degrees to radians 
float positive(float a) { if(a<0) return a+TWO_PI; else return a;}                                   // adds 2PI to make angle positive

// weighted sum 
vec W(float s,vec V) {return V(s*V.x,s*V.y);}                                                      // sV
vec W(vec U, vec V) {return V(U.x+V.x,U.y+V.y);}                                                   // U+V 
vec W(vec U,float s,vec V) {return W(U,S(s,V));}                                                   // U+sV
vec W(float u, vec U, float v, vec V) {return W(S(u,U),S(v,V));}                                   // uU+vV ( Linear combination)

//pt P(pt A, pt B, pt C) {return P((A.x+B.x+C.x)/3.0,(A.y+B.y+C.y)/3.0); };                            // (A+B+C)/3 (average)
//pt P(pt A, pt B, pt C, pt D) {return P(P(A,B),P(C,D)); };                                            // (A+B+C+D)/4 (average)

// weighted average 
//pt P(float a, pt A) {return P(a*A.x,a*A.y);}                                                      // aA  
pt P(float a, pt A, float b, pt B) {return P(a*A.x+b*B.x,a*A.y+b*B.y);}                              // aA+bB, (a+b=1) 
pt P(float a, pt A, float b, pt B, float c, pt C) {return P(a*A.x+b*B.x+c*C.x,a*A.y+b*B.y+c*C.y);}   // aA+bB+cC 
pt P(float a, pt A, float b, pt B, float c, pt C, float d, pt D){return P(a*A.x+b*B.x+c*C.x+d*D.x,a*A.y+b*B.y+c*C.y+d*D.y);} // aA+bB+cC+dD 


class vec { float x=0,y=0,z; 
 // CREATE
  vec () {};
  vec (float px, float py) {x = px; y = py;};
  vec (float px, float py, float pz) {x = px; y = py; z = pz;};
  void setTo (float px, float py, float pz) {x = px; y = py; z = pz;}; 
 // MODIFY
  vec setTo(float px, float py) {x = px; y = py; return this;}; 
  vec setTo(vec V) {x = V.x; y = V.y; return this;}; 
  vec zero() {x=0; y=0; return this;}
  vec scaleBy(float u, float v) {x*=u; y*=v; return this;};
  vec scaleBy(float f) {x*=f; y*=f; return this;};
  vec reverse() {x=-x; y=-y; return this;};
  vec divideBy(float f) {x/=f; y/=f; return this;};
  vec normalize() {float n=sqrt(sq(x)+sq(y)); if (n>0.000001) {x/=n; y/=n;}; return this;};
  vec add(float u, float v) {x += u; y += v; return this;};
  vec add(vec V) {x += V.x; y += V.y; return this;};   
  vec add(float s, vec V) {x += s*V.x; y += s*V.y; return this;};   
  
  
 
  
  vec rotateBy(float a) {float xx=x, yy=y; x=xx*cos(a)-yy*sin(a); y=xx*sin(a)+yy*cos(a); return this;};
  vec left() {float m=x; x=-y; y=m; return this;};
  void mul(float m) {x *= m; y *= m; z *= m;};
   void addScaled(float m, vec V) {x += m*V.x; y += m*V.y; z += m*V.z;};
  vec make() {return(new vec(x,y,z));};
  void show (pt P) {line(P.x,P.y, P.z,P.x+x,P.y+y,P.z+z); }; 

  void sub(vec V) {x -= V.x; y -= V.y; z -= V.z;};
  void div(float m) {x /= m; y /= m; z /= m;};
 void makeUnit() {float n=this.norm(); if (n>0.0001) {this.div(n);};};
  void back() {x= -x; y= -y; z= -z;};
  boolean coplanar (vec V, vec W) {return(abs(mixed(this,V,W))<0.0001);};
  boolean cw (vec U, vec V, vec W) {return(mixed(this,V,W)>0.0001);};
    public String toString(){
    return "("+x+","+y+" ,"+z+")";
  }  



  // OUTPUT VEC
  vec clone() {return(new vec(x,y));}; 

  // OUTPUT TEST MEASURE
  float norm() {return(sqrt(sq(x)+sq(y)));}
  boolean isNull() {return((abs(x)+abs(y)<0.000001));}
  float angle() {return(atan2(y,x)); }

  // DRAW, PRINT
  void write() {println("<"+x+","+y+">");};
  void showAt (pt P) {line(P.x,P.y,P.x+x,P.y+y); }; 
  void showArrowAt (pt P) {line(P.x,P.y,P.x+x,P.y+y); 
      float n=min(this.norm()/10.,height/50.); 
      pt Q=P(P,this); 
      vec U = S(-n,U(this));
      vec W = S(.3,R(U)); 
      beginShape(); Q.add(U).add(W).v(); Q.v(); Q.add(U).add(M(W)).v(); endShape(CLOSE); }; 
  //void label(String s, pt P) {P(P).add(0.5,this).add(3,R(U(this))).label(s); };
  } // end vec class
  
  
vec R(vec V) {return new vec(-V.y,V.x);};                                                             // V turned right 90 degrees (as seen on screen)
vec R(vec V, float a) {float c=cos(a), s=sin(a); return(new vec(V.x*c-V.y*s,V.x*s+V.y*c)); };                                     // V rotated by a radians
vec S(float s,vec V) {return new vec(s*V.x,s*V.y);};                                                  // sV
vec M(vec V) { return V(-V.x,-V.y); }                                                                  // -V

