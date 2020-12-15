class Model1 extends PSystem {
//  String _model = "Linear Vector";
  Model1(int size, float particleRange, float particleRepulse, float obstacleRange, float cohesionBias, float repulsionBias, float obstacleBias, float directionBias) {
    super(size, particleRange, particleRepulse, obstacleRange, cohesionBias, repulsionBias, obstacleBias, directionBias);
    _model = "Linear Vector";
  }
  
  Model1() {
    super();
    _model = "Linear Vector";
  }

  void update(boolean run, boolean dest, boolean perimCoord, boolean perimCompress) {
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
      coh = cohesion(p, perimCompress);

      /* Calculate Repulsion */
      rep = repulsion(p, perimCompress);

      /* Calculate Obstacle avoidance */
      if (obstacles.size() > 0) {
        avoid = avoidObstacles(p);
      }

      if (dest && destinations.size() > 0) {
        dir = direction(p, perimCoord);
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
    if (run) {
      _swarmDirection.set(0,0,0);
      for(Particle p : particles) {
        _swarmDirection.add(p._resultant);
        p.update();
      }
    }
    if (_loggingP) {
      plog.dump(pData);
      plog.clean();
    }
  }
    
  PVector cohesion(Particle p, boolean perimCompress) {
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
      if (perimCompress && p._isPerimeter && n._isPerimeter) {
        temp = PVector.sub(n._location,p._location).mult(_cohesionProportion).mult(_cohesionBias);
      } else {
        temp = PVector.sub(n._location,p._location).mult(_cohesionBias);
      }
      result.add(temp);
      if (_loggingN && _loggingP) {
        nData = plog._counter + "," + p._id + "," + n.toString() + "," + temp.x + "," + temp.y + "," + temp.z + "," + temp.mag() + "," + distance + "\n";
      }
    }
    if (_loggingN && _loggingP) {
      nClog.dump(nData);
      nClog.clean();
    }

    if (p._neighbours.size() > 0) {
      result.div(p._neighbours.size());
    }
    return result;
  }

  PVector repulsion(Particle p, boolean perimCompress) {
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
      if (perimCompress && p._isPerimeter && n._isPerimeter) { 
        dist = p._repulse/this._repulseProportion;
      } else {
        dist = p._repulse;
      }
      distance = PVector.dist(p._location,n._location);
      if (distance <= dist & p != n) {
        temp = PVector.sub(p._location, n._location).setMag(dist - distance).mult(_repulsionBias);
        result.add(temp);
        if (_loggingN && _loggingP) {
          nData = plog._counter + "," + p._id + "," + n.toString() + "," + temp.x + "," + temp.y + "," + temp.z + "," + temp.mag() + "," + distance + "\n";
        }
      }
    }
    if (_loggingN && _loggingP) {
      nRlog.dump(nData);
      nRlog.clean();
    }
    return result;
  }
}
