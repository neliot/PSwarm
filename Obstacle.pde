class Obstacle {
  int _id;
  PVector _location;
  float _size = 10.0f;
  float _mass = 1.0f;
  float _range = 50f;
  
  Obstacle(int i, float x, float y, float z) {
/** 
* Creates a desination
* 
* @param i Agent Id
* @param x location
* @param y location
* @param z location
*/
    this._id = i;
    this._location = new PVector(x,y,z);
  }
  
  Obstacle(int i, float x, float y, float z, float range) {
/** 
* Creates a desination
* 
* @param i Agent Id
* @param x location
* @param y location
* @param z location
* @param range repulsion range of Obstacle
*/
    this._id = i;
    this._range = range;
    this._location = new PVector(x,y,z);
  }

  Obstacle(int i, float x, float y, float z, float range, float size, float mass) {
/** 
* Creates a desination
* 
* @param i Agent Id
* @param x location
* @param y location
* @param z location
* @param range repulsion range
* @param size diameter
* @param mass mass of obstacle (possible attractor?)
*/
    this._id = i;
    this._size = size;
    this._mass = mass;
    this._range = range;
    this._location = new PVector(x,y,z);
  }

  String toString() {
/** 
* Creates a formatted string of destination.
*/
    return(this._id + "," + this._location.x + "," + this._location.y + "," + this._location.z + "," + this._range +"," + this._size + "," + this._mass);
  }  
}
