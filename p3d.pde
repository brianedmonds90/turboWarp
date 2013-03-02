import android.view.MotionEvent;
class pt { 
  float x=0, y=0, z=0;
  int meIndex;//Motion Event index of selected
  pt(){
    this.x=0;
    this.y=0;
  //  this.z=0;
  } 
  pt(float x,float y){
    this.x=x;
    this.y=y;
  }
  pt(float x,float y, float z){
    this.x=x;
    this.y=y;
    this.z=z;
  }
  float distance(pt a){
    return (float) Math.sqrt((this.x-a.x)*(this.x-a.x)+(this.y-a.y)*(this.y-a.y));  
  }
  void draw(){
    ellipse(this.x,this.y,50,50);
  }
  void drawWithNum(int num){
    fill(255,0,0);
    ellipse(this.x,this.y,100,100);
     fill(50);
     textSize(50);
    text(num,this.x-4,this.y-4);
  }
  public void move(float dx, float dy) {
    this.x+=dx;
    this.y+=dy;
    
  }
 public void move(pt delta){
    this.x+=delta.x;
    this.y+=delta.y;
  }

//  public pt subtract(pt a){
//    return new pt(this.x-a.x,this.y-a.y);
//  }
    public pt subtract(pt a){
    return new pt(this.x-a.x,this.y-a.y,this.z-a.z);
  }
  public String toString(){
    return "("+x+","+y+" ,"+z+")";
  }
//  public boolean equals(pt a){
//    if(a.x==this.x&&a.y==this.y)
//    return true;
//    return false;  
//  }
    pt add(float u, float v) {x += u; y += v; return this;}                       // P.add(u,v): P+=<u,v>
  pt add(pt P) {x += P.x; y += P.y; return this;};                              // incorrect notation, but useful for computing weighted averages
  pt add(float s, pt P)   {x += s*P.x; y += s*P.y; return this;};               // adds s*P
  pt add(vec V) {x += V.x; y += V.y; return this;}                              // P.add(V): P+=V
  pt add(float s, vec V) {x += s*V.x; y += s*V.y; return this;}                 // P.add(s,V): P+=sV
    pt v() {vertex(x,y); return this;};  // used for drawing polygons between beginShape(); and endShape();

  void set(pt p){
   this.x=p.x;
   this.y=p.y; 
   this.z=p.z;
  }
  pt make() {return(new pt(x,y,z));};
  void show(float r) { pushMatrix(); translate(x,y,z); sphere(r); popMatrix();}; 
  void showLineTo (pt P) {line(x,y,z,P.x,P.y,P.z); }; 
  void setToPoint(pt P) { x = P.x; y = P.y; z = P.z;}; 
  void setTo(pt P) { x = P.x; y = P.y; }//z = P.z;}; 
  void setTo (float px, float py, float pz) {x = px; y = py; z = pz;}; 
  void setToMouse() { x = mouseX; y = mouseY; }; 
  void write() {println("("+x+","+y+","+z+")");};
  void addVec(vec V) {x += V.x; y += V.y; z += V.z;};
  void addScaledVec(float s, vec V) {x += s*V.x; y += s*V.y; z += s*V.z;};
  void subVec(vec V) {x -= V.x; y -= V.y; z -= V.z;};
  void vert() {vertex(x,y,z);};
  void vertext(float u, float v) {vertex(x,y,z,u,v);};
  boolean isInWindow() {return(((x<0)||(x>width)||(y<0)||(y>height)));};
  void label(String s, vec D) {text(s, x+D.x, y+D.y, z+D.z);  };
  vec vecTo(pt P) {return(new vec(P.x-x,P.y-y,P.z-z)); };
  float disTo(pt P) {return(sqrt( sq(P.x-x)+sq(P.y-y)+sq(P.z-z) )); };
  vec vecToMid(pt P, pt Q) {return(new vec((P.x+Q.x)/2.0-x,(P.y+Q.y)/2.0-y,(P.z+Q.z)/2.0-z )); };
  vec vecToProp (pt B, pt D) {
      vec CB = this.vecTo(B); float LCB = CB.norm();
      vec CD = this.vecTo(D); float LCD = CD.norm();
      vec U = CB.make();
      vec V = CD.make(); V.sub(U); V.mul(LCB/(LCB+LCD));
      U.add(V);
      return(U);  
      };  
  void addPt(pt P) {x+=P.x; y+=P.y; z+=P.z;};
  void subPt(pt P) {x-=P.x; y-=P.y; z-=P.z; };
  void mul(float f) {x*=f; y*=f; y*=f;};
  void pers(float d) { y=d*y/(d+z); x=d*x/(d+z); z=d*z/(d+z); };
  void inverserPers(float d) { y=d*y/(d-z); x=d*x/(d-z); z=d*z/(d-z); };
  boolean coplanar (pt A, pt B, pt C) {return(abs(tetVol(this,A,B,C))<0.0001);};
  boolean cw (pt A, pt B, pt C) {return(tetVol(this,A,B,C)>0.0001);};}
  pt P() {return P(0,0); };                                                                            // make point (0,0)                                             
  pt P(pt P) {return P(P.x,P.y); };                                                                    // make copy of point A
  pt P(float s, pt A) {return new pt(s*A.x,s*A.y); };                                                  // sA
  pt P(pt P, vec V) {return P(P.x + V.x, P.y + V.y); }                                                 //  P+V (P transalted by vector V)
 pt P(pt P, float s, vec V) {return P(P,W(s,V)); }                                                    //  P+sV (P transalted by sV)
  pt P(float x, float y) {return new pt(x,y); };  
  pt P(pt A, float s, pt B) {return P(A.x+s*(B.x-A.x),A.y+s*(B.y-A.y));};//,A.z+s*(B.z-A.z)); };                 // A+sAB
  //pt P(pt A, pt B) {return P((A.x+B.x)/2,(A.y+B.y)/2); };                                              // (A+B)/2

