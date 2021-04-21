class Model9 extends PSystem {
  
  Model9() {
    super("Linear Vector - Adversarial","9");
  }

  void init() {
  };

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

      if (this._dest && D.size() > 0) {
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
    PVectorD vcb = new PVectorD(0,0,0);
    PVectorD v = new PVectorD(0,0,0);
    double distance = 0.0;
    String nData = "";
    
// GET ALL THE NEIGHBOURS
    for(Particle n : p._nbr) {
      distance = pvectorDFactory.dist(p._loc,n._loc);
      if (this._perimCompress && p._isPerim && n._isPerim) {
        v = pvectorDFactory.sub(n._loc,p._loc).mult(this._pc).mult(this._kc);
      } else {
        v = pvectorDFactory.sub(n._loc,p._loc).mult(this._kc);
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

  PVectorD repulsion(Particle p) {
/** 
* repulsion calculation - Calculates the repulsion between each agent and its neigbours.
* 
* @param p The particle that is currently being checked
*/
    PVectorD vrb = new PVectorD(0,0,0);
    PVectorD v = new PVectorD(0,0,0);
    int count = 0;
    double dist = 0.0;
    double distance = 0.0;
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
        count++;
        v = pvectorDFactory.sub(p._loc, n._loc).setMag(dist - distance).mult(this._kr);
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

  PVectorD direction(Particle p) {
/** 
* direction calculation - Calculates the normalised direction.
* 
* @param p The particle that is currently being checked
*/
    double rotation = Math.PI/2;
    boolean clockwise = false;
    PVectorD destination = new PVectorD(0,0,0);
    PVectorD vd = new PVectorD(0,0,0);
    PVectorD vad = new PVectorD(0,0,0);
    int id = 0;
    if (p._destinations.size() > 0) {
      destination = p._destinations.get(0)._loc;      
      for (int i = 1; i < p._destinations.size(); i++) {
        if (pvectorDFactory.dist(p._loc,destination) > pvectorDFactory.dist(p._loc,p._destinations.get(i)._loc)) {
          destination = p._destinations.get(i)._loc;
          id = p._destinations.get(i)._id;
        }
      }   
    }    

    if (boolean(modelProperties.getProperty("clockwise"))) {
      rotation = -Math.PI/2;
    } else {
      rotation = Math.PI/2;
    }

    vd = pvectorDFactory.sub(destination,p._loc);
    if (!this._perimCoord) {
      if (id % 2 == 0 && boolean(modelProperties.getProperty("alternateDirection"))) {
        vad = vd.copy().rotate(-rotation).mult(2);
      } else {
        vad = vd.copy().rotate(rotation).mult(2);
      }
    } else {
      /* Perimeter only control */
      if (p._isPerim) {
        if (id % 2 == 0 && boolean(modelProperties.getProperty("alternateDirection"))) {
          vad = vd.copy().rotate(-rotation).mult(2);
        } else {
          vad = vd.copy().rotate(rotation).mult(2);
        }
      }
    }
    vd.add(vad);
    return vd.setMag(this._kd);
  }
}
