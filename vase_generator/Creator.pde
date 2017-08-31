class Creator {
  ArrayList<Path> paths = new ArrayList<Path>();

  Printer printer;
  Settings settings;

  Creator(Printer t_printer, Settings t_settings) {
    printer = t_printer;
    settings = t_settings;
  }
}

class Vase extends Creator {
  float center_x;
  float center_y;

  float len = 10;
  float wid = 10;
  float hei = 10;

  int sides = 4;

  float increment_rotation = 0;

  float amount_oscillation_XY = 0;
  float increment_oscillation_XY = 0;

  float amount_oscillation_Z = 0;
  float increment_oscillation_Z = 0;

  float top_gradient = 1.0;
  float bottom_gradient = 1.0;

  Vase(Printer t_printer, Settings t_settings, float c_x, float c_y) {
    super(t_printer, t_settings);
    center_x = c_x;
    center_y = c_y;
  }

  void generate() {

    paths = new ArrayList<Path>();

    float tot_layers = hei / settings.layer_height;
    float z = 0;

    float angle_increment = TWO_PI / (float)sides;

    float rotation = 0;

    float oscillation_Z = 0;

    float gradient = 1;

    for (int layer = 0; layer<tot_layers; layer++) {

      gradient = map(layer, 0, tot_layers, bottom_gradient, top_gradient);

      z += settings.layer_height;
      rotation += increment_rotation;
      oscillation_Z += increment_oscillation_Z;

      Path new_path = new Path();

      float oscillation_XY = 0;

      for (float angle = 0; angle<=TWO_PI; angle+=angle_increment) {

        oscillation_XY+=increment_oscillation_XY;

        float x = center_x + cos(angle + rotation) * (len + sin(oscillation_XY) * amount_oscillation_XY + sin(oscillation_Z) * amount_oscillation_Z);
        float y = center_y + sin(angle + rotation) * (wid + sin(oscillation_XY) * amount_oscillation_XY + sin(oscillation_Z) * amount_oscillation_Z);

        PVector next_point = new PVector(x, y, z);

        new_path.addPoint(next_point);
      }

      new_path.makeClosed();
      new_path.setGradient(gradient);
      paths.add(new_path);
    }
  }

  Vase setCenter(float x, float y) {
    center_x = constrain(x, 0, printer.width_table);
    center_y = constrain(y, 0, printer.length_table);
    return this;
  }

  Vase setLength(float l) {
    len = constrain(l, settings.path_width, max(printer.width_table, printer.length_table));
    return this;
  }

  Vase setWidth(float w) {
    wid = constrain(w, settings.path_width, max(printer.width_table, printer.length_table));
    return this;
  }

  Vase setWidthAndLength(float wl) {
    wid = constrain(wl, settings.path_width, max(printer.width_table, printer.length_table));
    len = constrain(wl, settings.path_width, max(printer.width_table, printer.length_table));
    return this;
  }

  Vase setHeight(float h) {
    hei = constrain(h, settings.layer_height, printer.height_printer);
    return this;
  }

  Vase setSides(int n) {
    sides = n;
    return this;
  }

  Vase setRotation(float r) {
    increment_rotation = r;
    return this;
  }

  Vase setOscillationXYAmount(float w_l_xy) {
    amount_oscillation_XY = w_l_xy;
    return this;
  }

  Vase setOscillationXY(float w_xy) {
    increment_oscillation_XY = w_xy;
    return this;
  }

  Vase setOscillationZAmount(float w_l_z) {
    amount_oscillation_Z = w_l_z;
    return this;
  }

  Vase setOscillationZ(float w_z) {
    increment_oscillation_Z = w_z;
    return this;
  }

  Vase setBottomGradient(float b_g) {
    bottom_gradient = b_g;
    return this;
  }
  Vase setTopGradient(float t_g) {
    top_gradient = t_g;
    return this;
  }
}