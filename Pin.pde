class Pin{//Class used for interfacing between MultiTouchController and Grid
  int gridI,gridJ; 
  Pin(){
     gridI=-1;
     gridJ=-1;
     //multiTouchIndex=-1; 
  }
  Pin(int i, int j){
    gridI=i;
    gridJ=j;
    //multiTouchIndex=m; 
  }
  void pickVertex(pt a){
  float minDist=2*w;
  for (int i=0; i<n; i++) 
    for (int j=0; j<n; j++) {
      float dist = a.disTo(G[i][j]);
    if (dist<minDist) {
      minDist=dist; 
      this.gridI=i; 
      this.gridJ=j;
    };
    };
  }
}
