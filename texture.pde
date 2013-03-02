
void warpVertices(pt LA0, pt LB0, pt LA1, pt LB1, pt RA0, pt RB0, pt RA1, pt RB1, float f) { 
   for (int i=0; i<n; i++) for (int j=0; j<n; j++) G[i][j]= spirals(LA0,LB0,LA1,LB1,RA0,RB0,RA1,RB1,f,P(i*w,j*h));   
   }
    
void warpVertices(pair L, float f, float roi) { 
   for (int i=0; i<n; i++) for (int j=0; j<n; j++) G[i][j] = L.warp(G[i][j],f,roi);  
   }
    
void warpVertices(pair L, pair R, float f) { 
   for (int i=0; i<n; i++) for (int j=0; j<n; j++) G[i][j] = warp(L,R,f,G[i][j]);  
   }
    

