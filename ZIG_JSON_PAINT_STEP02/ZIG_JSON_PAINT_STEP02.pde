/**
 * (./) udp.pde - how to use UDP library as unicast connection
 * (cc) 2006, Cousot stephane for The Atelier Hypermedia
 * (->) http://hypermedia.loeil.org/processing/
 */
 
// import UDP library
import hypermedia.net.*;

UDP udp;  // define the UDP object

PVector accel,gyro,gravity;
float compass;
Quaternion quaternion;
Device device = new Device();
ArrayList<Touch> touch = new ArrayList<Touch>();

PVector pTouch; //previousTouch

void setup() {
  udp = new UDP( this, 50001 );
  udp.listen( true );
  size(640, 640);
  background(0);
}

void draw() {
  noStroke();
  colorMode(RGB,256);
  fill(0,10);
  rect(0,0,width,height);
  strokeWeight(10);
  
  stroke(255);

  if(touch.size() > 0){
    Touch t = touch.get(0);
    if(pTouch == null){
      pTouch = new PVector((t.x + 1)/2 * width,(t.y + 1)/2 * height);
    }
    PVector newTouch = new PVector((t.x + 1)/2 * width,(t.y + 1)/2 * height);
    
    line(newTouch.x, newTouch.y, pTouch.x, pTouch.y);

    pTouch.set(newTouch.x,newTouch.y);
  }else{
    pTouch = null;
  }
}

void receive( byte[] receiveData) {
  
  receiveData = subset(receiveData, 0, receiveData.length);
  String message = new String( receiveData );
    //println(message);
    
  JSONObject json = parseJSONObject(message + "");

  JSONObject deviceJson = json.getJSONObject("device");
  
  device.name = deviceJson.getString("name");
  device.uuid = deviceJson.getString("uuid");
  device.displayheight = deviceJson.getInt("displayheight");
  device.displaywidth = deviceJson.getInt("displaywidth");
  
  println("name:" + device.name + ",uuid:" + device.uuid + ",displayheight:" + device.displayheight + ",displayWidth:" + device.displaywidth);
  
  JSONObject data = json.getJSONObject("sensordata");
  
  if(!data.isNull("accel")){
    float accelX = data.getJSONObject("accel").getFloat("x");
    float accelY = data.getJSONObject("accel").getFloat("y");
    float accelZ = data.getJSONObject("accel").getFloat("z");
    if(accel == null){
      accel = new PVector(accelX,accelY,accelZ);
    }else{
      accel.set(accelX,accelY,accelZ);
    }
    println("accel x:" + accel.x + ",y:" + accel.y + ",z:" + accel.z);
  }
  if(!data.isNull("gravity")){
    float gravityX = data.getJSONObject("gravity").getFloat("x");
    float gravityY = data.getJSONObject("gravity").getFloat("y");
    float gravityZ = data.getJSONObject("gravity").getFloat("z");
    if(gravity == null){
      gravity = new PVector(gravityX,gravityY,gravityZ);
    }else{
      gravity.set(gravityX,gravityY,gravityZ);
    }
    println("gravity x:" + gravity.x + ",y:" + gravity.y + ",z:" + gravity.z);
  }
  if(!data.isNull("gyro")){
    float gyroX = data.getJSONObject("gyro").getFloat("x");
    float gyroY = data.getJSONObject("gyro").getFloat("y");
    float gyroZ = data.getJSONObject("gyro").getFloat("z");
    if(gyro == null){
      gyro = new PVector(gyroX,gyroY,gyroZ);
    }else{
      gyro.set(gyroX,gyroY,gyroZ);
    }
    println("gyro x:" + gyro.x + ",y:" + gyro.y + ",z:" + gyro.z);
  }
  if(!data.isNull("quaternion")){
    float qX = data.getJSONObject("quaternion").getFloat("x");
    float qY = data.getJSONObject("quaternion").getFloat("y");
    float qZ = data.getJSONObject("quaternion").getFloat("z");
    float qW = data.getJSONObject("quaternion").getFloat("w");
    if(quaternion == null){
      quaternion = new Quaternion(qX,qY,qZ,qW);
    }else{
      quaternion.set(qX,qY,qZ,qW);
    }
    println("quaternion x:" + quaternion.x + ",y:" + quaternion.y + ",z:" + quaternion.z + ",w:" + quaternion.w);
  }
  
  if(!data.isNull("touch")){
    JSONArray touchJson = data.getJSONArray("touch");
    touch.clear();
    for (int i = 0; i < touchJson.size(); i++) {
      float x = touchJson.getJSONObject(i).getFloat("x");
      float y = touchJson.getJSONObject(i).getFloat("y");
      Touch t = new Touch(x,y);
      if(!touchJson.getJSONObject(i).isNull("radius")){
        t.setRadius(touchJson.getJSONObject(i).getFloat("radius"));
      }
      if(!touchJson.getJSONObject(i).isNull("force")){
        t.setForce(touchJson.getJSONObject(i).getFloat("force"));
      }
      touch.add(t);
      println("touch " + i + " x:" + t.x + ",y:" + t.y + ",radius:" + t.radius + ",force:" + t.force);
    }
  }
}

class Device{
  String name,uuid,os,osversion;
  int displaywidth,displayheight;
  Device(){

  }
}
class Touch{
  float x,y;
  float radius,force;
  Touch(float _x,float _y){
    x = _x;
    y = _y;
  }
  void setRadius(float _radius){
    radius = _radius;
  }
  void setForce(float _force){
    force = _force;
  }
}

class Quaternion{
  float x,y,z,w;
  Quaternion(float _x,float _y,float _z,float _w){
    x = _x;
    y = _y;
    z = _z;
    w = _w;
  }
  void set(float _x,float _y,float _z,float _w){
    x = _x;
    y = _y;
    z = _z;
    w = _w;
  } 
}