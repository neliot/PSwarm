class Logger {
  PrintWriter _output;
  String _filename;
  int _counter = 0;
  
  Logger(String filename) {
/** 
* Sets up logger
* 
* @param filename name of the data dump file
*/ 
    _counter = 0;
    _filename = filename;
    try {
    _output = createWriter(_filename);
    } catch (Exception e) {
      e.printStackTrace();
      exit();      
    }
  }
  
  void dump(String data) {
    _output.print(data);
  }
  
  void clean() {
    _output.flush();
    _counter++;
  };
  
  void quit() {
    _output.flush();
    _output.close();
  }
}
