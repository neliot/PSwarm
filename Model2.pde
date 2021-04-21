class Model2 extends PSystem {
  Model2() {
    super("Random Walkers","2");    
  }

  void init() {};

    void populate() {
    boolean used = false;
    double nextX = 0;
    double nextY = 0;
    PRNG rand = new PRNG(_seed);
    for(int i = 0; i < this._swarmSize; i++) {
      try {
        used = true;
        while (used) {
          nextX = _grid/2 - (rand.nextFloat() * _grid);
          nextY = _grid/2 - (rand.nextFloat() * _grid);
          used = checkUsed(nextX,nextY);
          if (used) {
            println(nextX + ":" + nextY + "-used");
          }
        }
        // create agent in centred quartile.
        S.add(new Particle(this._nextParticleId++,nextX,nextY,0.0,this._Cb,this._Rb,this._speed));
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
    PVectorD change = new PVectorD(0,0,0);
    PVectorD avoid = new PVectorD(0,0,0);
    PVectorD dir = new PVectorD(0,0,0);
    PVectorD coh = new PVectorD(0,0,0);
    PVectorD rep = new PVectorD(0,0,0);

    for(Particle p : S) {      
      p.nbr(S);
      p.checkNbrs();
    }

    for(Particle p : S) {      
      avoid.set(0,0,0);
      dir.set(0,0,0);
      change.set(0,0,0); 

      /* Calculate Cohesion */
      coh = cohesion(p);

      /* Calculate Repulsion */
      rep = repulsion(p);

      /* Calculate Obstacle avoidance */
      if (this.O.size() > 0) {
        avoid = avoidObstacles(p);
      }

      if (this._dest && D.size() > 0) {
        dir = direction(p);
      }
      change.add(dir);
      change.add(avoid);
      change.add(coh);
      change.add(rep);
      
      p.setChange(change);
    }
    if (this._run) {
      _swarmDirection.set(0,0,0);
      for(Particle p : S) {
        _swarmDirection.add(p._resultant);
        p.update(this._particleOptimise);
      }
    }
    if (this._loggingP) {
      plog.dump(pData);
      plog.clean();
    }
  }

  PVectorD cohesion(Particle p) {
    return pvectorDFactory.random2D().mult(p._Cb);
  };

  PVectorD repulsion(Particle p) {
    return new PVectorD(0,0,0);
  };

  PVectorD direction(Particle p) {
/** 
* direction calculation - Calculates the normalised direction.
* 
* @param p The particle that is currently being checked
*/
    PVectorD destination = new PVectorD(0,0,0);
    PVectorD vd = new PVectorD(0,0,0);
    if (p._destinations.size() > 0) {
      destination = p._destinations.get(0)._loc;      
      for (int i = 1; i < p._destinations.size(); i++) {
        if (pvectorDFactory.dist(p._loc,destination) > pvectorDFactory.dist(p._loc,p._destinations.get(i)._loc)) {
          destination = p._destinations.get(i)._loc;
        }
      }   
    }    
    if (!this._perimCoord) {
      vd = pvectorDFactory.sub(destination,p._loc);
    } else {
      /* Perimeter only control */
      if (p._isPerim) {
        vd = pvectorDFactory.sub(destination,p._loc);
      }
    }
    return vd.setMag(this._kd);
  }
}
