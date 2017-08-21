class Path {
  ArrayList<PVector> vertices;
  float gradient = 1;

  Path() {
    vertices = new ArrayList<PVector>();
  }

  void setGradient(float g) {
    gradient = g;
  }

  void addPoint(PVector p) {
    vertices.add(p);
  }

  PVector getCenter() {

    float mean_X = 0, mean_Y = 0, mean_Z = 0;

    for (PVector p : vertices) {
      mean_X += p.x;
      mean_Y += p.y;
      mean_Z += p.z;
    }

    mean_X = mean_X / vertices.size();
    mean_Y = mean_Y / vertices.size();
    mean_Z = mean_Z / vertices.size();

    PVector center = new PVector(mean_X, mean_Y, mean_Z);

    return center;
  }

  void makeClosed() {
    if (vertices.size()>0)
      vertices.add(vertices.get(0));
  }
}