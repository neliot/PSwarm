class Model4 extends PSystem {
  Model4() {
    super("Path Follower 0.1","4");
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
    PVectorD inter = new PVectorD(0,0,0);

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

      removeMetGoals(p);

      if (this._dest && p._destinations.size() > 0) {
        dir = direction(p);
        change.add(dir);
      }
      change.add(avoid);
      change.add(coh);
      change.add(rep);
      
      inter.add(coh);
      inter.add(rep);
      
      if (this._loggingP) {
        pData += plog._counter + "," + p.toString() + "," + coh.x + "," + coh.y + "," + coh.z + "," + coh.mag() + "," + rep.x + "," + rep.y + "," +  rep.z + "," + rep.mag() + "," + inter.x + "," + inter.y + "," +  inter.z + "," + inter.mag() + "," + avoid.x + "," + avoid.y + "," + avoid.z + "," + avoid.mag() + "," + dir.x + "," + dir.y + "," + dir.z + "," + dir.mag() + "," + change.x + "," + change.y + "," + change.z + "," + change.mag() + "\n";
      }
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
/** 
* cohesion calculation - Calculates the cohesion between each agent and its neigbours.
* 
* @param p The particle that is currently being checked
*/
    PVectorD result = new PVectorD(0,0,0);
    PVectorD temp = new PVectorD(0,0,0);
    double distance = 0;
//    p._nbr.clear();
    String nData = "";
    
// GET ALL THE NEIGHBOURS
    for(Particle n : p._nbr) {
      distance = pvectorDFactory.dist(p._loc,n._loc);
      if (this._perimCompress && p._isPerim && n._isPerim) {
        temp = pvectorDFactory.sub(n._loc,p._loc).mult(this._pc).mult(this._kc);
      } else {
        temp = pvectorDFactory.sub(n._loc,p._loc).mult(this._kc);
      }
      result.add(temp);
      if (this._loggingN && this._loggingP) {
        nData = plog._counter + "," + p._id + "," + n.toString() + "," + temp.x + "," + temp.y + "," + temp.z + "," + temp.mag() + "," + distance + "\n";
      }
    }
    if (this._loggingN && this._loggingP) {
      nClog.dump(nData);
      nClog.clean();
    }
    if (p._nbr.size() > 0) {
      result.div(p._nbr.size());
    }
    return result;
  }

  PVectorD repulsion(Particle p) {
/** 
* repulsion calculation - Calculates the repulsion between each agent and its neigbours.
* 
* @param p The particle that is currently being checked
*/
    PVectorD result = new PVectorD(0,0,0);
    PVectorD temp = new PVectorD(0,0,0);
    int count = 0;
    double dist = 0;
    double distance = 0;
    String nData = "";
    for(Particle n : p._nbr) {
      // IF compress permeter then reduce repulsion field if both agents are perimeter agents.
      if (this._perimCompress && p._isPerim && n._isPerim) { 
        dist = p._Rb * this._pr;
      } else {
        dist = p._Rb;
      }
      distance = pvectorDFactory.dist(p._loc,n._loc);
      if (distance <= dist & p != n) {
        temp = pvectorDFactory.sub(p._loc, n._loc).setMag(p._Rb- distance).mult(this._kr);
        result.add(temp);
        if (this._loggingN && this._loggingP) {
          nData = plog._counter + "," + p._id + "," + n.toString() + "," + temp.x + "," + temp.y + "," + temp.z + "," + temp.mag() + "," + distance + "\n";
        }
      }
    }
    if (this._loggingN && this._loggingP) {
      nRlog.dump(nData);
      nRlog.clean();
    }
    return result;
  }

  PVectorD direction(Particle p) {
/** 
* direction calculation - Calculates the normalised direction.
* 
* @param p The particle that is currently being checked
*/
    PVectorD destination = new PVectorD(0,0,0);
    PVectorD dir = new PVectorD(0,0,0);
    if (p._destinations.size() > 0) {
      destination = p._destinations.get(0)._loc;      
    }    
    if (!this._perimCoord) {
      dir = pvectorDFactory.sub(destination,p._loc);
    } else {
      /* Perimeter only control */
      if (p._isPerim) {
        dir = pvectorDFactory.sub(destination,p._loc);
      }
    }
    return dir.setMag(this._kd);
  }

  void removeMetGoals(Particle p) {
    if (p._destinations.size() > 0) {
      if (pvectorDFactory.dist(p._loc,p._destinations.get(0)._loc) <= p._Cb) {
        p._destinations.remove(0);
      }
    } 
  } 
}
