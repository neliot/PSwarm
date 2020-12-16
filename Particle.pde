class Particle {
  PVector _location;
  PVector _nextLocation;
  PVector _resultant;
  ArrayList<Particle> _neighbours = new ArrayList<Particle>(); 
  ArrayList<Destination> _destinations = new ArrayList<Destination>(); ;
//  ArrayList<PImage> mice2 = new ArrayList<PImage>();
//  PVector _acceleration;
  int _id;
  float _size = 10.0;
  float _mass = 1.0;
  float _range;
  float _repulse;
  float _topspeed = 3.0/_mass; 
  float _sweepAngle;
  boolean _isPerimeter = true;

  Particle(int i, float x, float y, float z, float range, float repulse, float size, float mass) throws Exception {
/** 
* Creates a particle
* 
* @param i Agent Id
* @param range cohesion range of agents
* @param repulse repulse repulsion range of agents
* @param x location
* @param y location
*/
    _id = i;
    _range = range;
    _repulse = repulse;
    _size = size;
    _mass = mass;
    if (_repulse >= range) {
      throw new Exception("Range must be greater than Repulsion");
    }
    _location = new PVector(x,y,z);
    _nextLocation = new PVector(x,y,z);
    _resultant = new PVector(0,0,0);
  }

  Particle(int i, float x, float y, float z, float range, float repulse) throws Exception {
/** 
* Creates a particle
* 
* @param i Agent Id
* @param range cohesion range of agents
* @param repulse repulse repulsion range of agents
* @param x location
* @param y location
*/
    this._id = i;
    this._range = range;
    this._repulse = repulse;
    if (this._repulse > range) {
      throw new Exception("Range must be greater than Repulsion");
    }
    this._location = new PVector(x,y,z);
    this._nextLocation = new PVector(x,y,z);
    this._resultant = new PVector(0,0,0);
  }

  void setDestinations(ArrayList<Destination> destinations) {
    _destinations = (ArrayList<Destination>) destinations.clone();
  }

  void addDestination(Destination destination) {
    _destinations.add(destination);
  }

  void removeDestination(Destination destination) {
    for (int i = this._destinations.size() - 1; i >= 0; i--) {
//      Destination d = this._destinations.get(i);
      if (this._destinations.get(i) == destination) {
        this._destinations.remove(i);
      }
    }
  }

  String toString() {
/** 
* Creates a formatted string of particle data.
*/
    return(this._id + "," + this._location.x + "," + this._location.y + ","+ this._location.z + "," + this._range + "," + this._repulse + "," + this._size + "," + this._mass + "," + this._isPerimeter);
  }
  
  void setChange(PVector change) {
/** 
* Adds a vector to the particle.
* 
* @param force PVector
*/
    // mass set to 1. This is for future work.
    PVector f = PVector.div(change,this._mass);
    this._resultant.set(f);
  }

  void update() {
/** 
* Updates the position of the particle based on the _acceleration.
* 
*/
//    _change.add(_acceleration);
    PVector next = this._location.copy().add(_resultant);
    if (PVector.dist(this._location,next) > this._topspeed) {
      this._resultant.limit(_topspeed);    
    }
    // helping the garbage collector again;
    this._nextLocation.x = _location.x;
    this._nextLocation.y = _location.y;
    this._nextLocation.add(_resultant);
  }

  void move() {
/** 
* Updates the position of the particle based on the _acceleration.
* 
*/
    // Copy values rather than object! Lets help the garbage collector out!
    this._location.x = _nextLocation.x;
    this._location.y = _nextLocation.y;
    this._location.z = _nextLocation.z;
  }

  void reset() {
/** 
* Updates the particle for next iteration.
* 
*/
//    _acceleration.mult(0);
    _resultant.mult(0);
  }

  void getNeighbours(ArrayList<Particle> s){
    this._neighbours.clear();
    for(Particle n : s) {
      float distance = PVector.dist(this._location,n._location); 
      if ( distance <= this._range & this != n) {
        this._neighbours.add(n);
      }
    }
    checkNeighbours();
  }

  float calcAngle(float start, float end) {
    if (start < end) {
      start += 360;
    }
    return abs(start - end);
  }

  void checkNeighbours() {
/** 
* Examines the particles neighbours to determine if the agent is on an edge.
* 
* @param neighbours is an ArrayList of all particles in the cohesion field of the particle.
*/
// TEST FOR SMALL CONNECTIONS THAT MUST BE PERIMETER AGENTS    
//    PVector p1, p2;
    float angle;
    float dist;
    this._isPerimeter = false;
    if (this._neighbours.size() < 4) {
      this._isPerimeter = true;
      return;
    }
//CALCULATE SWEEP ANGLE
    for (Particle n : _neighbours) {
      PVector head = PVector.sub(n._location,this._location);
      n._sweepAngle = degrees(atan2(head.y,head.x))+180;
    }    
  
//BUBBLE SORT ARRAYLIST ON sweepAngle
    for (int i = 0; i < this._neighbours.size(); i++) {
      for (int j = 0; j < this._neighbours.size()-i-1; j++) {
        Particle start = this._neighbours.get(j);        
        Particle next = this._neighbours.get(j+1);
        if (start._sweepAngle < next._sweepAngle) {
            Particle temp = this._neighbours.get(j);
            this._neighbours.set(j,this._neighbours.get(j+1)); 
            this._neighbours.set(j+1,temp);
        }
      }
    }    
//SWEEP THE ANGLES 
    if (_neighbours.size() > 0) {
      for (int i = 0; i < this._neighbours.size()-1; i++) {
        angle = calcAngle(this._neighbours.get(i)._sweepAngle, this._neighbours.get(i+1)._sweepAngle);
        dist = PVector.dist(this._neighbours.get(i)._location, this._neighbours.get(i+1)._location);
        if ( dist > this._range || angle > 180) {
          this._isPerimeter = true;
        }
      }
      angle = calcAngle(this._neighbours.get(this._neighbours.size()-1)._sweepAngle,this._neighbours.get(0)._sweepAngle);
      dist = PVector.dist(this._neighbours.get(0)._location,this._neighbours.get(this._neighbours.size()-1)._location); 
      if (dist > _range  || angle > 180) {
        this._isPerimeter = true;
      }
    }
  }  
}
