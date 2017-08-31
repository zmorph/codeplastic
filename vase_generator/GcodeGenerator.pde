enum Extruder { //<>// //<>//
  T0, T1, T3
}

class GcodeGenerator {

  ArrayList<String> gcode;
  Printer printer;
  Settings settings;
  Processor processor;

  float E = 0; // Left extruder
  float A = 0; // Right extruder
  float last_gradient = 1;

  GcodeGenerator(Printer t_printer, Settings t_settings, Processor t_processor) {
    printer = t_printer;
    settings = t_settings;
    processor = t_processor;
  }

  GcodeGenerator generate() {
    Extruder last_extruder = Extruder.T0;

    gcode = new ArrayList<String>();

    float extrusion_multiplier = 1;

    startPrint();

    for (Path path : processor.paths) {

      moveTo(path.vertices.get(0), last_gradient);

      if (getLayerNumber(path.vertices.get(0)) < settings.start_fan_at_layer) {
        setSpeed(settings.default_speed/2);
      } else if (getLayerNumber(path.vertices.get(0)) == settings.start_fan_at_layer) {
        setSpeed(settings.default_speed);
        enableFan();
      } else {
        setSpeed(settings.default_speed);
      }

      Extruder current_extruder = getExtruder(path.gradient);
      setExtruder(last_extruder, current_extruder);

      write("G92 E0.0");
      E = 0;
      if (current_extruder == Extruder.T3) {
        write("G92 A0.0");
        A = 0;
      }

      extrusion_multiplier = getLayerNumber(path.vertices.get(0)) == 1 ? settings.extrusion_multiplier : 1;

      for (int i=0; i<path.vertices.size()-1; i++) {
        PVector p1 = path.vertices.get(i);
        PVector p2 = path.vertices.get(i+1);
        extrudeTo(p1, p2, extrusion_multiplier, path.gradient);
      }

      last_gradient = path.gradient;
      last_extruder = current_extruder;
    }

    endPrint();

    return this;
  }


  Extruder getExtruder(float gradient) {
    if (abs(gradient-1)<EPSILON)
      return Extruder.T0; 
    else if (abs(gradient-0)<EPSILON)
      return Extruder.T1;
    else 
    return Extruder.T3;
  }

  void setExtruder(Extruder last_extruder, Extruder current_extruder) {
    if (last_extruder == current_extruder)
      return;
    else
    {
      if (current_extruder == Extruder.T0)
        write("T0");
      else if (current_extruder == Extruder.T1)
        write("T1");
      else if (current_extruder == Extruder.T3)
        write("T3");
      else 
      {
        println("   ERROR *** Extruder type not found\n");
        exit();
      }
    }
  }

  int getLayerNumber(PVector p) {
    return (int)(p.z/settings.layer_height);
  }

  void write(String command) {
    gcode.add(command);
  }

  void moveTo(PVector p, float gradient) {
    retract(gradient);
    write("G1 " + "X" + p.x + " Y" + p.y + " Z" + p.z + " F" + settings.travel_speed);
    recover(gradient);
  }

  float extrude(PVector p1, PVector p2) {
    float points_distance = dist(p1.x, p1.y, p2.x, p2.y);
    float volume_extruded_path = settings.getExtrudedPathSection() * points_distance;
    float length_extruded_path = volume_extruded_path / settings.getFilamentSection();
    return length_extruded_path;
  }

  void extrudeTo(PVector p1, PVector p2, float extrusion_multiplier, float gradient) {
    if (abs(gradient-1)<EPSILON || abs(gradient-0)<EPSILON) {
      E+=(extrude(p1, p2) * extrusion_multiplier);
      write("G1 " + "X" + p2.x + " Y" + p2.y + " Z" + p2.z + " E" + E);
    } else {
      E+=(extrude(p1, p2) * extrusion_multiplier * gradient);
      A+=(extrude(p1, p2) * extrusion_multiplier * (1-gradient));
      write("G1 " + "X" + p2.x + " Y" + p2.y + " Z" + p2.z + " E" + E + " A" + A);
    }
  }

  void retract(float gradient) {
    if (abs(gradient-1)<EPSILON || abs(gradient-0)<EPSILON) {
      E-=settings.retraction_amount;
      write("G1" + " E" + E + " F" + settings.retraction_speed);
    } else {
      E-=(settings.retraction_amount * gradient);
      A-=(settings.retraction_amount * (1-gradient));
      write("G1" + " E" + E + " A" + A + " F" + settings.retraction_speed);
    }
  }

  void recover(float gradient) {
    if (abs(gradient-1)<EPSILON || abs(gradient-0)<EPSILON) {
      E+=settings.retraction_amount;
      write("G1" + " E" + E + " F" + settings.retraction_speed);
    } else {
      E+=(settings.retraction_amount * gradient);
      A+=(settings.retraction_amount * (1-gradient));
      write("G1" + " E" + E + " A" + A + " F" + settings.retraction_speed);
    }
  }

  void setSpeed(float speed) {
    write("G1 F" + speed);
  }

  void enableFan() {
    write("M 106");
  }

  void disableFan() {
    write("M 107");
  }

  void startPrint() {
    write("G91"); //Relative mode
    write("G1 Z1"); //Up one millimeter
    write("G28 X0 Y0"); //Home X and Y axes
    write("G90"); //Absolute mode
    write("G1 X" + printer.x_center_table + " Y" + printer.y_center_table + " F8000"); //Go to the center
    write("G28 Z0"); //Home Z axis
    write("G1 Z0"); //Go to height 0
    write("T0"); //Select extruder 1
    write("G92 E0"); //Reset extruder position to 0
  }


  void endPrint() {

    Path lastPath = processor.paths.get(processor.paths.size()-1);

    PVector last_position =lastPath.vertices.get(lastPath.vertices.size()-1);

    retract( lastPath.gradient); //Retract filament to avoid filament drop on last layer

    //Facilitate object removal
    float end_Z;
    if (printer.height_printer - last_position.z > 10) {
      end_Z = last_position.z + 10;
    } else {
      end_Z = last_position.z + (printer.height_printer - last_position.z);
    }
    moveTo(new PVector(printer.x_center_table, printer.length_table - 10, end_Z), lastPath.gradient);

    recover(lastPath.gradient); //Restore filament position
    write("M 107"); //Turn fans off
  }

  void export() {
    println(" ");
    println("Exporting gcode");
    //Create a unique name for the exported file
    String name_save = "gcode_"+day()+""+hour()+""+minute()+"_"+second()+".g";
    //Convert from ArrayList to array (required by saveString function)
    String[] arr_gcode = gcode.toArray(new String[gcode.size()]);
    // Export GCODE
    saveStrings(name_save, arr_gcode);
    println(name_save + " saved");
    println("-----");
  }
}