abstract class PSystem {
  ArrayList<Particle> particles = new ArrayList<Particle>();
  ArrayList<Destination> destinations = new ArrayList<Destination>();
  ArrayList<Obstacle> obstacles = new ArrayList<Obstacle>();
  boolean _lines = true;
  float _cohesionBias = 0.3f; // Must be < particle._topspeed to allow the swarm to stabalise to "pseudo equilibrium" (no jitter).
  float _repulsionBias = 300f; // Must be > _cohesionBias to prevent the swarm collapsing.
  float _directionBias = 80f; // Must be > particle._topspeed to allow free particles to coalesce.
  float _obstacleBias = 500f; // Stay away from those obstacles Eugene.
  float _particleRange = 70f; // Cohesion range, Must be greater than range to repulsion range.
  float _particleRepulse = 50f; // Repulsion range, Must be less than range to allow cohesion.
  float _obstacleRange = 75f; // Obstacle range
  float _repulseProportion = 1f; // Compressed perimeter reduction divisor
  float _cohesionProportion = 1f; // Compressed perimeter reduction divisor

  String _model;
  String _modelId;

  int _nextParticleId = 0;
  int _nextDestId = 0;
  int _nextObsId = 0;
  PVector _swarmDirection = new PVector();
  // float _repulseProportion = 0.5; // Compressed perimeter reduction divisor
  // float _cohesionProportion = 0.5; // Compressed perimeter reduction divisor
  boolean _loggingP = false;
  boolean _loggingN = false;
  Logger plog;
  Logger nClog;
  Logger nRlog;

  abstract void update(boolean run, boolean dest, boolean perimCoord, boolean perimCompress);
  abstract PVector cohesion(Particle p, boolean perimCompress);
  abstract PVector repulsion(Particle p, boolean perimCompress);
  abstract PVector direction(Particle p, boolean perimCoord);

//   PSystem(int size, float particleRange, float particleRepulse, float obstacleRange, float cohesionBias, float repulsionBias, float obstacleBias, float directionBias, String model, String modelId) {
// /** 
// * Sets up the environment with agents and parameters for the simulation
// * 
// * @param size no. of agents
// * @param range cohesion range of agents
// * @param repulse repulse repulsion range of agents
// * @param cohesionBias cohesion bias of system
// * @param repulsionBias repulsion bias of system
// * @param directionBias directional bias of system
// */ 
//     this._particleRange = particleRange;
//     this._particleRepulse = particleRepulse;
//     this._cohesionBias = cohesionBias;
//     this._repulsionBias = repulsionBias;
//     this._directionBias = directionBias;
//     this._obstacleBias = obstacleBias;
//     this._obstacleRange = obstacleRange;
//     this._model = model;
//     this._modelId = modelId;

//     for(int i = 0; i < size; i++) {
//       try {
//         // create agent in centred quartile.
//         particles.add(new Particle(this._nextParticleId++,random((width * 0.2),(width * 0.8)),random((height * 0.2),(height * 0.8)),0,this._particleRange,this._particleRepulse));
//       } catch (Exception e) {
//         println(e);
//         exit();
//       }
//     }
//     this.plog = new Logger("csv/P-"+_modelId+"-p.csv");
//     this.nClog = new Logger("csv/P-"+_modelId+"-nc.csv");
//     this.nRlog = new Logger("csv/P-"+_modelId+"-nr.csv");
//     this.plog.dump("STEP,ID,X,Y,Z,RANGE,REPULSE,SIZE,MASS,PERIM,CX,CY,CZ,CMAG,RX,RY,RZ,RMAG,IX,IY,IZ,IMAG,AX,AY,AZ,AMAG,DX,DY,DZ,DMAG,CHANGEX,CHANGEY,CHANGEZ,CHANGEMAG\n");    
//     this.nClog.dump("STEP,PID,NID,X,Y,Z,RANGE,REPULSE,SIZE,MASS,PERIM,COHX,COHY,COHZ,MAG,DIST\n");    
//     this.nRlog.dump("STEP,PID,NID,X,Y,Z,RANGE,REPULSE,SIZE,MASS,PERIM,REPX,REPY,REPZ,MAG,DIST\n");    
//   }
  
  PSystem(String model, String modelId) {
/** 
* Sets up the environment with agents and parameters for the simulation
* 
*/ 
    this._model = model;
    this._modelId = modelId;
    this.plog = new Logger("csv/P-"+_modelId+"-p.csv");
    this.nClog = new Logger("csv/P-"+_modelId+"-nc.csv");
    this.nRlog = new Logger("csv/P-"+_modelId+"-nr.csv");
    this.plog.dump("STEP,ID,X,Y,Z,RANGE,REPULSE,SIZE,MASS,PERIM,CX,CY,CZ,CMAG,RX,RY,RZ,RMAG,IX,IY,IZ,IMAG,AX,AY,AZ,AMAG,DX,DY,DZ,DMAG,CHANGEX,CHANGEY,CHANGEZ,CHANGEMAG\n");    
    this.nClog.dump("STEP,PID,NID,X,Y,Z,RANGE,REPULSE,SIZE,MASS,PERIM,COHX,COHY,COHZ,MAG,DIST\n");    
    this.nRlog.dump("STEP,PID,NID,X,Y,Z,RANGE,REPULSE,SIZE,MASS,PERIM,REPX,REPY,REPZ,MAG,DIST\n");    
  }

  void populate(int size) {
    for(int i = 0; i < size; i++) {
      try {
        // create agent in centred quartile.
        particles.add(new Particle(this._nextParticleId++,random((width * 0.2),(width * 0.8)),random((height * 0.2),(height * 0.8)),0,this._particleRange,this._particleRepulse));
      } catch (Exception e) {
        println(e);
        exit();
      }
    }
  }

