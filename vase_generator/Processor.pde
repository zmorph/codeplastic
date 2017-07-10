class Processor {

  ArrayList<Creator> objects = new ArrayList<Creator>();
  ArrayList<Path> paths;

  Processor addObject(Creator object) {
    objects.add(object);
    return this;
  }

  void sortPaths() {
    paths = new ArrayList<Path>();

    //Put all the outlines of the objects in one ArrayList
    for (Creator obj : objects) {
      for (Path path : obj.paths) {
        paths.add(path);
      }
    }

    //Sort them from bottom to top layer

    Collections.sort(paths, new Comparator<Path>() {
      public int compare(Path o1, Path o2) {      
        return Float.compare(o1.getCenter().z, o2.getCenter().z);
      }
    }
    );
  }
}