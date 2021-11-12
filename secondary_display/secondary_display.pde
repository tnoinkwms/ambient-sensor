//      ___      .___  ___. .______    __   _______ .__   __. .___________.        _______. _______ .__   __.      _______.  ______   .______
//     /   \     |   \/   | |   _  \  |  | |   ____||  \ |  | |           |       /       ||   ____||  \ |  |     /       | /  __  \  |   _  \
//    /  ^  \    |  \  /  | |  |_)  | |  | |  |__   |   \|  | `---|  |----`      |   (----`|  |__   |   \|  |    |   (----`|  |  |  | |  |_)  |
//   /  /_\  \   |  |\/|  | |   _  <  |  | |   __|  |  . `  |     |  |            \   \    |   __|  |  . `  |     \   \    |  |  |  | |      /
//  /  _____  \  |  |  |  | |  |_)  | |  | |  |____ |  |\   |     |  |        .----)   |   |  |____ |  |\   | .----)   |   |  `--'  | |  |\  \----.
// /__/     \__\ |__|  |__| |______/  |__| |_______||__| \__|     |__|        |_______/    |_______||__| \__| |_______/     \______/  | _| `._____|
import processing.serial.*;
Serial myPort;

float x,y,z,angle,delta;
float x1,y1;
float centX,centY;
float count;
PGraphics pg;
float omega = radians(360);
float gamma,rambda;
float [] bar1;
float [] bar2;
int LENGTH;
float value1;
float amp;
int L;
int N;
int M;
int P;
float sum,ave;
float sumsave;
int k;
float laticesize;
float cross;
PImage[] IMAGES = new PImage[20];
int r;
int Q;
String inBuf;

void setup(){
  myPort = new Serial(this, Serial.list()[0], 9600);
  background(0,0,0);
  //select secondary display
  fullScreen(P3D,2);
  smooth(10);
  centX = width/2;
  centY = height/2;
  amp = height/3.8;
  laticesize = width/5.4;
  cross =8;
  pg = createGraphics(width,height);
  frameRate(1000);
  rectMode(CENTER);
   L=1;
   N=0;
   M=0;
   P=0;
   sum=0;
   ave=0;
   sumsave=0;
   bar1 = new float[10];
   bar2 = new float[10];
   for (int i=0;i<IMAGES.length;i++){
     r = i+1;
     IMAGES[i] = loadImage(r+".jpg");
   }
   Q=19;
}

void draw(){  
 translate(0,0);
 hint(DISABLE_DEPTH_TEST);
 count = frameCount -1;
 // read volatage per 1s
 if(count%70==0){
   byte[] outBuf = new byte[1];
   outBuf[0] = 's';
   myPort.write(outBuf);
   if(myPort.available() >0){
    inBuf = myPort.readString();
    //about pm 1E4
    value1 = float(inBuf);
   }
   gamma = map(value1,-0.7,0.7,-3 ,3)*100;
   rambda = 1+abs(gamma);
   bar1[M] = abs(value1)*2*1E4;
   L+=1;
   N+=1;
   M+=1;
   sum +=abs(value1);
   if(N%10==0){
     sumsave = sum;
     ave = sumsave/10;
     sum=0;
  }
 }
 // write red point
 delta +=gamma*1.5;
 x = amp*sin(radians(4*omega*count*0.125))+centX;
 y = amp*sin(radians(6*rambda*omega*count*0.125+delta%360))+centY;
 
 background(0,0,0);
 
 pg.beginDraw();
 pg.fill(0,15);
 pg.rect(0,0,width,height);
 pg.fill(255,0,0);
 pg.circle(x,y,4.5);
 if(count%840==1){
   pg.fill(0,0,0);
   pg.rect(0,0,width,height);
 }
 pg.endDraw();
 image(pg,0,0);
 
 //write wave
 beginShape(); 
 noFill();
 stroke(255,0,0);
 strokeWeight(1);
 for (float t =0;t<360;t+=0.01){
   angle = map(t,0,360,0,2*PI);
   x1 = amp*sin(4*angle)+centX;
   y1 = amp*sin(6*rambda*angle+radians(delta%360))+centY;
   vertex(x1, y1);
 }
 endShape();
 noFill();
 drawTitle();
 //write bar
 if(N>10){
   average();
   voltage();
   voltage2();
 }
 //update bar
 if(M%10==0){
   M=0;
   bar2 = bar1;
 }
 
 //write lattice
   stroke(0,150,255,150);
   line(centX-laticesize-cross,centY+laticesize+cross-count%210*(laticesize+cross)*2/210,centX+laticesize+cross,centY+laticesize+cross-count%210*(laticesize+cross)*2/210);
   line(centX-laticesize-cross,centY-laticesize+cross+count%280*(laticesize+cross)*2/280,centX+laticesize+cross,centY-laticesize+cross+count%280*(laticesize+cross)*2/280);
   stroke(255,255,255);
 //flash the lattice
 if (count%2==0){
   latice();
 }
 if(count%5==0){
   k+=1;
 }
 // reset delta
 if (count%840==0){
   background(255,255,255);
   delta = 0; 
 }
 //prevent overflow
 if(count==86400){
   N=0;
   L=0;
   count=0;
 }
 //flash back
 if(abs(value1)<1E-6 && Q>=0){
   translate(0,0);
   image(IMAGES[Q],0,0,width,height); 
   Q+=-1;
 }
 if (abs(value1)>1E-6 && Q<=0) Q=19;
 hint(ENABLE_DEPTH_TEST);
}


void latice(){
  translate(centX,centY);
  float dx = laticesize*2/4;
  float dy = laticesize*2/4;
  for(int j=0;j<5;j++){
    float dx2 = dx*j;
    float dy2 = dy*j;
    for(int i=0;i<5;i++){
      float dx1 = dx*i;
      float dy1 = dy*i;
      line(-laticesize+dx1-cross,laticesize-dy2,-laticesize+dx1+cross,laticesize-dy2);
      line(-laticesize+dx2,laticesize-dy1-cross,-laticesize+dx2,laticesize-dy1+cross);
    }
  }
}

void drawTitle() { 
  fill(255);
  textAlign(CENTER);
  textSize(14);
  text("phase="+delta%360,centX+105,centY+90);
  textSize(18);
  text("x="+x,centX-540,height-20);
  text("y="+y,centX-270,height-20);
  text("voltage="+value1+"mV",centX,height-20);
  text("gamma="+gamma,centX+250,height-20);
  text("ambient sensor ver1.0.1",centX+550,height-20);
  text("average="+ave,centX-500,20);
  text("current voltage",centX-10,20);
  text("recorded voltage",centX+400,20);
}

void average(){
  noStroke();
  fill(255,255,255);
  rect(centX-290,15,ave*6*1E5,8);
}

void voltage(){
  noStroke();
  for(int i=1;i<M;i++){
  fill(255,255,255);
  rect(centX+60+bar1[i-1]+15*i,15,bar1[i],8);
  }
}
void voltage2(){
  P = k%10;
  for (int s=1;s<=P;s++){ 
  fill(255,255,255);
  rect(centX+500+bar2[s-1]+15*s,15,bar2[s],8);
  }
}
