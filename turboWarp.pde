// Flat tringle mesh with texture for image warping
// Written by Jarek Rossignac June 2006
//Modified to support multiTouch on android devices by Brian Edmonds
import processing.opengl.*;            // comment out if not using OpenGL
import android.view.KeyEvent;
import java.io.File;
import android.os.Environment;
MultiTouchController mController;    //Multiple Finger touch object
PImage myImage;     // image used as tecture 
static boolean drawPins=false;
boolean drawGrid,showMenu;
static boolean animate=false;
static boolean test=false;
boolean global=false;
Pin pp;
int numF;
float roi=100;
static boolean save,unPin,reset,init;
boolean drawDummyGrid;
float t,deltaT;
int n=33;                                   // size of grid. Must be >2!
float f=0;
pt[][] G = new pt [n][n];                  // array of vertices
pt[][] dummyG=new pt[n][n];                //original grid for animation
pt[][] keyFrame= new pt[n][n];
int pi,pj;                                 // indices of vertex being dragged when mouse is pressed
Menu menu;
boolean showVertices=false, showEdges=false, showTexture=true;  // flags for rendering vertices and edges
color red = color(200, 10, 10), blue = color(10, 10, 200), green = color(10, 200, 20), 
magenta = color(200, 50, 200), black = color(10, 10, 10); 
float w,h,ww,hh;                                  // width, height of cell in absolute and normalized units
vec offset = new vec (0,0,0);                  // offset vector from mouse to clicked vertex
pt a,b,c;
// constraints
int mc = 60;                                   // max number of constraints
int[] cn = new int [10];                           // number of constraints in each set
int[][] I = new  int [10][mc];                        // i coordiantes of saved constraints
int[][] J = new int [10][mc];                        // j coordiantes of saved constraints
pt[][] C = new pt [10][mc];                           // constrainted location
int m=0;                                        // current set of constraints
pair LPair,R;

void restoreConstraints () {
  pinBorder();
  for (int k=0; k<cn[m]; k++) { 
    int i = I[m][k];  int j = J[m][k]; 
    G[i][j].setTo(C[m][k]); 
    pinned[i][j]=true;
    }; 
  }
void saveConstraints () {
  cn[m]=0;
  for (int i=2; i<n-2; i++) for (int j=2; j<n-2; j++) if (pinned[i][j]) {I[m][cn[m]]=i; J[m][cn[m]]=j; C[m][cn[m]].setTo(G[i][j]); cn[m]++; };
  }
void initConstraints () {for (int i=0; i<10; i++) for (int j=0; j<mc; j++) C[i][j]=new pt(0,0,0); }

// SMOOTHING  
vec[][] L = new vec [n][n];                // laplace vectors for vertices
vec[][] B = new vec [n][n];                // CG vectors for vertices
vec[][] Q = new vec [n][n];                // CG vectors for vertices
vec[][] V = new vec [n][n];                // CG vectors for vertices
boolean showL=false, showQ=false,showV=false, showB=false;              // flags for rendering laplace vectors
boolean[][] pinned= new boolean [n][n];     // mask for pinned vertices
boolean move = true;
int fstp=0, nstp=0;              // Iteration counters for fast and normal smoothing
boolean smoothing = false;

// ** SETUP **
void setup() { 
  deltaT=.01;
  //deltaT=.05;
  t=0.0;
  size(displayWidth, displayHeight, OPENGL);                              //for OpenGL use: void setup() { size(800, 800, OPENGL);  
  menu=new Menu();
  a= new pt();
  b=new pt();
  c=new pt();
  c.setToPoint(a);
  LPair= new pair();
  R = new pair(); 
  unPin=false;
  drawGrid=false;
  pp=new Pin();
  PFont font = loadFont("Courier-14.vlw"); textFont(font, 30);
  File f = new File(Environment.getExternalStorageDirectory().getPath() + "turboWarp/warped0426.png"); 
 // myImage = loadImage("//sdcard//turboWarp/warped0426.png");       // load image for texture
  myImage= loadImage("middleTeton.jpg");
  ww=1.0/(n-1); hh=1.0/(n-1);                                            // set intial width and height of a cell
  w=800*ww; h=800*hh;                                            // set intial width and height of a cell in normalized [0,1]x[0,1]
  resetVertices();
  pinBorder();
  initConstraints();
  mController=new MultiTouchController();  
  textFont(font, titleFontSize);
  initDummyG();
  
  //drawDummyGrid=true;
  hint(ENABLE_NATIVE_FONTS);
  numF=0;
  animate=true;
  } 
 
 float titleFontSize, menuFontSize, menuPad;
 
