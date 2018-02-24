import toxi.geom.*;
import toxi.geom.mesh.*;
import toxi.volume.*;
import toxi.processing.*;

import peasy.*;
import peasy.org.apache.commons.math.*;
import peasy.org.apache.commons.math.geometry.*;

PeasyCam cam;

ToxiclibsSupport gfx;

VolumetricSpace volume;
VolumetricBrush brush;
IsoSurface surface;
TriangleMesh mesh;

ArrayList<Agent> agents;
ArrayList<Vec3D> food;


int N_AGENTS=500;

int DIMX=200;
int DIMY=200;
int DIMZ=25;

Vec3D SCALE=new Vec3D(1, 1, 0.1).scaleSelf(50);

float ISO_THRESHOLD = 0.5;
float DENSITY=0.5;


void setup() {
  size(1024, 768, P3D);

  noStroke();
  fill(255);

  cam = new PeasyCam(this, 50);
  cam.setMinimumDistance(1);
  cam.setMaximumDistance(100);

  gfx=new ToxiclibsSupport(this);
  volume=new VolumetricSpaceArray(SCALE, DIMX, DIMY, DIMZ);

  brush=new RoundBrush(volume, 0.1);
  surface=new ArrayIsoSurface(volume);
  mesh=new TriangleMesh();

  agents = new ArrayList<Agent>();
  for (int i=0; i<N_AGENTS; i++) {
    agents.add(new Agent(random(DIMX), random(DIMY), DIMZ/2));
  }

  food = new ArrayList<Vec3D>();
}


void draw() {
  background(0);

  myLights();

  for (Agent agent : agents) {

    agent.setSpeed(cos(noise(agent.x*0.1, agent.y*0.1)*TWO_PI), sin(noise(agent.x*0.1, agent.y*0.1)*TWO_PI), 0);
    agent.update(food);

    brush.setSize(agent.size);
    brush.drawAtGridPos(agent.x, agent.y, agent.z, DENSITY);
  }

  volume.closeSides();  

  surface.reset();
  surface.computeSurfaceMesh(mesh, ISO_THRESHOLD);

  myPerspective();
  gfx.mesh(mesh);
}

class Agent extends Vec3D {
  Vec3D speed;
  boolean active = true;
  float size = 0.25;
  int age = 0;

  Agent(float x, float y, float z) {
    super(x, y, z);
  }

  void setSpeed(float x, float y, float z) {
    speed = new Vec3D(x, y, z);
  }


  void eat(ArrayList<Vec3D> food) {
    ArrayList<Vec3D> food_update = new ArrayList<Vec3D>();
    boolean has_eaten = false;
    for (int i=0; i<food.size(); i++) {
      if (!has_eaten) {
        float dist = sqrt(sq(x-food.get(i).x)+sq(y-food.get(i).y)+sq(z-food.get(i).z)); 
        if (dist<2*size) {
          size+=0.0125;
          has_eaten = true;
        } else {
          food_update.add(food.get(i));
        }
      } else {
        food_update.add(food.get(i));
      }
    }
    food = food_update;
  }

  void growFood(ArrayList<Vec3D> food) {
    if (active)
      food.add(new Vec3D(x, y, z));
  }

  void update(ArrayList<Vec3D> food) {
    if (active) {
      age++;

      eat(food);

      if (age%100 == 0)
        growFood(food);

      x+=speed.x;
      y+=speed.y;
      z+=speed.z;

      if (x<0 || x>DIMX || y<0 || y>DIMY)
        active = false;
    }
  }
}

void exportSimpleMesh() {
  mesh.saveAsSTL(sketchPath("scribble"+(System.currentTimeMillis()/1000)+".stl"));
}

void exportSubdividedMesh() {
  WETriangleMesh we_mesh = mesh.toWEMesh();
  we_mesh.subdivide();
  new LaplacianSmooth().filter(we_mesh, 2);
  //we_mesh.saveAsOBJ(sketchPath("scribble"+(System.currentTimeMillis()/1000)+".obj"));
  we_mesh.saveAsSTL(sketchPath("scribble"+(System.currentTimeMillis()/1000)+".stl"));
}

void myPerspective() { // Avoid clipping the view
  float fov = PI/3.0;
  float cameraZ = (height/2.0) / tan(fov/2.0);
  perspective(fov, float(width)/float(height), cameraZ/500.0, cameraZ*10.0);
}

void myLights() {
  directionalLight(240, 240, 240, 0.25, 0.25, 1);
  directionalLight(240, 240, 240, 0, 0, -1);
  lightSpecular(240, 240, 240);
  shininess(1);
}

void keyPressed() {
  if (key=='s') { 
    exportSimpleMesh();
  }
  if (key=='e') {
    exportSubdividedMesh();
  }
}