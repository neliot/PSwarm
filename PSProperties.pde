class PSProperties {
  String[] _data1;
  StringList _data2 = new StringList();
  String _filename = "application.properties";

  PSProperties(){
    getData();  
  }

  PSProperties(String filename){
    _filename = filename;
    getData();
  }

  void getData() { 
    _data1 = loadStrings(_filename);
    for(String line : _data1) {
      _data2.append(line);  
    }
  }

  String getProperty(String name) {
    for(String line : _data2) {
      String lineProperty = splitTokens(line,"=")[0];
      if (name.toLowerCase().equals(lineProperty.toLowerCase())) {
        return splitTokens(line,"=#")[1].trim();
      }
    }
    return "NaN";
  }

  void setProperty(String property, String value, String comment) {
      for(int i = 0; i < _data2.size(); i++) {
        String line = _data2.get(i);
        String lineProperty = split(line,'=')[0];
        if (property.toLowerCase().equals(lineProperty.toLowerCase())) {
              _data2.set(i,property + "=" + value + " #" + comment);
              return;
        }
      }   
    _data2.append(property + "=" + value + " #" + comment);
  }

  void save() {
    saveStrings(_filename,_data2.array());
  }
}