  PVector getCentroid() {
    PVector center = new PVector(0,0);
    for(Particle p : this.particles) {
        center.add(p._location);
    }    
    center.div(this.particles.size());
    return center;
  }

  void saveSwarm() {
    PrintWriter output;
    output = createWriter("P-"+_modelId+"-agents.dat"); 
    output.println(this.particles.size() + "," + this._particleRange + "," + this._particleRepulse + "," + this._repulsionBias + "," + this._cohesionBias + "," + this._directionBias +  "," + this._cohesionProportion + "," + this._repulseProportion);
    for(Particle p : particles) {
        output.println(p.toString());
    }        
    output.flush();
    output.close();
    output = createWriter("P-"+_modelId+"-obstacles.dat"); 
    for(Obstacle o : obstacles) {
        output.println(o.toString());
    }        
    output.flush();
    output.close();
    output = createWriter("P-"+_modelId+"-destinations.dat"); 
    for(Destination d : destinations) {
        output.println(d.toString());
    }        
    output.flush();
    output.close();
  }

  void loadSwarm() {
/** 
* Load environment settings from file and particles.
* 
* @param size no. of agents
* @param linesYN Grid enabled/disable
*/    

//_id + "," + _location.x + "," + _location.y + ","+ _location.z + "," + _range + "," + _repulse + "," + _size + "," + _mass + "," + _isPerimeter

    String[] lines = loadStrings("P-"+_modelId+"-agents.dat");
    float[] params = float(split(lines[0], ','));
    this._particleRange = params[1];
    this._particleRepulse = params[2];
    this._repulsionBias = params[3];
    this._cohesionBias = params[4];
    this._directionBias = params[5];
    this._cohesionProportion = params[6];
    this._repulseProportion = params[7];

    this.particles.clear();
    for (int i = 1 ; i < lines.length; i++) {
      float[] nums = float(split(lines[i], ','));
      try {
        particles.add(new Particle(int(nums[0]), nums[1], nums[2], nums[3], nums[4], nums[5], nums[6], nums[7]));
        this._nextParticleId = int(nums[0]++);
      } catch (Exception e) {
        println(e);
        exit();
      }
    }
    lines = loadStrings("P-"+_modelId+"-obstacles.dat");
    this.obstacles.clear();
    for (String data : lines) {
      float[] nums = float(split(data, ','));
      obstacles.add(new Obstacle(int(nums[0]), nums[1], nums[2], nums[3], nums[4], nums[5], nums[6]));
      this._nextObsId = int(nums[0]++);
    }

    lines = loadStrings("P-"+_modelId+"-destinations.dat");
    this.destinations.clear();
    for (String data : lines) {
      float[] nums = float(split(data, ','));
      Destination d = new Destination(int(nums[0]), nums[1], nums[2], nums[3], nums[4], nums[5]);
      destinations.add(d);
      this._nextObsId = int(nums[0]++);
      for(Particle p : particles) {
        p.addDestination(d);
      }
    }
  }
  
  void moveReset() {
    for(Particle p : this.particles) {
      p.move();
      p.reset();
    }
  }
  
  PVector avoidObstacles(Particle p) {
/** 
* obstacle avoidance calculation - Calculates the repulsion
* 
* @param p The particle that is currently being checked
*/
    PVector result = new PVector(0,0);
// GET ALL THE IN RANGE OBSTACLES
    for(Obstacle o : this.obstacles) {
      if (PVector.dist(p._location,o._location) <= o._range) {
         result.add(PVector.sub(o._location,p._location));
      };
    }
    return result.normalize().mult(-_obstacleBias);
  }

  void addDestination(float x, float y, float z) {
    Destination d = new Destination(_nextDestId++,x,y,z);
    this.destinations.add(d);
    for(Particle p : particles) {
      p.addDestination(d);
    }
  }

  void deleteDestinationById(int id) {
    for (int i = this.destinations.size() - 1; i >= 0; i--) {
      Destination d = this.destinations.get(i);
      if (d._id == id) {
        for(Particle p : particles) {
          p.removeDestination(d);
        }
        this.destinations.remove(i);
      }
    }
  }

  Destination getDestinationWithId(int id) {
     for(Destination d : this.destinations) {
       if (d._id == id) return d;
     }
     return null;
  }
  
  void addParticle(float x, float y, float z) {
    try {
      // create agent in centred quartile.
      Particle p = new Particle(this._nextParticleId++,x,y,z,this._particleRange,this._particleRepulse);
      p.setDestinations(this.destinations);
      this.particles.add(p);
    } catch (Exception e) {
      println(e);
      exit();
    }
  }
  
  void deleteParticleById(int id) {
    for (int i = this.particles.size() - 1; i >= 0; i--) {
      Particle part = this.particles.get(i);
      if (part._id == id) {
        this.particles.remove(i);
      }
    }
  }
  
  Particle getParticleWithId(int id) {
     for(Particle n : this.particles) {
       if (n._id == id) return n;
     }
     return null;
  }

  Obstacle getObstacleWithId(int id) {
     for(Obstacle o : this.obstacles) {
       if (o._id == id) return o;
     }
     return null;
  }

  void deleteObstacleById(int id) {
    for (int i = this.obstacles.size() - 1; i >= 0; i--) {
      Obstacle o = this.obstacles.get(i);
      if (o._id == id) {
        this.obstacles.remove(i);
      }
    }
  }

  void addObstacle(float x, float y, float z) {
      this.obstacles.add(new Obstacle(_nextObsId++,x,y,z,this._obstacleRange));
  }

  boolean hasObstacles() {
    return (this.obstacles.size() > 0);
  }
}
