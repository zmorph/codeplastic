import processing.dxf.*;
import processing.svg.*;


Pack pack;

boolean growing = false;

void setup() {
  size(1400, 800);

  noFill();
  stroke(255);

  noiseDetail(2, 0.1);

  pack = new Pack();
}

void draw() {
  background(50);

  pack.run();

  if (growing)
    pack.addCircle(new Circle(width/2, height/2));

  //saveFrame("frames/#####.tif");
}


class Pack {
  ArrayList<Circle> circles;

  float max_speed = 1;
  float max_force = 1;

  Pack() {  
    initiate();
  }

  void initiate() {
    circles = new ArrayList<Circle>(); 
    for (int i = 0; i < 500; i++) {
      addCircle(new Circle(width/2, height/2));
    }
  }

  void addCircle(Circle b) {
    circles.add(b);
  }

  void run() {

    PVector[] separate_forces = new PVector[circles.size()];
    int[] near_circles = new int[circles.size()];

    for (int i=0; i<circles.size(); i++) {
      checkBorders(i);
      updateCircleRadius(i);
      checkCirclePosition(i);
      applySeparationForcesToCircle(i, separate_forces, near_circles);
      displayCircle(i);
    }
  }

  void checkBorders(int i) {
    Circle circle_i=circles.get(i);
    if (circle_i.position.x-circle_i.radius/2 < 0 || circle_i.position.x+circle_i.radius/2 > width)
    {
      circle_i.velocity.x*=-1;
      circle_i.update();
    }
    if (circle_i.position.y-circle_i.radius/2 < 0 || circle_i.position.y+circle_i.radius/2 > height)
    {
      circle_i.velocity.y*=-1;
      circle_i.update();
    }
  }

  void updateCircleRadius(int i) {
    circles.get(i).updateRadius();
  }

  void checkCirclePosition(int i) {

    Circle circle_i=circles.get(i);

    for (int j=i+1; j<=circles.size(); j++) {

      Circle circle_j = circles.get(j == circles.size() ? 0 : j);

      int count = 0;

      float d = PVector.dist(circle_i.position, circle_j.position);

      if (d < circle_i.radius/2+circle_j.radius/2) {
        count++;
      }

      // Zero velocity if no neighbours
      if (count == 0) {
        circle_i.velocity.x = 0.0;
        circle_i.velocity.y = 0.0;
      }
    }
  }


  void applySeparationForcesToCircle(int i, PVector[] separate_forces, int[] near_circles) {

    if (separate_forces[i]==null)
      separate_forces[i]=new PVector();

    Circle circle_i=circles.get(i);

    for (int j=i+1; j<circles.size(); j++) {

      if (separate_forces[j] == null) 
        separate_forces[j]=new PVector();

      Circle circle_j=circles.get(j);

      PVector forceij = getSeparationForce(circle_i, circle_j);

      if (forceij.mag()>0) {
        separate_forces[i].add(forceij);        
        separate_forces[j].sub(forceij);
        near_circles[i]++;
        near_circles[j]++;
      }
    }

    if (near_circles[i]>0) {
      separate_forces[i].div((float)near_circles[i]);
    }

    if (separate_forces[i].mag() >0) {
      separate_forces[i].setMag(max_speed);
      separate_forces[i].sub(circles.get(i).velocity);
      separate_forces[i].limit(max_force);
    }

    PVector separation = separate_forces[i];

    circles.get(i).applyForce(separation);
    circles.get(i).update();
  }

  PVector getSeparationForce(Circle n1, Circle n2) {
    PVector steer = new PVector(0, 0, 0);
    float d = PVector.dist(n1.position, n2.position);
    if ((d > 0) && (d < n1.radius/2+n2.radius/2)) {
      PVector diff = PVector.sub(n1.position, n2.position);
      diff.normalize();
      diff.div(d);
      steer.add(diff);
    }
    return steer;
  }

  void exportDXF() {
    String exportName = getSaveName()+".dxf";
    PGraphics pg = createGraphics(width, height, DXF, exportName);
    pg.beginDraw();
    for (int i=0; i<circles.size(); i++) {
      Circle p = circles.get(i);
      dxfCircle(p.position.x, p.position.y, p.radius, 60, pg);
    }
    pg.endDraw();
    pg.dispose();
    pg.endRaw();

    println(exportName + " saved.");
  } 

  void dxfCircle(float x, float y, float r, float detail, PGraphics pg) {
    float inc = TWO_PI / detail;

    float px = x +cos(0)*r/2;
    float py = y +sin(0)*r/2;   
    for (float a=inc; a<TWO_PI; a+=inc) {
      float x1 = x +cos(a)*r/2;
      float y1 = y +sin(a)*r/2;
      pg.line(px, py, x1, y1);
      px=x1;
      py=y1;
    }
  }


  void exportSVG() {
    String exportName = getSaveName()+".svg";
    PGraphics pg = createGraphics(width, height, SVG, exportName);
    pg.beginDraw();
    for (int i=0; i<circles.size(); i++) {
      Circle p = circles.get(i);
      pg.ellipse(p.position.x, p.position.y, p.radius, p.radius);
    }
    pg.endDraw();
    pg.dispose();
    println(exportName + " saved.");
  }

  String getSaveName() {
    return  day()+""+hour()+""+minute()+""+second();
  }

  void displayCircle(int i) {
    circles.get(i).display();
  }
}

class Circle {

  PVector position;
  PVector velocity;
  PVector acceleration;

  float radius;

  Circle(float x, float y) {
    acceleration = new PVector(0, 0);
    velocity = PVector.random2D();
    position = new PVector(x, y);
    updateRadius();
  }

  void applyForce(PVector force) {
    acceleration.add(force);
  }

  void update() {
    //velocity.add(noise(100+position.x*0.01, 100+position.y*0.01)*0.5, noise(200+position.x*0.01, 200+position.y*0.01)*0.5); 
    velocity.add(acceleration);
    position.add(velocity);
    acceleration.mult(0);
  }

  void updateRadius() {
    radius = 2 + noise(position.x*0.01, position.y*0.01) * 50;
  }

  void display() {
    ellipse(position.x, position.y, radius, radius);
  }
}

void mouseDragged() {
  pack.addCircle(new Circle(mouseX, mouseY));
}

void keyPressed() {
  if (key == 'r' || key == 'R') {
    pack.initiate();
    noiseSeed((long)random(100000));
  } else if (key == 'p' || key == 'P') {
    growing=!growing;
  } else if (key == 's' || key == 'S') {
    String name = ""+day()+hour()+minute()+second();
    pack.exportDXF();
    pack.exportSVG();
    saveFrame(name+".png");
    println(name + " saved.");
  }
}