// display 
//void show(pt P, float r) {ellipse(P.x, P.y, 2*r, 2*r);};                                             // draws circle of center r around P
//void show(pt P) {ellipse(P.x, P.y, 6,6);};                                                           // draws small circle around point
//void edge(pt P, pt Q) {line(P.x,P.y,Q.x,Q.y); };                                                      // draws edge (P,Q)
//void arrow(pt P, pt Q) {arrow(P,V(P,Q)); }                                                            // draws arrow from P to Q
//void label(pt P, String S) {text(S, P.x-4,P.y+6.5); }                                                 // writes string S next to P on the screen ( for example label(P[i],str(i));)
//void label(pt P, vec V, String S) {text(S, P.x-3.5+V.x,P.y+7+V.y); }                                  // writes string S at P+V
//void v(pt P) {vertex(P.x,P.y);};    
 
//class vec { float x,y,z; 
//  vec (float px, float py, float pz) {x = px; y = py; z = pz;};
//  void setTo (float px, float py, float pz) {x = px; y = py; z = pz;}; 
//  vec make() {return(new vec(x,y,z));};
//  void setTo(vec V) { x = V.x; y = V.y; z = V.z;}; 
//  void show (pt P) {line(P.x,P.y, P.z,P.x+x,P.y+y,P.z+z); }; 
//  void add(vec V) {x += V.x; y += V.y; z += V.z;};
//  void addScaled(float m, vec V) {x += m*V.x; y += m*V.y; z += m*V.z;};
//  void sub(vec V) {x -= V.x; y -= V.y; z -= V.z;};
//  void mul(float m) {x *= m; y *= m; z *= m;};
//  void div(float m) {x /= m; y /= m; z /= m;};
//  void write() {println("("+x+","+y+","+z+")");};
//  float norm() {return(sqrt(sq(x)+sq(y)+sq(z)));}; 
//  void makeUnit() {float n=this.norm(); if (n>0.0001) {this.div(n);};};
//  void back() {x= -x; y= -y; z= -z;};
//  boolean coplanar (vec V, vec W) {return(abs(mixed(this,V,W))<0.0001);};
//  boolean cw (vec U, vec V, vec W) {return(mixed(this,V,W)>0.0001);};
//    public String toString(){
//    return "("+x+","+y+" ,"+z+")";
//  }  
//
//} ;
  
