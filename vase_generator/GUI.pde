void setGui() {
  cp5.setAutoDraw(false);

  float start_X = 10;
  float inc_X = 10;
  float start_Y = 10;
  float inc_Y = 10;

  cp5.addSlider("sides").setPosition(start_X, start_Y+=2*inc_Y).setRange(3, 100).setNumberOfTickMarks(98).setCaptionLabel("sides number").setColorCaptionLabel(100).setValue(4);

  cp5.addSlider("width_vase").setPosition(start_X, start_Y+=2*inc_Y).setRange(0, builder.printer.width_table/2).setCaptionLabel("Width X (mm)").setColorCaptionLabel(100).setValue(10);
  cp5.addSlider("length_vase").setPosition(start_X, start_Y+=inc_Y).setRange(0, builder.printer.length_table/2).setCaptionLabel("Length X (mm)").setColorCaptionLabel(100).setValue(10);
  cp5.addSlider("height_vase").setPosition(start_X, start_Y+=inc_Y).setRange(0, builder.printer.height_printer).setCaptionLabel("Height X (mm)").setColorCaptionLabel(100).setValue(10);

  cp5.addSlider("rotation").setPosition(start_X, start_Y+=2*inc_Y).setRange(0, QUARTER_PI/15).setCaptionLabel("Rotation (rad)").setColorCaptionLabel(100).setValue(0);

  cp5.addSlider("amount_oscillation_XY").setPosition(start_X, start_Y+=2*inc_Y).setRange(0, 50).setCaptionLabel("amount oscillation XY (mm)").setColorCaptionLabel(100).setValue(0);
  cp5.addSlider("increment_oscillation_XY").setPosition(start_X, start_Y+=inc_Y).setRange(0, PI).setCaptionLabel("increment oscillation XY (rad)").setColorCaptionLabel(100).setValue(0);

  cp5.addSlider("amount_oscillation_Z").setPosition(start_X, start_Y+=2*inc_Y).setRange(0, 50).setCaptionLabel("amount oscillation Z (mm)").setColorCaptionLabel(100).setValue(0);
  cp5.addSlider("increment_oscillation_Z").setPosition(start_X, start_Y+=inc_Y).setRange(0, QUARTER_PI/15).setCaptionLabel("increment oscillation Z (rad)").setColorCaptionLabel(100).setValue(0);

  cp5.addSlider("top_gradient").setPosition(start_X, start_Y+=2*inc_Y).setRange(0, 1).setCaptionLabel("Top gradient").setColorCaptionLabel(100).setValue(1);
  cp5.addSlider("bottom_gradient").setPosition(start_X, start_Y+=inc_Y).setRange(0, 1).setCaptionLabel("Bottom gradient").setColorCaptionLabel(100).setValue(1);

  cp5.addButton("Export GCODE").setPosition(10, height-50).setHeight(40).setWidth(int(0.2*width)-10).setColorLabel(10).setColorBackground(color(0, 200, 0));
}

void controlEvent(ControlEvent theEvent) {
  if (theEvent.isController()) { 
    if (theEvent.getController().getName()=="sides") {
      builder.vase.setSides((int)cp5.getController("sides").getValue());
      builder.update();
    } else if (theEvent.getController().getName()=="width_vase") {
      builder.vase.setWidth(cp5.getController("width_vase").getValue());
      builder.update();
    } else if (theEvent.getController().getName()=="length_vase") {
      builder.vase.setLength(cp5.getController("length_vase").getValue());
      builder.update();
    } else if (theEvent.getController().getName()=="height_vase") {
      builder.vase.setHeight(cp5.getController("height_vase").getValue());
      builder.update();
    } else if (theEvent.getController().getName()=="rotation") {
      builder.vase.setRotation(cp5.getController("rotation").getValue());
      builder.update();
    } else if (theEvent.getController().getName()=="amount_oscillation_XY") {
      builder.vase.setOscillationXYAmount(cp5.getController("amount_oscillation_XY").getValue());
      builder.update();
    } else if (theEvent.getController().getName()=="increment_oscillation_XY") {
      builder.vase.setOscillationXY(cp5.getController("increment_oscillation_XY").getValue());
      builder.update();
    } else if (theEvent.getController().getName()=="amount_oscillation_Z") {
      builder.vase.setOscillationZAmount(cp5.getController("amount_oscillation_Z").getValue());
      builder.update();
    } else if (theEvent.getController().getName()=="increment_oscillation_Z") {
      builder.vase.setOscillationZ(cp5.getController("increment_oscillation_Z").getValue());
      builder.update();
    } else if (theEvent.getController().getName()=="bottom_gradient") {
      builder.vase.setBottomGradient(cp5.getController("bottom_gradient").getValue());
      builder.update();
    } else if (theEvent.getController().getName()=="top_gradient") {
      builder.vase.setTopGradient(cp5.getController("top_gradient").getValue());
      builder.update();
    } else if (theEvent.getController().getName()=="Export GCODE") {
      builder.exportGcode();
    }
  }
}

// ENABLE CONTOLP5 WITH PEASYCAM
void gui() {
  hint(DISABLE_DEPTH_TEST);
  cam.beginHUD();
  if (cp5.isMouseOver()) {
    cam.setActive(false);
  } else {
    cam.setActive(true);
  }
  cp5.draw();
  cam.endHUD();
  hint(ENABLE_DEPTH_TEST);
}