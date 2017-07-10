class Settings {
  float path_width = 0.4; //mm
  float layer_height = 0.2; //mm
  float filament_diameter = 1.75; //mm

  float default_speed = 1500; //mm/minute
  float travel_speed = 3000; //mm/minute

  int start_fan_at_layer = 3;

  float extrusion_multiplier = 3;

  float retraction_amount = 4.5; //mm
  float retraction_speed = 5000; //mm/minute
  
  float getExtrudedPathSection(){
    return path_width * layer_height; //mm^2
  }
  
  float getFilamentSection(){
    return PI * sq(filament_diameter/2.0f); //mm^2
  }
}