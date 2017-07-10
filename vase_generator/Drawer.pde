class Drawer {
  Processor processor;
  Printer printer;

  Drawer(Processor t_processor, Printer t_printer) {
    processor = t_processor;
    printer = t_printer;
  }

  void displayAll(color c) {
    displayPrinterChamber();
    displayPaths(c);
  }

  void displayPaths() { 
    for (Path path : processor.paths) {
      for (int i=0; i< path.vertices.size()-1; i++) {
        PVector p1 = path.vertices.get(i);
        PVector p2 = path.vertices.get(i + 1);
        line(p1.x, p1.y, p1.z, p2.x, p2.y, p2.z);
      }
    }
  }

  void displayPaths(color c) {
    stroke(c);
    displayPaths();
  }

  // SHOW PRINTING CHAMBER
  void displayPrinterChamber() { 
    pushMatrix();
    translate(printer.x_center_table, printer.y_center_table, 0);
    fill(200);
    stroke(0);
    rectMode(CENTER);
    rect(0, 0, printer.width_table, printer.length_table);
    rectMode(CORNER);
    translate(0, 0, printer.height_printer/2);
    noFill();
    box(printer.width_table, printer.length_table, printer.height_printer);
    popMatrix();
  }
}