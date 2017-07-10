/*

Vase generator for 3D printing.

www.codeplastic.com

MIT License

Copyright (c) 2017 Przemek Jaworski - Alberto Maria Giachino

*/

import java.util.Collections;
import java.util.Comparator; 

import peasy.*;
import peasy.org.apache.commons.math.*;
import peasy.org.apache.commons.math.geometry.*;

PeasyCam cam; // Peasy cam for 3d views

import controlP5.*;

ControlP5 cp5; // Control P5 for GUI

Builder builder;

void setup() {
  size(800, 600, P3D);

  cam = new PeasyCam(this, 100);

  builder = new Builder();

  // Initialize Control P5
  cp5 = new ControlP5(this);
  cp5.setAutoDraw(false);
  setGui();
}

void draw() {
  background(255);

  builder.visualize();

  gui();
}