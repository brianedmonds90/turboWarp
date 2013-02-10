// Flat tringle mesh with texture for image warping
// Written by Jarek Rossignac June 2006
import processing.opengl.*;                // comment out if not using OpenGL
PImage myImage;                            // image used as tecture 
MultiTouchController mController;  //MultiTouch object

int n=33;                                   // size of grid. Must be >2!
pt[][] G = new pt [n][n];                  // array of vertices
int pi,pj;                                   // indices of vertex being dragged when mouse is pressed
pt Mouse = new pt(0,0,0);                   // current mouse position
boolean pressed;
boolean showVertices=true, showEdges=false, showTexture=true;  // flags for rendering vertices and edges
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
void setup() { size(displayWidth, displayHeight, P3D);                              //for OpenGL use: void setup() { size(800, 800, OPENGL);  
  PFont font = loadFont("Courier-14.vlw"); textFont(font, 12);
  myImage = loadImage("jarek.jpg");                                 // load image for texture
  ww=1.0/(n-1); hh=1.0/(n-1);                                            // set intial width and height of a cell
  w=myImage.width*ww; h=myImage.height*hh;   // set intial width and height of a cell in normalized [0,1]x[0,1]
  mController=new MultiTouchController();
  pressed=false;
  resetVertices();
  pinBorder();
  initConstraints ();
  } 
 
