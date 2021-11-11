//      ___      .___  ___. .______    __   _______ .__   __. .___________.        _______. _______ .__   __.      _______.  ______   .______
//     /   \     |   \/   | |   _  \  |  | |   ____||  \ |  | |           |       /       ||   ____||  \ |  |     /       | /  __  \  |   _  \
//    /  ^  \    |  \  /  | |  |_)  | |  | |  |__   |   \|  | `---|  |----`      |   (----`|  |__   |   \|  |    |   (----`|  |  |  | |  |_)  |
//   /  /_\  \   |  |\/|  | |   _  <  |  | |   __|  |  . `  |     |  |            \   \    |   __|  |  . `  |     \   \    |  |  |  | |      /
//  /  _____  \  |  |  |  | |  |_)  | |  | |  |____ |  |\   |     |  |        .----)   |   |  |____ |  |\   | .----)   |   |  `--'  | |  |\  \----.
// /__/     \__\ |__|  |__| |______/  |__| |_______||__| \__|     |__|        |_______/    |_______||__| \__| |_______/     \______/  | _| `._____|

float x,y,z,angle,delta;
float x1,y1;
float centX,centY;
float count;
PGraphics pg;
float omega = radians(360);
float gamma,rambda;
String [][] csv;
float [] bar1;
float [] bar2;
int LENGTH;
float y_maxv;
float y_minv;
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

void setup(){
  background(0,0,0);
  fullScreen(P3D,2);
  smooth(10);
  centX = width/2;
  centY = height/2;
  amp = height/3.8;
  laticesize = width/5.4;
  cross =6;
  pg = createGraphics(width,height);
  frameRate(1000);
  rectMode(CENTER);
  String lines[] = loadStrings("ycam-3-20130501.csv");
  int csvWidth=0;
  for (int i=1; i < lines.length; i++) {
    String [] chars=split(lines[i],',');
    if (chars.length>csvWidth){
      csvWidth=chars.length;
    }
  }
  csv = new String [lines.length][csvWidth];
  LENGTH =lines.length; 
  for (int i=0; i < lines.length; i++) {
    String [] temp = new String [lines.length];
    temp= split(lines[i], ',');
    for (int j=0; j < temp.length; j++){
     csv[i][j]=temp[j];
       if (csv[i][j].startsWith("\"") && csv[i][j].endsWith("\"")) {
          csv[i][j] = csv[i][j].substring(1, csv[i][j].length() - 1);
      }
    }
  }
  y_maxv = float(csv[1][1]);
   for (int i=1; i < lines.length; i++) {
     if(y_maxv < float(csv[i][1])){
    y_maxv = float(csv[i][1]);
    }
   }
  y_minv = float(csv[1][1]);
   for (int i=1; i < lines.length; i++) {
     if(y_minv > float(csv[i][1])){
    y_minv = float(csv[i][1]);
    }
   }
   L=1;
   N=0;
   M=0;
   P=0;
   sum=0;
   ave=0;
   sumsave=0;
   bar1 = new float[10];
   bar2 = new float[10];
}

void draw(){  
 translate(0,0);
 hint(DISABLE_DEPTH_TEST);
 count = frameCount -1;
 if(count%70==0){
   // ここは電位に従うように．
   value1 = Float.parseFloat(csv[L][1]);
   gamma = map(value1,y_minv,y_maxv,-3 
    ,3)*10;
   rambda = 1+abs(gamma);
   bar1[M] = abs(value1)*50;
   L+=1;
   N+=1;
   M+=1;
   sum +=abs(value1)*100;
   if(N%10==0){
     sumsave = sum;
     ave = sumsave/10;
     sum=0;
  }
 }
 delta +=gamma;
 x = amp*sin(radians(4*omega*count*0.125))+centX;
 y = amp*sin(radians(6*rambda*omega*count*0.125+delta%360))+centY;
 
 background(0,0,0);
 
 pg.beginDraw();
 pg.fill(0,10);
 pg.rect(0,0,width,height);
 pg.fill(255,0,2);
 pg.circle(x,y,4.5);
 pg.endDraw();

 image(pg,0,0);
 //ここに回る楕円を入れられたらいいな．
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
 
 //文字とave
 noFill();
 drawTitle();
 if(N>10){
   average();
   voltage();
   voltage2();
 }
 if(M%10==0){
   M=0;
   bar2 = bar1;
 }
 
 //バチバチ
 if (abs(delta%360)<30){
   if (count%5==0){
   background(0,0,0);
   }
 }
 //スキャン
   stroke(0,150,255,150);
   line(centX-laticesize-cross,centY+laticesize+cross-count%210*(laticesize+cross)*2/210,centX+laticesize+cross,centY+laticesize-count%210*(laticesize+8)*2/210);
   line(centX-laticesize-cross,centY-laticesize+cross+count%280*(laticesize+cross)*2/280,centX+laticesize+cross,centY-laticesize+count%280*(laticesize+8)*2/280);
    //line(centX-308+count%210*616/210,centY-300,centX-308+count%210*616/210,centY+300);
    //line(centX-308,y,centX+308,y);
    //line(x,centY-300,x,centY+300);
   stroke(255,255,255);
   //格子
 if (count%3==0){
   latice();
 }
 if(count%5==0){
   k+=1;
 }
 //ホワイトアウト
 if (count%840==0){
   background(255,255,255);
   delta = 0; 
 }
//overflow防止
 if(count==86400){
   N=0;
   //csvから読む限り，L=0のリセットは必要ないけど，長時間回すことを考えるとね，
   L=0;
   count=0;
 }
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
  textSize(8);
  text("phase="+delta%360,centX+95,centY+65);
  textSize(10);
  text("x="+x,centX-380,height-20);
  text("y="+y,centX-190,height-20);
  text("voltage="+value1+"mV",centX,height-20);
  text("gamma="+gamma,centX+190,height-20);
  text("ambient sensor ver1.0.1",centX+380,height-20);
  text("average="+ave,centX-400,20);
  text("current voltage",centX-100,20);
  text("recorded voltage",centX+200,20);
}

void average(){
  noStroke();
  fill(255,255,255);
  rect(centX-260,15,ave*10,8);
}

void voltage(){
  noStroke();
  for(int i=1;i<M;i++){
  fill(255,255,255);
  rect(centX-40+bar1[i-1]+10*i,15,bar1[i],8);
  }
}
void voltage2(){
  P = k%10;
  for (int s=1;s<=P;s++){ 
  //stroke(255,255,255);
  fill(255,255,255);
  rect(centX+260+bar2[s-1]+10*s,15,bar2[s],8);
  }
}
