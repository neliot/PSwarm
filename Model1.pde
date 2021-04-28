class Model1 extends PSystem {
  Model1() {
    super("Linear Vector + Void Reduction","1");
  }

  void init() {
    // if (this._compression == 1 && this._pkr > 1) {
    //   println("Outer compression must have pkr <= 1");
    //   exit();
    // }
    // if (this._compression == 2 && this._pkr < 1) {
    //   println("Inner compression must have pkr >= 1");
    //   exit();
    // }
  }

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
//          if (used) {
//            println(nextX + ":" + nextY + "-used");
//          }
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
    PVectorD perimGap = new PVectorD(0,0,0);
    PVectorD inter = new PVectorD(0,0,0);
    
    for(Particle p : S) {      
      p.nbr(S);
      p.checkNbrs();
    }
    
    for(Particle p : S) {      
      avoid.set(0,0,0);
      dir.set(0,0,0);
      change.set(0,0,0);
      perimGap.set(0,0,0); 
      coh.set(0,0,0);
      rep.set(0,0,0);

      /* Calculate Cohesion */
      coh = cohesion(p);

      /* Calculate Repulsion */
      rep = repulsion(p);
      
      /* Calculate Gap */
      if (this._perimCompress) {
        perimGap = gap2(p);
      }

      /* Calculate Obstacle avoidance */
      if (O.size() > 0) {
        avoid = avoidObstacles(p);
      }

      if (this._dest && D.size() > 0) {
        dir = direction(p);
      }
      change.add(dir);
      change.add(avoid);
      change.add(coh);
      change.add(rep);
      change.add(perimGap);
      
      inter = pvectorDFactory.add(coh,rep);
      
      if (_loggingP) {
        if (this._logMin) {
          pData += plog._counter + "," + p.logString(this._logMin) + "," + coh.x + "," + coh.y + "," + coh.mag() + "," + rep.x + "," + rep.y + "," + rep.mag() + "," + inter.x + "," + inter.y + "," + inter.mag() + "," + dir.x + "," + dir.y + "," + dir.mag() + "," + change.x + "," + change.y + "," + change.mag() + "\n";
        } else {
          pData += plog._counter + "," + p.logString(this._logMin) + "," + coh.x + "," + coh.y + "," + coh.z + "," + coh.mag() + "," + rep.x + "," + rep.y + "," +  rep.z + "," + rep.mag() + "," + inter.x + "," + inter.y + "," +  inter.z + "," + inter.mag() + "," + avoid.x + "," + avoid.y + "," + avoid.z + "," + avoid.mag() + "," + dir.x + "," + dir.y + "," + dir.z + "," + dir.mag() + "," + change.x + "," + change.y + "," + change.z + "," + change.mag() + "\n";
        }
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
    double distance = 0;
//    p._nbr.clear();
    String nData = "";
    
// GET ALL THE NEIGHBOURS
    for(Particle n : p._nbr) {
      v = pvectorDFactory.sub(n._loc,p._loc);
      if (this._perimCompress) {
        v.mult(this._pkc[p.isPerim()][n.isPerim()]);
      }
      v.mult(this._kc);
      vcb.add(v);
      if (this._loggingN && this._loggingP) {
        distance = pvectorDFactory.dist(p._loc,n._loc);
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

  PVectorD gap(Particle p){ // Aggregate the gaps
    PVectorD vgb = new PVectorD(0,0,0);
    PVectorD v = new PVectorD(0,0,0);
    for (int i =0; i < p._gapStart.size(); i++) {
        v = pvectorDFactory.add(p._gapStart.get(i)._loc,p._gapEnd.get(i)._loc).mult(0.5);
        v = pvectorDFactory.sub(v,p._loc);
        vgb.add(v);
    }
    if (p._gapStart.size() > 0) {
      vgb.div(p._gapStart.size());
    }
    vgb.mult(this._kg);
    return vgb;
  }

  PVectorD gap2(Particle p){ // Take the first gap found
    PVectorD vgb = new PVectorD(0,0,0);
    PVectorD v = new PVectorD(0,0,0);
    if (p._gapStart.size() > 0) {
        v = pvectorDFactory.add(p._gapStart.get(0)._loc,p._gapEnd.get(0)._loc).mult(0.5);
        v = pvectorDFactory.sub(v,p._loc);
        vgb.add(v);
    }
    vgb.mult(this._kg);
    return vgb;
  }

  PVectorD repulsion(Particle p) {
/** 
* repulsion calculation - Calculates the repulsion between each agent and its neigbours.
* 
* @param p The particle that is currently being checked
*/
    PVectorD vrb = new PVectorD(0,0);
    PVectorD v = new PVectorD(0,0);
    int count = 0;
    double dist = 0.0;
    double distance = 0.0;
    String nData = "";
    for(Particle n : p._nbr) {
      // IF compress permeter then reduce repulsion field if both agents are perimeter agents.
      dist = p._Rb;
      if (this._perimCompress) { 
        dist = dist * this._pr[p.isPerim()][n.isPerim()];
      }
      distance = pvectorDFactory.dist(p._loc,n._loc);                     // calculate neighbour distance
      if (distance <= dist & p != n) {                                    // If this agent has an effect in this relationship
        count++;                                                          // keep a record of the number of relationships
        v = pvectorDFactory.sub(p._loc, n._loc).setMag(dist - distance); // Calculate initial vector
//        if (this._compression == 0 || !this._perimCompress) {             // if compression is off (by setting or interactive)
        if (this._perimCompress) {             // if compression is off (by setting or interactive)
          v.mult(this._pkr[p.isPerim()][n.isPerim()]);
        // } else if ((p._isPerim ^ n._isPerim) && (this._compression == 1)) { // Outer compression apply kr and pkr to i & p
        //   v.mult(this._kr);
        //   v.mult(this._pkr);
        // } else if ((!p._isPerim && n._isPerim) && (this._compression == 2)) { // Inner compression apply kr and pkr to i only
        //   v.mult(this._kr);
        }
        v.mult(this._kr);                      // Must be inner to inner relationship
        vrb.add(v);                              // Sum the neighbours
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
      vrb.div(count);                                           // Average the magnitude
    }
    return vrb;
  }

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
