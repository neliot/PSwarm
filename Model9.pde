class Model9 extends PSystem {
  Model9() {
    super("Linear Vector - Adversarial","9");
  }

  void init() {};

  void populate() {
    PRNG rand = new PRNG(_seed);
    for(int i = 0; i < this._swarmSize; i++) {
      try {
        // create agent in centred quartile.
        S.add(new Particle(this._nextParticleId++,rand.nextInt(width),rand.nextInt(height),0,this._Cb,this._Rb));
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

      if (this._dest && destinations.size() > 0) {
        dir = direction(p);
      }
      change.add(dir);
      change.add(avoid);
      change.add(coh);
      change.add(rep);
      
      inter.add(coh);
      inter.add(rep);
      
      if (_loggingP) {
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
    PVector vcb = new PVector(0,0,0);
    PVector v = new PVector(0,0,0);
    float distance = 0f;
    String nData = "";
    
// GET ALL THE NEIGHBOURS
    for(Particle n : p._nbr) {
      distance = PVector.dist(p._loc,n._loc);
      if (this._perimCompress && p._isPerim && n._isPerim) {
        v = PVector.sub(n._loc,p._loc).mult(this._pc).mult(this._kc);
      } else {
        v = PVector.sub(n._loc,p._loc).mult(this._kc);
      }
      vcb.add(v);
      if (this._loggingN && this._loggingP) {
        nData = plog._counter + "," + p._id + "," + n.toString() + "," + v.x + "," + v.y + "," + v.z + "," + v.mag() + "," + distance + "\n";
      }
    }
    if (this._loggingN && this._loggingP) {
      nClog.dump(nData);
      nClog.clean();
    }
    if (p._nbr.size() > 0) {
      vcb.div(p._nbr.size());
    }
    return vcb;
  }

  PVector repulsion(Particle p) {
/** 
* repulsion calculation - Calculates the repulsion between each agent and its neigbours.
* 
* @param p The particle that is currently being checked
*/
    PVector vrb = new PVector(0,0,0);
    PVector v = new PVector(0,0,0);
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
        count++;
        v = PVector.sub(p._loc, n._loc).setMag(dist - distance).mult(this._kr);
        vrb.add(v);
        if (this._loggingN && this._loggingP) {
          nData = plog._counter + "," + p._id + "," + n.toString() + "," + v.x + "," + v.y + "," + v.z + "," + v.mag() + "," + distance + "\n";
        }
      }
    }
    if (this._loggingN && this._loggingP) {
      nRlog.dump(nData);
      nRlog.clean();
    }
    if (count > 0) {
      vrb.div(count);
    }
    return vrb;
  }

  PVector direction(Particle p) {
/** 
* direction calculation - Calculates the normalised direction.
* 
* @param p The particle that is currently being checked
*/
    PVector destination = new PVector(0,0,0);
    PVector vd = new PVector(0,0,0);
    PVector vad = new PVector(0,0,0);
    int id = 0;
    if (p._destinations.size() > 0) {
      destination = p._destinations.get(0)._loc;      
      for (int i = 1; i < p._destinations.size(); i++) {
        if (PVector.dist(p._loc,destination) > PVector.dist(p._loc,p._destinations.get(i)._loc)) {
          destination = p._destinations.get(i)._loc;
          id = p._destinations.get(i)._id;
        }
      }   
    }    
    if (!this._perimCoord) {
      vd = PVector.sub(destination,p._loc);
      if (id % 2 == 0) {
        vad = vd.copy().rotate(-HALF_PI).mult(2);
      } else {
        vad = vd.copy().rotate(HALF_PI).mult(2);
      }
    } else {
      /* Perimeter only control */
      if (p._isPerim) {
        vd = PVector.sub(destination,p._loc);
        if (id % 2 == 0) {
          vad = vd.copy().rotate(-HALF_PI).mult(2);
        } else {
          vad = vd.copy().rotate(HALF_PI).mult(2);
        }
      }
    }
    vd.add(vad);
    return vd.setMag(this._kd);
  }
}