import java.util.List;

import toxi.geom.*;
import toxi.geom.mesh2d.Voronoi;

List<Vec2D> points;

void setup() {
  size(800, 600);

  noFill();

  points = new ArrayList<Vec2D>();

  int n_points = 50;

  for (int i=0; i<n_points; i++) {
    points.add( new Vec2D(random(width), random(height)));
  }
}

void draw() {
  background(255);

  Voronoi voronoi = new Voronoi();

  voronoi.addPoints(points);

  Rect bound_rect = new Rect(0, 0, width, height);

  SutherlandHodgemanClipper clipper = new SutherlandHodgemanClipper(bound_rect);

  List<Polygon2D> regions = voronoi.getRegions();

  for (int i=0; i<regions.size(); i++) {
    regions.set(i, clipper.clipPolygon(regions.get(i)));
    Vec2D centroid = regions.get(i).getCentroid();
    points.set(i, centroid);
  }

  drawPoints(points);

  drawPolygons(regions);
}

void drawPoints(List<Vec2D> pts) {
  for (Vec2D p : pts)
    ellipse(p.x, p.y, 2, 2);
}

void drawPolygons(List<Polygon2D> ps) {
  for (Polygon2D p : ps)
    drawPolygon(p);
}

void drawPolygon(Polygon2D p) {
  beginShape();
  for (Vec2D v : p.vertices)
    vertex(v.x, v.y);
  endShape(CLOSE);
}

void mousePressed() {
  points.add(new Vec2D(mouseX, mouseY));
}

void mouseDragged() {
  points.add(new Vec2D(mouseX, mouseY));
}