class Model1 extends PSystem {
  Model1() {
    super("Linear Vector","1");
  }

  void init() {};

  void populate() {
    for(int i = 0; i < this._swarmSize; i++) {
      try {
        // create agent in centred quartile.
        particles.add(new Particle(this._nextParticleId++,random((width * 0.2),(width * 0.8)),random((height * 0.2),(height * 0.8)),0,this._particleRange,this._particleRepulse));
      } catch (Exception e) {
        println(e);
        exit();
      }
    }
  }

  void update() {
/** 
* Update system - Updates particle positions based on forces and displays the result.
* 
* @param run Enables and disables the update of the particle velocities to freeze particle positions.
* @param dest Enables and disables the destination vector
* @param perimCoord Enables and disables the perimeter only directional vector
* @param perimCompress Enables and disables the reduction of the perimeter agents repulsion range
*/
    String pData = "";
    PVector change = new PVector(0,0,0);
    PVector avoid = new PVector(0,0,0);
    PVector dir = new PVector(0,0,0);
    PVector coh = new PVector(0,0,0);
    PVector rep = new PVector(0,0,0);
    PVector inter = new PVector(0,0,0);
    for(Particle p : particles) {      
      avoid.set(0,0,0);
      dir.set(0,0,0);
      change.set(0,0,0); 

      p.getNeighbours(particles);

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
      for(Particle p : particles) {
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
* @param s The swarm
*/
    PVector result = new PVector(0,0,0);
    PVector temp = new PVector(0,0,0);
    float distance = 0f;
//    p._neighbours.clear();
    String nData = "";
    
// GET ALL THE NEIGHBOURS
    for(Particle n : p._neighbours) {
      distance = PVector.dist(p._location,n._location);
      if (this._perimCompress && p._isPerimeter && n._isPerimeter) {
        temp = PVector.sub(n._location,p._location).mult(this._cohesionProportion).mult(this._cohesionBias);
      } else {
        temp = PVector.sub(n._location,p._location).mult(this._cohesionBias);
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

    if (p._neighbours.size() > 0) {
      result.div(p._neighbours.size());
    }
    return result;
  }

  PVector repulsion(Particle p) {
/** 
* repulsion calculation - Calculates the repulsion between each agent and its neigbours.
* 
* @param p The particle that is currently being checked
* @param s The swarm
* @param perimCompress boolean value to toggle swarm perimeter compression on/off 
*/
    PVector result = new PVector(0,0);
    PVector temp = new PVector(0,0);
    int count = 0;
    float dist = 0f;
    float distance = 0f;
    String nData = "";
    for(Particle n : p._neighbours) {
      // IF compress permeter then reduce repulsion field if both agents are perimeter agents.
      if (this._perimCompress && p._isPerimeter && n._isPerimeter) { 
        dist = p._repulse/this._repulseProportion;
      } else {
        dist = p._repulse;
      }
      distance = PVector.dist(p._location,n._location);
      if (distance <= dist & p != n) {
        temp = PVector.sub(p._location, n._location).setMag(dist - distance).mult(this._repulsionBias);
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
* @param perimCoord is perimer coordination enabled
*/
    PVector destination = new PVector(0,0,0);
    PVector dir = new PVector(0,0,0);
    if (p._destinations.size() > 0) {
      destination = p._destinations.get(0)._location;      
      for (int i = 1; i < p._destinations.size(); i++) {
        if (PVector.dist(p._location,destination) > PVector.dist(p._location,p._destinations.get(i)._location)) {
          destination = p._destinations.get(i)._location;
        }
      }   
    }    
    if (!this._perimCoord) {
      dir = PVector.sub(destination,p._location);
    } else {
      /* Perimeter only control */
      if (p._isPerimeter) {
        dir = PVector.sub(destination,p._location);
      }
    }
    return dir.setMag(this._directionBias);
  }
}