void resetVertices() {   // resets points and laplace vectors 
   for (int i=0; i<n; i++) for (int j=0; j<n; j++) {
     G[i][j]=new pt(i*w,j*h,0); 
     L[i][j]=new vec(0,0,0); 
     B[i][j]=new vec(0,0,0);  
     Q[i][j]=new vec(0,0,0);  
     V[i][j]=new vec(0,0,0);
     };  
   } 
void initDummyG(){
    for(int i=0;i<G.length;i++){
   for(int j=0;j<G[i].length;j++){
     dummyG[i][j]=new pt();
     dummyG[i][j].setToPoint(G[i][j]);
   } 
  }
}
void initGrid(pt [][] grid){
    for(int i=0;i<G.length;i++){
   for(int j=0;j<G[i].length;j++){
     grid[i][j]=new pt();
     //dummyG[i][j].setToPoint(G[i][j]);
   } 
  }
}
void pinBorder() { // pins two rings of border vertices
  for (int i=0; i<n; i++) for (int j=0; j<n; j++) pinned[i][j]=false;  
  for (int i=0; i<n; i++) {pinned[i][0]=true; pinned[i][1]=true;    pinned[i][n-2]=true; pinned[i][n-1]=true; };
  for (int j=0; j<n; j++) {pinned[0][j]=true; pinned[1][j]=true;    pinned[n-2][j]=true; pinned[n-1][j]=true; };
        // pin another ring for testing
  //  for (int j=0; j<n; j++) { pinned[2][j]=true; pinned[n-3][j]=true; pinned[j][2]=true; pinned[j][n-3]=true;};
  }        
 
// ** DRAW **
void draw() { background(255); sphereDetail(4); 
  if (smoothing) {
    for(int k=0; k<30; k++) 
      if (sfair()) 
        fstp++;
    } 
  else {
    XYcubicFilter(); 
    nstp++;
  };
  if (showTexture)  paintImage();
  if (showEdges) drawEdges();
  if (showVertices) drawVertices(); 
  //if (showL) drawL();  if (showB) drawB();   if (showQ) drawQ();  if (showV) drawV(); 
  if(drawGrid){
    drawGrid();
  }
  if(drawDummyGrid){
    drawDummyGrid();
  }
  if(drawPins){//Show constraints
    drawPins();
  }
  fill(50);
  textSize(32);
  menu.draw();
  if(save){//Save a screenshot
    save();
    //saveFrame("//sdcard//turboWarb/warped####.png"); 
   save=false; 
  }
  else if(reset){//Reset the morph to the original image
    reset();
    reset=false; 
  }
  if(test){//Used for testing features
    saveAnimationFrame();
    test=false;
  }
  
   LPair= new pair(new pt(492.84778,268.1169),new pt(451.00897,391.65414),new pt(516.67664,420.0195),new pt(452.7228,390.67413));
  R= new pair(new pt(423.72888,587.102),new pt(463.2494,481.45377),new pt(513.6487,444.87125),new pt(457.68945,450.95416));
  roi=d(LPair.ctr(),R.ctr());
  resetVertices();
  LPair.evaluate(f); R.evaluate(f); 
  
  if(global) warpVertices(LPair,R,f);
  else {
    warpVertices(LPair,f,roi);
    warpVertices(R,f,roi);
    }
  
  
  if(animate){
    
    t+=0.02; if (t>=4) t=0; f=sq(cos(t*PI/2));
   // println("Inside animate loop");
//    if(t>1.0){
//    deltaT=-.1; 
//    }
//    else if(t<0.0){
//     deltaT=.1;
//    }
//    //if(t<1.0)
//    t+=deltaT; 
//  //  println("t: "+t);
//   // drawGrid=true;
//    //drawDummyGrid=true;
//    lerpPins(keyFrame,t,dummyG); //animate grid function
//    //saveFrame("//sdcard//turboWarb/warped"+numF+".jpg");
    //numF++;
  }
};
  
