class Destination {
//  int _nextId;
  int _id;
  PVector _location;
  float _size = 10.0;
  float _mass = 1.0;

  Destination(int i, float x, float y, float z) {
/** 
* Creates a desination
* 
* @param i Destination Id
* @param range cohesion range of agents
* @param repulse repulse repulsion range of agents
* @param x location
* @param y location
*/
    this._id = i;
    this._location = new PVector(x,y,z);
  }

  
  Destination(int i, float x, float y, float z, float size, float mass) {
/** 
* Creates a desination
* 
* @param i Agent Id
* @param range cohesion range of agents
* @param repulse repulse repulsion range of agents
* @param x location
* @param y location
*/
    this._id = i;
    this._size = size;
    this._mass = mass;
    this._location = new PVector(x,y,z);
  }

  String toString() {
/** 
* Creates a formatted string of destination.
*/
    return(this._id + "," + this._location.x + "," + this._location.y + "," + this._location.z + "," + this._size + "," + this._mass);
  }  
}
