// pairs of edges defining a spiral

class pair {  
  pt A0=P(-20,-20);
  pt B0=P(20,-20);
  pt A1=P(-20,20);
  pt B1=P(20,20);
  pt At;
  pt Bt; 
  pt G = P();
  float a=0, s=1;
  
  pair(){}
  pair(pt LA0, pt LB0, pt LA1, pt LB1){A0=LA0; B0=LB0; A1=LA1; B1=LB1;}
//  void show0() {edge(A0,B0); show(A0,2);}
//  void showt() {edge(At,Bt); show(At,2);}
//  void show1() {edge(A1,B1); show(A1,2);}
//  pair showAll() {pen(red,2); show0(); pen(blue,2); show1(); pen(green,2); showt(); return this;}
//     
  pair evaluate(float t) { 
    a =spiralAngle(A0,B0,A1,B1); 
    s =spiralScale(A0,B0,A1,B1);
    G = spiralCenter(a, s, A0, A1); 
    At = L(G,R(A0,t*a,G),pow(s,t));
    Bt = L(G,R(B0,t*a,G),pow(s,t));
    return this;
    }  
  
  pt warp(pt Q, float t, float roi) {   
   float d=d(Q,ctr());
   float c=sq(cos(d/roi*PI/2));
   if (d>roi) c=0; 
   return L(G,R(Q,c*t*a,G),pow(s,c*t));
   }
   
  pt warp(pt Q, float t) {return L(G,R(Q,t*a,G),pow(s,t));}
   
  pt ctr() {return P(A0,B0);}
 
  } // end pair
 
pt warp(pair L, pair R, float f, pt Q0) {
  pt QLt = L.warp(Q0,f); 
  pt QRt = R.warp(Q0,f);
  float dL=d(Q0,L.ctr()), dR=d(Q0,R.ctr());
  float roi=d(L.ctr(),R.ctr());
  float a = dL/(dL+dR);
  float cL=sq(cos(a*PI/2)), cR=sq(sin(a*PI/2));
  return P(cL,QLt,cR,QRt);
  }
  
  
                                                                                                     