void paintImage() {
   textureMode(NORMAL);       // texture parameters in [0,1]x[0,1]
   for (int i=0; i<n-1; i++) {
     beginShape(QUAD_STRIP); 
     texture(myImage); 
     for (int j=0; j<n; j++) { 
        vertex(G[i][j].x,    G[i][j].y,      i*ww, j*hh); 
        vertex(G[i+1][j].x, G[i+1][j].y, (i+1)*ww, j*hh); };
     endShape();
     };
   }
  
void drawEdges() {
   stroke(black); noFill(); 
   for (int i=0; i<n-1; i++) {
      beginShape(QUAD_STRIP); texture(myImage); 
      for (int j=0; j<n; j++) { vertex(G[i][j].x, G[i][j].y); vertex(G[i+1][j].x, G[i+1][j].y); };
      endShape();
      };
   }
void setKeyFrame(pt [][]keyFrame){//Sets the keyframes before an animation loop
  //initDummyG();
   for(int i=0;i<G.length;i++){
   for(int j=0;j<G[i].length;j++){
     keyFrame[i][j]=new pt();
     keyFrame[i][j].setToPoint(G[i][j]);
   } 
  }
  
}
void drawVertices() {
   noStroke(); fill(red); 
   for (int i=0; i<n; i++) for (int j=0; j<n;j++) if (pinned[i][j]) G[i][j].show(4);
   }

//void drawL() {stroke(green); for (int i=0; i<n; i++) for (int j=0; j<n;j++) L[i][j].show(G[i][j]); }
//void drawB() {stroke(red); for (int i=0; i<n; i++) for (int j=0; j<n;j++) B[i][j].show(G[i][j]); }
//void drawQ() {stroke(red); for (int i=0; i<n; i++) for (int j=0; j<n;j++) Q[i][j].show(G[i][j]); }
//void drawV() {stroke(magenta); for (int i=0; i<n; i++) for (int j=0; j<n;j++) V[i][j].show(G[i][j]); }

void drawGrid(){
  stroke(red);
  strokeWeight(4);
  for(int i=0;i<G.length-1;i++){
    for(int j=0;j<G[i].length-1;j++){
        line(G[i][j].x,G[i][j].y,G[i+1][j].x,G[i+1][j].y);
        line(G[i][j].x,G[i][j].y,G[i][j+1].x,G[i][j+1].y);
    }
 } 
}
void drawDummyGrid(){
  stroke(blue);
  strokeWeight(4);
  for(int i=0;i<dummyG.length-1;i++){
    for(int j=0;j<dummyG[i].length-1;j++){
        line(dummyG[i][j].x,dummyG[i][j].y,dummyG[i+1][j].x,dummyG[i+1][j].y);
        line(dummyG[i][j].x,dummyG[i][j].y,dummyG[i][j+1].x,dummyG[i][j+1].y);
    }
 } 
}
void drawPins(){
  fill(blue);
  for(int i=2;i<G.length-2;i++){
    for(int j=2;j<G[i].length-2;j++){  
      if(pinned[i][j]){
          if(pp.gridI==i &&pp.gridJ==j)
            fill(red);
           else
             fill(blue);
          ellipse(G[i][j].x, G[i][j].y,20,20);
       }
    }
  }
}
//**********************************
//***      GUI ACTIONS
//**********************************
 

void fs() { smoothing=true; sfairInit(); fstp=0; for(int k=0; k<100; k++) if (sfair()) fstp++;}

void pressedBeta() { 
   MultiTouch temp;
   for(int i=0;i<mController.size();i++){
       temp=mController.getAt(i);
       pickVertex(temp);  // sets pi, pj to indices of vertex closest to mouse
       pinned[temp.p.gridI][temp.p.gridJ]=true;
   }
};  
void pickVertex(MultiTouch t) {
  float minDist=2*w;
  for (int i=0; i<n; i++) 
    for (int j=0; j<n; j++) {
      float dist = t.disk.disTo(G[i][j]);
    if (dist<minDist) {
      minDist=dist;       
      pi=i; 
      pj=j;
    };
    };
    t.setPin(new Pin(pi,pj));
  }
