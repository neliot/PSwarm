class Destination {
  int _id;
  PVector _loc;
  float _size = 10.0f;
  float _mass = 1.0f;

  Destination(int i, float x, float y, float z) {
/** 
* Creates a destination
* 
* @param i Destination Id
* @param x location
* @param y location
* @param z location
*/
    this._id = i;
    this._loc = new PVector(x,y,z);
  }
  
  Destination(int i, float x, float y, float z, float size, float mass) {
/** 
* Creates a desination
* 
* @param i Agent Id
* @param x location
* @param y location
* @param z location
* @param size diameter
* @param mass mass of destination (Future work maybe?)
*/
    this._id = i;
    this._size = size;
    this._mass = mass;
    this._loc = new PVector(x,y,z);
  }

  public void setPos(float x, float y, float z) {
    this._loc.set(x,y,z);
  }

  public JSONObject getJSONProps() {
    JSONObject o = new JSONObject();
    o.put("id", this._id);
    o.put("size",_size);
    o.put("mass",_mass);
    return o;
  }

  public String toString() {
/** 
* Creates a formatted string of destination.
*/
    return(this._id + "," + this._loc.x + "," + this._loc.y + "," + this._loc.z + "," + this._size + "," + this._mass);
  }  
}
