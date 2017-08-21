enum PrintType {
  SINGLE_COLOR_EXTRUDER_1, 
    SINGLE_COLOR_EXTRUDER_2, 
    DUAL_COLOR, 
    MULTI_COLOR,
}

class GcodeGenerator {

  ArrayList<String> gcode;
  Printer printer;
  Settings settings;
  Processor processor;

  float E = 0; // Left extruder

  GcodeGenerator(Printer t_printer, Settings t_settings, Processor t_processor) {
    printer = t_printer;
    settings = t_settings;
    processor = t_processor;
  }

  GcodeGenerator generate() {
    gcode = new ArrayList<String>();

    printPrintType(getPrintType());

    float extrusion_multiplier = 1;

    startPrint();

    for (Path path : processor.paths) {

      moveTo(path.vertices.get(0));

      if (getLayerNumber(path.vertices.get(0)) < settings.start_fan_at_layer) {
        setSpeed(settings.default_speed/2);
      } else if (getLayerNumber(path.vertices.get(0)) == settings.start_fan_at_layer) {
        setSpeed(settings.default_speed);
        enableFan();
      } else {
        setSpeed(settings.default_speed);
      }

      extrusion_multiplier = getLayerNumber(path.vertices.get(0)) == 1 ? settings.extrusion_multiplier : 1;

      for (int i=0; i<path.vertices.size()-1; i++) {
        PVector p1 = path.vertices.get(i);
        PVector p2 = path.vertices.get(i+1);
        extrudeTo(p1, p2, extrusion_multiplier);
      }
    }

    endPrint();

    return this;
  }

  void printPrintType(PrintType type) {
    switch(type) {
    case SINGLE_COLOR_EXTRUDER_1:
      println("SINGLE_COLOR_EXTRUDER_1");
      break;
    case SINGLE_COLOR_EXTRUDER_2: 
      println("SINGLE_COLOR_EXTRUDER_2");
      break;
    case DUAL_COLOR:
      println("DUAL_COLOR");
      break;
    case MULTI_COLOR:
      println("MULTI_COLOR");
      break;
    }
  }

  PrintType getPrintType() {
    PrintType print_type =  PrintType.SINGLE_COLOR_EXTRUDER_1;

    float first_gradient = processor.paths.get(0).gradient;

    if (abs(first_gradient-1)<EPSILON)
      print_type = PrintType.SINGLE_COLOR_EXTRUDER_1;
    else if (abs(first_gradient-0)<EPSILON)
      print_type = PrintType.SINGLE_COLOR_EXTRUDER_2;
    else 
    print_type = PrintType.MULTI_COLOR;

    println(EPSILON);
    printPrintType(print_type);

    for (Path path : processor.paths) {
      if (abs(path.gradient-first_gradient)<EPSILON)
        continue;
      else if (abs(path.gradient-first_gradient-1)<EPSILON)
        print_type = PrintType.DUAL_COLOR;
      else
        print_type = PrintType.MULTI_COLOR;
    }

    return print_type;
  }

  int getLayerNumber(PVector p) {
    return (int)(p.z/settings.layer_height);
  }

  void write(String command) {
    gcode.add(command);
  }

  void moveTo(PVector p) {
    retract();
    write("G1 " + "X" + p.x + " Y" + p.y + " Z" + p.z + " F" + settings.travel_speed);
    recover();
  }

  float extrude(PVector p1, PVector p2) {
    float points_distance = dist(p1.x, p1.y, p2.x, p2.y);
    float volume_extruded_path = settings.getExtrudedPathSection() * points_distance;
    float length_extruded_path = volume_extruded_path / settings.getFilamentSection();
    return length_extruded_path;
  }

  void extrudeTo(PVector p1, PVector p2, float extrusion_multiplier) {
    E+=(extrude(p1, p2) * extrusion_multiplier);
    write("G1 " + "X" + p2.x + " Y" + p2.y + " Z" + p2.z + " E" + E);
  }

  void extrudeTo(PVector p1, PVector p2, float extrusion_multiplier, float f) {
    E+=(extrude(p1, p2) * extrusion_multiplier);
    write("G1 " + "X" + p2.x + " Y" + p2.y + " Z" + p2.z + " E" + E + " F" + f);
  }

  void retract() {
    E-=settings.retraction_amount;
    write("G1" + " E" + E + " F" + settings.retraction_speed);
  }

  void recover() {
    E+=settings.retraction_amount;
    write("G1" + " E" + E + " F" + settings.retraction_speed);
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
    PVector last_position = processor.paths.get(processor.paths.size()-1).vertices.get(processor.paths.get(processor.paths.size()-1).vertices.size()-1);

    retract(); //Retract filament to avoid filament drop on last layer

    //Facilitate object removal
    float end_Z;
    if (printer.height_printer - last_position.z > 10) {
      end_Z = last_position.z + 10;
    } else {
      end_Z = last_position.z + (printer.height_printer - last_position.z);
    }
    moveTo(new PVector(printer.x_center_table, printer.length_table - 10, end_Z));

    recover(); //Restore filament position
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