void movePinned(){
  MultiTouch t;
  for(int i=0;i<mController.size();i++){
    t=mController.getAt(i);
     //Mouse= t.disk;
     G[t.p.gridI][t.p.gridJ].setTo(t.disk); 
  }
   nstp=0;
   smoothing=false;
}
 void save(){  
     myImage=get(0,0,displayWidth,800);
     mController=new MultiTouchController();
    resetVertices();
    pinBorder();
    initConstraints();
     //drawGrid=true;
  }
  void saveAnimationFrame(){  
     PImage img=get(0,0,displayWidth,800);
     img.save("//sdcard//turboWarb/warped"+numF+".png");
     numF++;
     //drawGrid=true;
  }
  //TODO fix this method
  void reset(){
    //mController=new MultiTouchController();
    //resetVertices();
    //pinBorder();
    //initConstraints();
    setup();
  }
  //void unPin(){
   //Select closest pin
  // mController.closestPin(getPoint(me));    
  //}
  
/********************************************************************************************/
//Override android touch events
/*******************************************************************************************/

public boolean surfaceTouchEvent(MotionEvent me) {//Overwrite this android touch method to process touch data
  int action= whichAction(me);
  if(action==1){
//    pressed=true;
    if(me.getY()>800){
      menu.buttonPressed(me);//User has pressed a menu button
      if(animate)
        setKeyFrame(keyFrame);
    }
    else{
      if(unPin){
       // println("Point on Screen: "+getPt(me));
        pp=mController.closestPin(getPt(me));
        unPin(pp);
        unPin=false;
      }
      else{
        mController.touch(me,whichFinger(me)); //Register the touch event
        pressedBeta();
      }
    }
  }
  else if(action==0){
    mController.lift(whichFinger(me)); //Register the lift event   
    smoothing=true; sfairInit(); fstp=0;
  }
 else if(action==2){
   mController.motion(me);//Register the motion event
   movePinned();
 }
 return super.surfaceTouchEvent(me);
}  
int whichAction(MotionEvent me) { // 1=press, 0=release, 2=drag
   int action = me.getAction(); 
   int aaction = action & MotionEvent.ACTION_MASK;
   int what=0;
   if (aaction==MotionEvent.ACTION_POINTER_UP || aaction==MotionEvent.ACTION_UP) what=0;
   if (aaction==MotionEvent.ACTION_DOWN || aaction==MotionEvent.ACTION_POINTER_DOWN) what=1;
   if (aaction==MotionEvent.ACTION_MOVE) what=2;
   return what; 
   }  
int whichFinger(MotionEvent me) {
          int pointerIndex = (me.getAction() & MotionEvent.ACTION_POINTER_INDEX_MASK)>> MotionEvent.ACTION_POINTER_INDEX_SHIFT;
          int pointerId = me.getPointerId(pointerIndex);
          return pointerId;
          }
          
pt getPt(MotionEvent me){
    pt cTouch= new pt(me.getX(0),me.getY(0),0);
    return cTouch;
}
void unPin(Pin p){
  mController.unPin(p);
   for(int i=2;i<G.length-2;i++){
    for(int j=2;j<G[i].length-2;j++){  
      if(pinned[i][j]){
          if(pp.gridI==i &&pp.gridJ==j){
            pinned[i][j]=false;
             smoothing=true; sfairInit(); fstp=0;
            return;
          }
       }
    }
  }
}
void lerpPins(pt [][]start, float t,pt [][]finish){
  for(int i=2;i<G.length-2;i++){
    for(int j=2;j<G[i].length-2;j++){  
     if(pinned[i][j]){
       G[i][j]=P(start[i][j],t,finish[i][j]);
       smoothing=true; sfairInit(); fstp=0;
     }
    }
  }
}
void lerpPins(float t,pt [][]finish){
  for(int i=2;i<G.length-2;i++){
    for(int j=2;j<G[i].length-2;j++){  
     if(pinned[i][j]){
       G[i][j]=P(dummyG[i][j],t,finish[i][j]);
       smoothing=true; sfairInit(); fstp=0;
     }
    }
  }
}