vec triNormalFromPts(pt A, pt B, pt C) {vec N = cross(A.vecTo(B),A.vecTo(C));  return(N); };
float tetVol (pt A, pt B, pt C, pt D) { return(dot(triNormalFromPts(A,B,C),A.vecTo(D))); };
float dot(vec U, vec V) {return(U.x*V.x+U.y*V.y+U.z*V.z); };
vec cross(vec U, vec V) {return(new vec( U.y*V.z-U.z*V.y, U.z*V.x-U.x*V.z, U.x*V.y-U.y*V.x )); };
float mixed(vec U, vec V, vec W) {return(dot(cross(U,V),W)); };
pt average (pt A, pt B) {return(new pt((A.x+B.x)/2 , (A.y+B.y)/2, (A.z+B.z)/2 )); };
pt average (pt A, pt B, pt C) {return(new pt((A.x+B.x+C.x)/3 , (A.y+B.y+C.y)/3, (A.z+B.z+C.z)/3 )); };
pt average (pt A, pt B, pt C, pt D) {return(new pt( (A.x+B.x+C.x+D.x)/4 , (A.y+B.y+C.y+D.y)/4, (A.z+B.z+C.z+D.z)/4 ) ); };
pt between (pt A, float s, pt B) {return(new pt((s-1)*A.x+s*B.x , (s-1)*A.y+s*B.y,(s-1)*A.z+s*B.z )); };
vec between (vec A, float s, vec B) {return(new vec((s-1)*A.x+s*B.x , (s-1)*A.y+s*B.y,(s-1)*A.z+s*B.z )); };
vec dif(pt A, pt B) {return(new vec( B.x-A.x , B.y-A.y , B.z-A.z)); };
vec dif(vec U, vec V) {return(new vec(V.x-U.x,V.y-U.y,V.z-U.z)); };
vec sum(vec U, vec V) {return(new vec(V.x+U.x,V.y+U.y,V.z+U.z)); };
vec average(vec U, vec V) {return(new vec((U.x+V.x)/2,(U.y+V.y)/2,(U.z+V.z)/2)); };
vec average (vec A, vec B, vec C, vec D) {return(new vec( (A.x+B.x+C.x+D.x)/4 , (A.y+B.y+C.y+D.y)/4, (A.z+B.z+C.z+D.z)/4 ) ); };


//************************************************************************
//**** SPIRAL
//************************************************************************
pt spiralPt(pt A, pt G, float s, float a) {return L(G,R(A,a,G),s);}  
pt spiralPt(pt A, pt G, float s, float a, float t) {return L(G,R(A,t*a,G),pow(s,t));} 
pt spiralCenter(pt A, pt B, pt C, pt D) { // computes center of spiral that takes A to C and B to D
  float a = spiralAngle(A,B,C,D); 
  float z = spiralScale(A,B,C,D);
  return spiralCenter(a,z,A,C);
  }
float spiralAngle(pt A, pt B, pt C, pt D) {return angle(V(A,B),V(C,D));}
float spiralScale(pt A, pt B, pt C, pt D) {return d(C,D)/d(A,B);}
pt spiralCenter(float a, float z, pt A, pt C) {
  float c=cos(a), s=sin(a);
  float D = sq(c*z-1)+sq(s*z);
  float ex = c*z*A.x - C.x - s*z*A.y;
  float ey = c*z*A.y - C.y + s*z*A.x;
  float x=(ex*(c*z-1) + ey*s*z) / D;
  float y=(ey*(c*z-1) - ex*s*z) / D;
  return P(x,y);
  }
  
pt spiralT(pt A, pt B, pt C, float t) {
  float a =spiralAngle(A,B,B,C); 
  float s =spiralScale(A,B,B,C);
  pt G = spiralCenter(a, s, A, B); 
  return L(G,R(B,t*a,G),pow(s,t));
  }
  
pt spiral(pt A, pt B, pt C, pt D, float t, pt Q) {
  float a =spiralAngle(A,B,C,D); 
  float s =spiralScale(A,B,C,D);
  pt G = spiralCenter(a, s, A, C); 
  return L(G,R(Q,t*a,G),pow(s,t));
  }
  
pt spiralA(pt A, pt B, pt C, pt D, float t) {
  float a =spiralAngle(A,B,C,D); 
  float s =spiralScale(A,B,C,D);
  pt G = spiralCenter(a, s, A, C); 
  return L(G,R(A,t*a,G),pow(s,t));
  }
  
pt spiralB(pt A, pt B, pt C, pt D, float t) {
  float a =spiralAngle(A,B,C,D); 
  float s =spiralScale(A,B,C,D);
  pt G = spiralCenter(a, s, A, C); 
  return L(G,R(B,t*a,G),pow(s,t));
  }
  
pt onSpiral(pt A, pt B, pt C) {
  float a =spiralAngle(A,B,B,C); 
  float s =spiralScale(A,B,B,C);
  pt G = spiralCenter(a, s, A, B); 
  return L(G,R(B,a/2,G),sqrt(s));
  }

pt spirals(pt LA0, pt LB0, pt LA1, pt LB1, pt RA0, pt RB0, pt RA1, pt RB1, float f, pt Q0) {
  float dL=d(Q0,P(LA0,LB0)), dR=d(Q0,P(RA0,RB0));
  float roi=d(P(LA0,LB0),P(RA0,RB0));
   float cL=sq(cos(dL/roi*PI/2)), cR=sq(cos(dR/roi*PI/2));
  if (dL>roi) cL=0;  if (dR>roi) cR=0;
  pt QLt = spiral(LA0,LB0,LA1,LB1,f*cL,Q0); 
  pt QRt = spiral(RA0,RB0,RA1,RB1,f*cR,Q0); 
  return P(P(Q0,1,V(Q0,QLt)),1,V(Q0,QRt));
  }


