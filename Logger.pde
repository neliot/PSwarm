/************************************************
* Logger Class
*************************************************
* See history.txt
*/
// JAVA-IMPLEMENTATION
//  import java.io.PrintWriter; 
//  import java.io.File;

class Logger {
  PrintWriter _output;
  String _filename = "";
  String _store = "";
  int _counter = 1;
  
  Logger(String filename) {
/** 
* Sets up logger
* 
* @param filename name of the data dump file
*/ 
    this._counter = 1;
    this._filename = filename;
    try {
// JAVA-BASED Processing Mangles
//   _output = new PrintWriter(new File(_filename));
      this._output = createWriter(_filename);
    } catch (Exception e) {
      e.printStackTrace();
      exit();      
    }
  }

  Logger() {
/** 
* Sets up logger
* 
* @param filename name of the data dump file
*/ 
    this._counter = 1;
  }

  public void dump(String data) {
    if (this._filename.equals("")) {
      this._store += data;
    } else {
      this._output.print(data);
    }
  }
  
  public void clean() {
    this._output.flush();
    this._counter++;
  };
  
  public void quit() {
    this._output.flush();
    this._output.close();
  }
}
