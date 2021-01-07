abstract class PSystem {
  java.util.Properties modelProperties = new java.util.Properties();
  ArrayList<Particle> particles = new ArrayList<Particle>();
  ArrayList<Destination> destinations = new ArrayList<Destination>();
  ArrayList<Obstacle> obstacles = new ArrayList<Obstacle>();
  boolean _lines = true;
  int _swarmSize = 0;
  float _cohesionBias = 0.3f; // Must be < particle._topspeed to allow the swarm to stabalise to "pseudo equilibrium" (no jitter).
  float _repulsionBias = 300f; // Must be > _cohesionBias to prevent the swarm collapsing.
  float _directionBias = 80f; // Must be > particle._topspeed to allow free particles to coalesce.
  float _obstacleBias = 500f; // Stay away from those obstacles Eugene.
  float _particleRange = 70f; // Cohesion range, Must be greater than range to repulsion range.
  float _particleRepulse = 50f; // Repulsion range, Must be less than range to allow cohesion.
  float _obstacleRange = 75f; // Obstacle range
  float _repulseProportion = 1f; // Compressed perimeter reduction divisor
  float _cohesionProportion = 1f; // Compressed perimeter reduction divisor
  boolean _obstacleLink = true;
  boolean _dest = true;
  boolean _run = true;
  boolean _perimCoord = false;
  boolean _perimCompress = false;

  String _model;
  String _modelId;

  int _nextParticleId = 0;
  int _nextDestId = 0;
  int _nextObsId = 0;
  PVector _swarmDirection = new PVector();
  boolean _loggingP = false;
  boolean _loggingN = false;
  Logger plog;
  Logger nClog;
  Logger nRlog;

  abstract void update();
  abstract PVector cohesion(Particle p);
  abstract PVector repulsion(Particle p);
  abstract PVector direction(Particle p);
  abstract void populate();
  abstract void init();

  PSystem(String model, String modelId) {
/** 
* Sets up the environment with agents and parameters for the simulation
* 
*/ 
    this._model = model;
    this._modelId = modelId;

    try {
      modelProperties.load( createReader("Model" + this._modelId + ".properties") );
    } catch(Exception e) {
      println(e);
      exit();
    }

    this._swarmSize = int(modelProperties.getProperty("size"));
    this._particleRange = float(modelProperties.getProperty("particleRange"));
    this._particleRepulse = float(modelProperties.getProperty("particleRepulse"));
    this._repulsionBias = float(modelProperties.getProperty("repulsionBias"));
    this._cohesionBias = float(modelProperties.getProperty("cohesionBias"));
    this._directionBias = float(modelProperties.getProperty("directionBias"));
    this._obstacleBias = float(modelProperties.getProperty("obstacleBias"));
    this._obstacleRange = float(modelProperties.getProperty("obstacleRange"));
    this._repulseProportion = float(modelProperties.getProperty("repulseProportion"));
    this._cohesionProportion = float(modelProperties.getProperty("cohesionProportion"));
    this._dest = boolean(modelProperties.getProperty("dest"));
    this._perimCoord = boolean(modelProperties.getProperty("perimCoord"));
    this._perimCompress = boolean(modelProperties.getProperty("perimCompress"));
    this._run = boolean(modelProperties.getProperty("run"));
    this._loggingP = boolean(modelProperties.getProperty("loggingP"));
    this._loggingN = boolean(modelProperties.getProperty("loggingN"));
    this.plog = new Logger("csv/P-"+_modelId+"-p.csv");
    this.nClog = new Logger("csv/P-"+_modelId+"-nc.csv");
    this.nRlog = new Logger("csv/P-"+_modelId+"-nr.csv");
    this.plog.dump("STEP,ID,X,Y,Z,RANGE,REPULSE,SIZE,MASS,PERIM,CX,CY,CZ,CMAG,RX,RY,RZ,RMAG,IX,IY,IZ,IMAG,AX,AY,AZ,AMAG,DX,DY,DZ,DMAG,CHANGEX,CHANGEY,CHANGEZ,CHANGEMAG\n");    
    this.nClog.dump("STEP,PID,NID,X,Y,Z,RANGE,REPULSE,SIZE,MASS,PERIM,COHX,COHY,COHZ,MAG,DIST\n");    
    this.nRlog.dump("STEP,PID,NID,X,Y,Z,RANGE,REPULSE,SIZE,MASS,PERIM,REPX,REPY,REPZ,MAG,DIST\n");  

    if (boolean(modelProperties.getProperty("loadSwarm"))) {
      this.loadSwarm();
    } else {
      this.populate();
    }
    this.init();  
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
/** 
* Save environment settings to file.
* 
*/     
    PrintWriter output;
    output = createWriter("save/P-"+_modelId+"-agents.dat"); 
    output.println(this.particles.size() + "," + this._particleRange + "," + this._particleRepulse + "," + this._repulsionBias + "," + this._cohesionBias + "," + this._directionBias +  "," + this._cohesionProportion + "," + this._repulseProportion);
    for(Particle p : particles) {
        output.println(p.toString());
    }        
    output.flush();
    output.close();
    output = createWriter("save/P-"+_modelId+"-obstacles.dat"); 
    for(Obstacle o : obstacles) {
        output.println(o.toString());
    }        
    output.flush();
    output.close();
    output = createWriter("save/P-"+_modelId+"-destinations.dat"); 
    for(Destination d : destinations) {
        output.println(d.toString());
    }        
    output.flush();
    output.close();
  }

  void loadSwarm() {
/** 
* Load environment settings from files.
* 
*/    
    String[] lines = loadStrings("save/P-"+_modelId+"-agents.dat");
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
        this._nextParticleId = int(nums[0]) + 1;
      } catch (Exception e) {
        println(e);
        exit();
      }
    }
    lines = loadStrings("save/P-"+_modelId+"-obstacles.dat");
    this.obstacles.clear();
    for (String data : lines) {
      float[] nums = float(split(data, ','));
      obstacles.add(new Obstacle(int(nums[0]), nums[1], nums[2], nums[3], nums[4], nums[5], nums[6]));
      this._nextObsId = int(nums[0]) + 1;
    }

    lines = loadStrings("save/P-"+_modelId+"-destinations.dat");
    this.destinations.clear();
    for (String data : lines) {
      float[] nums = float(split(data, ','));
      Destination d = new Destination(int(nums[0]), nums[1], nums[2], nums[3], nums[4], nums[5]);
      destinations.add(d);
      this._nextDestId = int(nums[0]) + 1;
      for(Particle p : particles) {
        p.addDestination(d);
      }
    }
    this.init(); 
  }
  
  void moveReset() {
    if(this._run) {
      for(Particle p : this.particles) {
        p.move();
        p.reset();
      }
    }
  }
  
  PVector avoidObstacles(Particle p) {
/** 
* obstacle avoidance calculation - Calculates the repulsion
* 
* @param p The particle that is currently being checked
*/
    PVector result = new PVector(0,0,0);
// GET ALL THE IN RANGE OBSTACLES
    for(Obstacle o : this.obstacles) {
      if (PVector.dist(p._location,o._location) <= o._range) {
         result.add(PVector.sub(o._location,p._location));
      }
    }

    if (system.obstacles.size() > 1 && this._obstacleLink) {
      for (int i = 1; i < this.obstacles.size(); i++) {
        float x0 = p._location.x;
        float y0 = p._location.y;
        float x1 = this.obstacles.get(i)._location.x;
        float y1 = this.obstacles.get(i)._location.y;
        float x2 = this.obstacles.get(i-1)._location.x;
        float y2 = this.obstacles.get(i-1)._location.y;

        float dir = ((x2-x1) * (y1-y0)) - ((x1-x0) * (y2-y1));
        float num = abs(dir);
//        float num = dir;
        float denum = sqrt(sq(x2-x1) + sq(y2-y1));
        float distance = num/denum;
        if (distance <= system._obstacleRange && x0 >= min(x1,x2) && x0 <= max(x1,x2) && y0 >= min(y1,y2) && y0 <= max(y1,y2)) {
          PVector start = system.obstacles.get(i)._location;
          PVector end = system.obstacles.get(i-1)._location;
          PVector d = PVector.sub(end,start);
          d.rotate(HALF_PI).setMag(system._obstacleRange);
          if (dir > 0) {
            result.add(d);
          } else {
            result.sub(d);
          }
        }
      }
    }
//    return result.normalize().mult(-_obstacleBias);
    return result.mult(-_obstacleBias);
  }

  void addDestination(float x, float y, float z) {
/** 
* Add Destination in 3D
* 
* @param x X Position
* @param y Y Position
* @param z Z Position
*/
    Destination d = new Destination(_nextDestId++,x,y,z);
    this.destinations.add(d);
    for(Particle p : particles) {
      p.addDestination(d);
    }
  }

  void deleteDestination(Destination d) {
/** 
* Delete Destination
* 
* @param d Destination
*/
    for (int i = this.destinations.size() - 1; i >= 0; i--) {
      Destination dest = this.destinations.get(i);
      if (d == dest) {
        for(Particle p : particles) {
          p.removeDestination(d);
        }
        this.destinations.remove(i);
      }
    }
  }

  void addParticle(float x, float y, float z) {
/** 
* Add Particle/Agent in 3D
* 
* @param x X Position
* @param y Y Position
* @param z Z Position
*/
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
  
  void deleteParticle(Particle p) {
/** 
* Delete Particle/Agent
* 
* @param p Particle
*/
    for (int i = this.particles.size() - 1; i >= 0; i--) {
      Particle part = this.particles.get(i);
      if (part == p) {
        this.particles.remove(i);
      }
    }
  }

  void deleteObstacle(Obstacle o) {
/** 
* Delete Obstacle
* 
* @param o Obstacle
*/
    for (int i = this.obstacles.size() - 1; i >= 0; i--) {
      Obstacle obs = this.obstacles.get(i);
      if (obs == o) {
        this.obstacles.remove(i);
      }
    }
  }

  void addObstacle(float x, float y, float z) {
/** 
* Add Destination in 3D
* 
* @param x X Position
* @param y Y Position
* @param z Z Position
*/
    this.obstacles.add(new Obstacle(_nextObsId++,x,y,z,this._obstacleRange));
  }

  boolean hasObstacles() {
    return (this.obstacles.size() > 0);
  }
}
