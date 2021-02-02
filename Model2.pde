class Model2 extends PSystem {
  Model2() {
    super("Random Walkers","2");    
  }

  void init() {};

  void populate() {
    for(int i = 0; i < this._swarmSize; i++) {
      try {
        // create agent in centred quartile.
        S.add(new Particle(this._nextParticleId++,random((width * 0.2),(width * 0.8)),random((height * 0.2),(height * 0.8)),0,this._Cb,this._Rb));
      } catch (Exception e) {
        println(e);
        exit();
      }
    }
  }

  void update() {
/** 
* Update system - Updates particle positions based on forces and displays the result.
*/
    String pData = "";
    PVector move = new PVector(0,0,0);
    for(Particle p : S) {      
      move = PVector.random2D();
      move.setMag(p._topspeed);
      p.setChange(move);
    }
    if (this._run) {
      _swarmDirection.set(0,0,0);
      for(Particle p : S) {
        _swarmDirection.add(p._resultant);
        p.update();
      }
    }
  }

  PVector cohesion(Particle p) {
    return new PVector(0,0,0);
  };
  PVector repulsion(Particle p) {
    return new PVector(0,0,0);
  };

  PVector direction(Particle p) {
/** 
* direction calculation - Calculates the normalised direction.
* 
* @param p The particle that is currently being checked
*/
    PVector destination = new PVector(0,0,0);
    PVector dir = new PVector(0,0,0);
    if (p._destinations.size() > 0) {
      destination = p._destinations.get(0)._loc;      
      for (int i = 1; i < p._destinations.size(); i++) {
        if (PVector.dist(p._loc,destination) > PVector.dist(p._loc,p._destinations.get(i)._loc)) {
          destination = p._destinations.get(i)._loc;
        }
      }   
    }    
    if (!this._perimCoord) {
      dir = PVector.sub(destination,p._loc);
    } else {
      /* Perimeter only control */
      if (p._isPerim) {
        dir = PVector.sub(destination,p._loc);
      }
    }
    return dir.setMag(_kd);
  }
}
