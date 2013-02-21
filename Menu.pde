class Menu{
  Button save,reset,animate,unPin,showPins;
  Menu(){
    save=new Button("Save",0,800);
    reset=new Button("Reset",0,900);
    animate=new Button("Animate",200,800);
    unPin=new Button("Unpin",200,900);
    showPins=new Button("Show Pins",400,800);
  }
  void draw(){
    save.draw();
    reset.draw();
    animate.draw();
    unPin.draw();
    showPins.draw();
  }
  void buttonPressed(MotionEvent me){
    if(save.pressed(me)){
     turboWarp.save=true;
    }
   if(reset.pressed(me)){ //Remove all pins
       turboWarp.reset=true;
     }
   if(showPins.pressed(me)){
      turboWarp.drawPins=!turboWarp.drawPins;
     } 
   }
}