void resetVertices() {   // resets points and laplace vectors 
   for (int i= 0; i<n; i++) 
     for (int j=0; j<n; j++) {
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
 // Mouse.setToMouse(); 
 if(mController.mTContainer.size()>0)
     Mouse.setTo(mController.firstPt());
  if (pressed) {
    G[pi][pj].setTo(Mouse); 
    G[pi][pj].addVec(offset);
  };
  if (smoothing) {for(int k=0; k<30; k++) if (sfair()) fstp++;} else {XYcubicFilter(); nstp++;};
 // drawGrid();
  drawB();
  mController.draw();
//  if (showTexture)  paintImage();
//  if (showEdges) drawEdges();
//  if (showVertices) drawVertices(); 
//  if (showL) drawL();  if (showB) drawB();   if (showQ) drawQ();  if (showV) drawV(); 
    
//  String ss="faster smoothing steps = "+Format(fstp,4); fill(green); text(ss,5,20);  
//         ss="normal smoothing steps = "+Format(nstp,4); fill(blue); text(ss,5,10);  
   };
void drawGrid(){
  stroke(0);
  strokeWeight(4);
  beginShape(POINTS);
   for (int i=0; i<G.length; i++) {
     for (int j=0; j<G[i].length; j++) { 
        vertex(G[i][j].x, G[i][j].y); 
      }
   }
   endShape();
}
void paintImage() {
   textureMode(NORMAL);       // texture parameters in [0,1]x[0,1]
   for (int i=0; i<n-1; i++) {
     beginShape(QUAD_STRIP); 
   //  texture(myImage); 
//       vertex((displayWidth-myImage.width)/2, (displayHeight-myImage.height)/2, 0, 0);
//       vertex((myImage.width+displayWidth)/2, (displayHeight-myImage.height)/2, myImage.width, 0);
//       vertex((myImage.width+displayWidth)/2, (displayHeight+myImage.height)/2, myImage.width, myImage.height);
//       vertex((displayWidth-myImage.width)/2,(displayHeight+myImage.height)/2, 0, myImage.height);
     for (int j=0; j<n; j++) { 
        vertex(G[i][j].x,    G[i][j].y,      i*ww, j*hh); 
        vertex(G[i+1][j].x, G[i+1][j].y, (i+1)*ww, j*hh); };
     endShape();
     };
   }
  
void drawEdges() {
   stroke(black); noFill(); 
   for (int i=0; i<n-1; i++) {
      beginShape(QUAD_STRIP); 
      // texture(myImage);
//         vertex((displayWidth-myImage.width)/2, (displayHeight-myImage.height)/2, 0, 0);
//         vertex((myImage.width+displayWidth)/2, (displayHeight-myImage.height)/2, myImage.width, 0);
//         vertex((myImage.width+displayWidth)/2, (displayHeight+myImage.height)/2, myImage.width, myImage.height);
//         vertex((displayWidth-myImage.width)/2,(displayHeight+myImage.height)/2, 0, myImage.height);
      for (int j=0; j<n; j++) { vertex(G[i][j].x, G[i][j].y); vertex(G[i+1][j].x, G[i+1][j].y); };
      endShape();
      };
   }

void drawVertices() {
   noStroke(); fill(red); 
   for (int i=0; i<n; i++) for (int j=0; j<n;j++) if (pinned[i][j]) G[i][j].show(4);
   }
void drawL() {stroke(green); for (int i=0; i<n; i++) for (int j=0; j<n;j++) L[i][j].show(G[i][j]); }
void drawB() {stroke(blue); for (int i=0; i<n; i++) for (int j=0; j<n;j++) {B[i][j].show(G[i][j]); println("B: "+B[i][j]);}}
void drawQ() {stroke(red); for (int i=0; i<n; i++) for (int j=0; j<n;j++) Q[i][j].show(G[i][j]); }
void drawV() {stroke(magenta); for (int i=0; i<n; i++) for (int j=0; j<n;j++) V[i][j].show(G[i][j]); }


//**********************************
//***      GUI ACTIONS
//**********************************
void keyPressed() {  
   if (key=='c')  {cn[m]=0;}
   if (key=='p')  {pinBorder();}   
   if (key==' ')  {resetVertices();}
//   if ((key==CODED) && (keyCode==CONTROL)) if (!smoothing) {sfairInit();  fstp=0; smoothing=true;};
   if (key=='e') showEdges=!showEdges;   
   if (key=='L') showL=!showL;
   if (key=='B') showB=!showB;
   if (key=='V') showV=!showV;
   if (key=='Q') showQ=!showQ;
   if (key=='m') move=!move; 
   if (key=='t') showTexture=!showTexture;
   if (key=='v') showVertices=!showVertices; 
   if (key=='0') {m=0; restoreConstraints();fs();}
   if (key=='1') {m=1; restoreConstraints();fs();}
   if (key=='2') {m=2; restoreConstraints();fs();}
   if (key=='3') {m=3; restoreConstraints();fs();}
   if (key=='4') {m=4; restoreConstraints();fs();}
   if (key=='5') {m=0; restoreConstraints();fs();}
   if (key=='6') {m=1; restoreConstraints();fs();}
   if (key=='7') {m=2; restoreConstraints();fs();}
   if (key=='8') {m=3; restoreConstraints();fs();}
   if (key=='9') {m=4; restoreConstraints();fs();}
   if (key==')') {m=0; saveConstraints();}
   if (key=='!') {m=1; saveConstraints();}
   if (key=='@') {m=2; saveConstraints();}
   if (key=='#') {m=3; saveConstraints();}
   if (key=='$') {m=4; saveConstraints();}
   if (key=='%') {m=0; saveConstraints();}
   if (key=='^') {m=1; saveConstraints();}
   if (key=='&') {m=2; saveConstraints();}
   if (key=='*') {m=3; saveConstraints();}
   if (key=='(') {m=4; saveConstraints();}
  };
  
//void mousePressed() { 
//   Mouse.setToMouse(); 
//   pickVertex();  // sets pi, pj to indices of vertex closest to mouse
//   pinned[pi][pj]=true;
//   offset.setTo(dif(Mouse,G[pi][pj]));
//   nstp=0;
//   smoothing=false;
//   };  
void pressedBeta() { 
   Mouse.setTo(mController.firstPt()); 
   pickVertex();  // sets pi, pj to indices of vertex closest to mouse
   pinned[pi][pj]=true;
   offset.setTo(dif(Mouse,G[pi][pj]));
   nstp=0;
   smoothing=false;
   };  
void pickVertex() {
  float minDist=2*w;
  for (int i=0; i<n; i++) for (int j=0; j<n; j++) {
    float dist = Mouse.disTo(G[i][j]);
    if (dist<minDist) {minDist=dist; pi=i; pj=j;};
    };
  }    
  
//void mouseReleased() {    // unpin vertex if ctrl is pressed when mouse released
//   //if (keyPressed) if (key==CODED) if (keyCode==CONTROL)  
//   pinned[pi][pj]=false;
//   smoothing=true; sfairInit(); fstp=0;
//   };   

void fs() { smoothing=true; sfairInit(); fstp=0; for(int k=0; k<100; k++) if (sfair()) fstp++;}
/********************************************************************************************/
//Override android touch events
/*******************************************************************************************/


public boolean surfaceTouchEvent(MotionEvent me) {//Overwrite this android touch method to process touch data
  int action= whichAction(me);
  if(action==1){
    pressed=true;
    mController.touch(me,whichFinger(me)); //Register the touch event
     //pressedBeta();
   
  
  }
  else if(action==0){
    mController.lift(whichFinger(me)); //Register the lift event
    pressed=false;
    smoothing=true; sfairInit(); fstp=0;
   // mouseReleased();
  }
  else if(action==2){
    //pressed=true;
    pressedBeta();
    mController.motion(me);//Register the motion event
   
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
           //if(what!=2) println("   action = "+what); // id in the order pressed (filling), except for last finger
   return what; 
   }  
int whichFinger(MotionEvent me) {
          int pointerIndex = (me.getAction() & MotionEvent.ACTION_POINTER_INDEX_MASK)>> MotionEvent.ACTION_POINTER_INDEX_SHIFT;
          int pointerId = me.getPointerId(pointerIndex);
          // println(" finger = "+pointerId); // id in the order pressed (filling), except for last finger
          return pointerId;
          }


