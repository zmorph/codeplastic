class Builder {
  Printer printer = new Printer();
  Settings settings = new Settings();
  Processor processor = new Processor();

  Drawer drawer;
  GcodeGenerator gcodeGenerator;

  Vase vase;

  Builder() {
    addCreator();
    update();
  }

  void addCreator() {
    vase = new Vase(printer, settings, printer.x_center_table, printer.y_center_table);
  }

  void update() {
    vase.generate();

    processor = new Processor();

    processor.addObject(vase);

    processor.sortPaths();

    drawer = new Drawer(processor, printer);

    gcodeGenerator = new GcodeGenerator(printer, settings, processor);
  }

  void visualize() {
    drawer.displayPrinterChamber();
    drawer.displayPaths(color(0, 150));
  }

  void exportGcode() {
    gcodeGenerator = new GcodeGenerator(printer, settings, processor);
    gcodeGenerator.generate().export();
  }
}