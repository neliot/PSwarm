/************************************************
* Obstacle Class
*************************************************
* V 0.1
*************************************************
* Author: Neil Eliot
*************************************************
* Date: 16/02/2021
*************************************************
* Modified constructor to allow size and mass to 
* be added from JSON import
*************************************************
*/

class Obstacle {
  int _id;
  PVectorD _loc;
  double _size = 10.0;
  double _mass = 1.0;
  double _Ob = 50;
  
  Obstacle(int i, double x, double y, double z) {
/** 
* Creates a desination
* 
* @param i Agent Id
* @param x location
* @param y location
* @param z location
*/
    this._id = i;
    this._loc = new PVectorD(x,y,z);
  }
  
  Obstacle(int i, double x, double y, double z, double Ob) {
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
    this._Ob = Ob;
    this._loc = new PVectorD(x,y,z);
  }

  Obstacle(int i, double x, double y, double z, double Ob, double size, double mass) {
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
    this._Ob = Ob;
    this._loc = new PVectorD(x,y,z);
  }

  public JSONObject getJSONProps() {
    JSONObject o = new JSONObject();
    o.put("id", this._id);
    o.put("size",_size);
    o.put("mass",_mass);
    o.put("ob",_Ob);
    return o;
  }

  public void setPos(double x, double y, double z) {
    this._loc.set(x,y,z);
  }

  public String toString() {
/** 
* Creates a formatted string of destination.
*/
    return(this._id + "," + this._loc.x + "," + this._loc.y + "," + this._loc.z + "," + this._Ob +"," + this._size + "," + this._mass);
  }  
}
