// Flat tringle mesh with texture for image warping
// Written by Jarek Rossignac June 2006
//Modified to support multiTouch on android devices by Brian Edmonds
import processing.opengl.*;                // comment out if not using OpenGL
import android.view.KeyEvent;
import java.io.File;
MultiTouchController mController;    //Multiple Finger touch object
PImage myImage;                            // image used as tecture 
static boolean drawPins=false;
boolean showMenu;
static boolean save,unPin,reset;
int n=33;                                   // size of grid. Must be >2!
pt[][] G = new pt [n][n];                  // array of vertices
int pi,pj;                                   // indices of vertex being dragged when mouse is pressed
boolean init;
Menu menu;
//TODO TESTING
int []piArray =new int[4];
int []pjArray=new int[4];
//End of TODO
//pt Mouse = new pt(0,0,0);                   // current mouse position
boolean showVertices=false, showEdges=false, showTexture=true;  // flags for rendering vertices and edges
color red = color(200, 10, 10), blue = color(10, 10, 200), green = color(10, 200, 20), 
magenta = color(200, 50, 200), black = color(10, 10, 10); 
float w,h,ww,hh;                                  // width, height of cell in absolute and normalized units
vec offset = new vec (0,0,0);                  // offset vector from mouse to clicked vertex

// constraints
int mc = 60;                                   // max number of constraints
int[] cn = new int [10];                           // number of constraints in each set
int[][] I = new  int [10][mc];                        // i coordiantes of saved constraints
int[][] J = new int [10][mc];                        // j coordiantes of saved constraints
pt[][] C = new pt [10][mc];                           // constrainted location
int m=0;                                        // current set of constraints

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
  size(displayWidth, displayHeight, OPENGL);                              //for OpenGL use: void setup() { size(800, 800, OPENGL);  
  menu=new Menu();
  PFont font = loadFont("Courier-14.vlw"); textFont(font, 30);
  myImage = loadImage("jarek.jpg");                                 // load image for texture
  ww=1.0/(n-1); hh=1.0/(n-1);                                            // set intial width and height of a cell
  w=800*ww; h=800*hh;                                            // set intial width and height of a cell in normalized [0,1]x[0,1]
  resetVertices();
  pinBorder();
  initConstraints();
  mController=new MultiTouchController();  
  textFont(font, titleFontSize);
  hint(ENABLE_NATIVE_FONTS);
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

void pinBorder() { // pins two rings of border vertices
  for (int i=0; i<n; i++) for (int j=0; j<n; j++) pinned[i][j]=false;  
  for (int i=0; i<n; i++) {pinned[i][0]=true; pinned[i][1]=true;    pinned[i][n-2]=true; pinned[i][n-1]=true; };
  for (int j=0; j<n; j++) {pinned[0][j]=true; pinned[1][j]=true;    pinned[n-2][j]=true; pinned[n-1][j]=true; };
        // pin another ring for testing
  //  for (int j=0; j<n; j++) { pinned[2][j]=true; pinned[n-3][j]=true; pinned[j][2]=true; pinned[j][n-3]=true;};
  }        
 
// ** DRAW **
void draw() { background(255); sphereDetail(4); 


  if (smoothing) {for(int k=0; k<30; k++) if (sfair()) fstp++;} else {XYcubicFilter(); nstp++;};
  if (showTexture)  paintImage();
  if (showEdges) drawEdges();
  if (showVertices) drawVertices(); 
  if (showL) drawL();  if (showB) drawB();   if (showQ) drawQ();  if (showV) drawV(); 
//  drawGrid();
  if(drawPins){//Show constraints
    drawPins();
  }
  fill(50);
  textSize(32);
//  text("TESTING",100,100);
//  noFill();
  menu.draw();
  if(save){//Save a screenshot
    saveFrame("//sdcard//turboWarb/warped####.png"); 
   save=false; 
  }
  else if(reset){//Reset the morph to the original image
    reset();
    reset=false; 
  }
//  String ss="faster smoothing steps = "+Format(fstp,4); fill(green); text(ss,5,20);  
//         ss="normal smoothing steps = "+Format(nstp,4); fill(blue); text(ss,5,10);  
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

void drawVertices() {
   noStroke(); fill(red); 
   for (int i=0; i<n; i++) for (int j=0; j<n;j++) if (pinned[i][j]) G[i][j].show(4);
   }

void drawL() {stroke(green); for (int i=0; i<n; i++) for (int j=0; j<n;j++) L[i][j].show(G[i][j]); }
void drawB() {stroke(red); for (int i=0; i<n; i++) for (int j=0; j<n;j++) B[i][j].show(G[i][j]); }
void drawQ() {stroke(red); for (int i=0; i<n; i++) for (int j=0; j<n;j++) Q[i][j].show(G[i][j]); }
void drawV() {stroke(magenta); for (int i=0; i<n; i++) for (int j=0; j<n;j++) V[i][j].show(G[i][j]); }

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
void drawPins(){
  fill(blue);
  for(int i=2;i<G.length-2;i++){
    for(int j=2;j<G[i].length-2;j++){  
      if(pinned[i][j]){
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
void unPin(MotionEvent me) { 
    MultiTouch temp= mController.findClosest(new pt(me.getX(),me.getY(),0));  // finds the closest pin to the mouse
    pinned[temp.p.gridI][temp.p.gridJ]=false;
} 
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
    saveFrame("//sdcard//turboWarb/warped####.png"); 
  }
  //TODO fix this method
  void reset(){
    mController=new MultiTouchController();
    resetVertices();
    pinBorder();
    initConstraints();
  }
  
/********************************************************************************************/
//Override android touch events
/*******************************************************************************************/

public boolean surfaceTouchEvent(MotionEvent me) {//Overwrite this android touch method to process touch data
  int action= whichAction(me);
  if(action==1){
//    pressed=true;
    if(me.getY()>800){
      menu.buttonPressed(me);//User has pressed a menu button
    }
    else{
      mController.touch(me,whichFinger(me)); //Register the touch event
      pressedBeta();
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
