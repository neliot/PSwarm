class Model7 extends PSystem {
  Model7() {
    super("Void Reduction 0.1","7");
  }

  void init() {};

  void populate() {
    PRNG rand = new PRNG(_seed);
    for(int i = 0; i < this._swarmSize; i++) {
      try {
        // create agent in centred quartile.
        Particle p = new Particle(this._nextParticleId++,random((width * 0.01),(width * 1.0)),random((height * 0.01),(height * 1.0)),0,this._Cb,this._Rb);
        S.add(p);
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
    PVector change = new PVector(0,0,0);
    PVector avoid = new PVector(0,0,0);
    PVector dir = new PVector(0,0,0);
    PVector coh = new PVector(0,0,0);
    PVector rep = new PVector(0,0,0);
    PVector inter = new PVector(0,0,0);
    for(Particle p : S) {      
      avoid.set(0,0,0);
      dir.set(0,0,0);
      change.set(0,0,0); 

      p.nbr(S);

      /* Calculate Cohesion */
      coh = cohesion(p);

      /* Calculate Repulsion */
      rep = repulsion(p);

      /* Calculate Obstacle avoidance */
      if (obstacles.size() > 0) {
        avoid = avoidObstacles(p);
      }

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
        p.update();
      }
    }
    if (this._loggingP) {
      plog.dump(pData);
      plog.clean();
    }
  }
    
  PVector cohesion(Particle p) {
/** 
* cohesion calculation - Calculates the cohesion between each agent and its neigbours.
* 
* @param p The particle that is currently being checked
*/
    PVector result = new PVector(0,0,0);
    PVector temp = new PVector(0,0,0);
    float distance = 0f;
    String nData = "";
    
// GET ALL THE NEIGHBOURS
    for(Particle n : p._nbr) {
      distance = PVector.dist(p._loc,n._loc);
      if (p._isPerim && p.hasGap() && this._perimCompress) {
        temp = PVector.add(p._gap.get(0)._loc,p._gap.get(1)._loc).mult(0.5);
        temp = PVector.sub(temp,p._loc).mult(this._kc);
      } else {
        temp = PVector.sub(n._loc,p._loc).mult(this._kc);
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

  PVector repulsion(Particle p) {
/** 
* repulsion calculation - Calculates the repulsion between each agent and its neigbours.
* 
* @param p The particle that is currently being checked
*/
    PVector result = new PVector(0,0,0);
    PVector temp = new PVector(0,0,0);
    int count = 0;
    float dist = 0f;
    float distance = 0f;
    String nData = "";
    for(Particle n : p._nbr) {
      // IF compress permeter then reduce repulsion field if both agents are perimeter agents.
      if (this._perimCompress && p._isPerim && n._isPerim) { 
        dist = p._Rb * this._pr;
      } else {
        dist = p._Rb;
      }
      distance = PVector.dist(p._loc,n._loc);
      if (distance <= dist & p != n) {
        temp = PVector.sub(p._loc, n._loc).setMag(p._Rb- distance).mult(this._kr);
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
    return dir.setMag(this._kd);
  } 
}
