class Menu{
  Button save,reset,animate,unPin,showPins,loadImage;
  Menu(){
    save=new Button("Save",0,800);
    reset=new Button("Reset",0,900);
    animate=new Button("Animate",200,800);
    unPin=new Button("Unpin",200,900);
    showPins=new Button("Show Pins",400,800);
    loadImage=new Button("Load Image", 400,900);
  }
  void draw(){
    save.draw();
    reset.draw();
    animate.draw();
    unPin.draw();
    showPins.draw();
    loadImage.draw();
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
   if(unPin.pressed(me)){
      turboWarp.unPin=!turboWarp.unPin;
     }
    if(animate.pressed(me)){
      turboWarp.animate=!turboWarp.animate;
    } 
   }
}
