abstract class PSystem {
  java.util.Properties modelProperties = new java.util.Properties();
  ArrayList<Particle> S = new ArrayList<Particle>();
  ArrayList<Destination> destinations = new ArrayList<Destination>();
  ArrayList<Obstacle> obstacles = new ArrayList<Obstacle>();
  boolean _lines = true;
  int _swarmSize = 0;
  float _kc = 0.3f; // Must be < particle._topspeed to allow the swarm to stabalise to "pseudo equilibrium" (no jitter).
  float _kr = 300f; // Must be > _kc to prevent the swarm collapsing.
  float _kd = 80f; // Must be > particle._topspeed to allow free S to coalesce.
  float _ko = 500f; // Stay away from those obstacles Eugene.
  float _Cb = 70f; // Cohesion range, Must be greater than range to repulsion range.
  float _Rb = 50f; // Repulsion range, Must be less than range to allow cohesion.
  float _Ob = 75f; // Obstacle range
  float _pr = 1f; // Compressed perimeter reduction divisor
  float _pc = 1f; // Compressed perimeter reduction divisor
  int _seed = 1234;
  int _grid = 500;
  PSVector test = new PSVector();
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
    this._seed = int(modelProperties.getProperty("seed"));
    this._grid = int(modelProperties.getProperty("grid"));
    this._Cb = float(modelProperties.getProperty("Cb"));
    this._Rb = float(modelProperties.getProperty("Rb"));
    this._kr = float(modelProperties.getProperty("kr"));
    this._kc = float(modelProperties.getProperty("kc"));
    this._kd = float(modelProperties.getProperty("kd"));
    this._ko = float(modelProperties.getProperty("ko"));
    this._Ob = float(modelProperties.getProperty("Ob"));
    this._obstacleLink = boolean(modelProperties.getProperty("obstacleLink"));
    this._pr = float(modelProperties.getProperty("pr"));
    this._pc = float(modelProperties.getProperty("pc"));
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

  public PVector getCentroid() {
    PVector center = new PVector(0,0);
    for(Particle p : this.S) {
        center.add(p._loc);
    }    
    center.div(this.S.size());
    return center;
  }

  public void saveSwarm() {
/** 
* Save environment settings to file.
* 
*/  
    int i = 0;
    JSONObject json = new JSONObject();
    JSONObject jsonParams = new JSONObject();

    JSONObject jsonAgents = new JSONObject();
    JSONArray jsonAgentsProps = new JSONArray();
    JSONArray jsonAgentsCoords = new JSONArray();
    JSONArray jsonAgentsX = new JSONArray();
    JSONArray jsonAgentsY = new JSONArray();
    JSONArray jsonAgentsZ = new JSONArray();

    JSONObject jsonDestinations = new JSONObject();
    JSONArray jsonDestinationsProps = new JSONArray();
    JSONArray jsonDestinationsCoords = new JSONArray();
    JSONArray jsonDestinationsX = new JSONArray();
    JSONArray jsonDestinationsY = new JSONArray();
    JSONArray jsonDestinationsZ = new JSONArray();

    JSONObject jsonObstacles = new JSONObject();
    JSONArray jsonObstaclesProps = new JSONArray();
    JSONArray jsonObstaclesCoords = new JSONArray();
    JSONArray jsonObstaclesX = new JSONArray();
    JSONArray jsonObstaclesY = new JSONArray();
    JSONArray jsonObstaclesZ = new JSONArray();
    
    PrintWriter output;
//    output = createWriter("save/P-"+_modelId+"-agents.dat"); 
//    output.println(this.S.size() + "," + this._Cb + "," + this._Rb + "," + this._kr + "," + this._kc + "," + this._kd +  "," + this._pc + "," + this._pr);
    jsonParams.put("cb",this._Cb);
//    jsonParams.put("seed",this._seed);
//    jsonParams.put("grid",this._grid);
    jsonParams.put("rb",this._Rb);
    jsonParams.put("kr",this._kr);
    jsonParams.put("kc",this._kc);
    jsonParams.put("kd",this._kd);
    jsonParams.put("ko",this._ko);
    jsonParams.put("ob",this._Ob);
    jsonParams.put("pr",this._pr);
    jsonParams.put("pc",this._pc);
    jsonParams.put("perim_coord",this._perimCoord);

    i = 0;
    for(Particle p : S) {
      jsonAgentsProps.setJSONObject(i,p.getJSONProps());
      jsonAgentsX.setFloat(i,p._loc.x);
      jsonAgentsY.setFloat(i,p._loc.y);
      jsonAgentsZ.setFloat(i,p._loc.z);
      i++;
//      output.println(p.toString());
    }
    
    jsonAgentsCoords.setJSONArray(0,jsonAgentsX);
    jsonAgentsCoords.setJSONArray(1,jsonAgentsY);
    jsonAgentsCoords.setJSONArray(2,jsonAgentsZ);

    jsonAgents.put("coords",jsonAgentsCoords);
    jsonAgents.put("props",jsonAgentsProps);

//    output.flush();
//    output.close();
//    output = createWriter("save/P-"+_modelId+"-obstacles.dat");

     i = 0;
    for(Obstacle o : obstacles) {
      jsonObstaclesProps.setJSONObject(i,o.getJSONProps());
      jsonObstaclesX.setFloat(i,o._loc.x);
      jsonObstaclesY.setFloat(i,o._loc.y);
      jsonObstaclesZ.setFloat(i,o._loc.z);
      i++;
//      output.println(o.toString());
    } 

    jsonObstaclesCoords.setJSONArray(0,jsonObstaclesX);
    jsonObstaclesCoords.setJSONArray(1,jsonObstaclesY);
    jsonObstaclesCoords.setJSONArray(2,jsonObstaclesZ);

    jsonObstacles.put("coords",jsonObstaclesCoords);
    jsonObstacles.put("props",jsonObstaclesProps);

//    output.flush();
//    output.close();
//    output = createWriter("save/P-"+_modelId+"-destinations.dat"); 
    i = 0;
    for(Destination d : destinations) {
      jsonDestinationsProps.setJSONObject(i,d.getJSONProps());
      jsonDestinationsX.setFloat(i,d._loc.x);
      jsonDestinationsY.setFloat(i,d._loc.y);
      jsonDestinationsZ.setFloat(i,d._loc.z);
      i++;
//      output.println(d.toString());
    }        

    jsonDestinationsCoords.setJSONArray(0,jsonDestinationsX);
    jsonDestinationsCoords.setJSONArray(1,jsonDestinationsY);
    jsonDestinationsCoords.setJSONArray(2,jsonDestinationsZ);

    jsonDestinations.put("coords",jsonDestinationsCoords);
    jsonDestinations.put("props",jsonDestinationsProps);

//    output.flush();
//    output.close();

    json.put("obstacles",jsonObstacles);
    json.put("destinations",jsonDestinations);
    json.put("agents",jsonAgents);
    json.put("params",jsonParams);
    saveJSONObject(json, "save/pswarm"+_modelId+".json");
  }

  public void loadSwarm() {
/** 
* Load environment settings from files.
* 
*/   
    JSONObject json = loadJSONObject("save/pswarm"+_modelId+".json");
//    println("AGENTS:");
    this.S.clear();

    JSONArray props = json.getJSONObject("agents").getJSONArray("props");
    JSONArray coords = json.getJSONObject("agents").getJSONArray("coords");

    for (int i = 0; i < props.size(); i++) {
      JSONObject p = props.getJSONObject(i);
      JSONArray x = coords.getJSONArray(0);
      JSONArray y = coords.getJSONArray(1);
      JSONArray z = coords.getJSONArray(2);
      try {
//        Particle(int i, float x, float y, float z, float Cb, float Rb, float size, float mass)
        S.add(new Particle(p.getInt("id"), (float)x.getDouble(i), (float)y.getDouble(i), (float)z.getDouble(i), (float)p.getDouble("cb"), (float)p.getDouble("rb"), (float)p.getDouble("size"), (float)p.getDouble("mass")));
        this._nextParticleId = p.getInt("id") + 1;
      } catch (Exception e) {
        println(e);
        exit();
      }
//      println(p.getInt("id") + ":" + p.getFloat("rb") + " x:" + x.getDouble(i) + " y:" + y.getDouble(i) + " z:" + z.getDouble(i));
    }

//    println("DESTINATIONS:");
    props = json.getJSONObject("destinations").getJSONArray("props");
    coords = json.getJSONObject("destinations").getJSONArray("coords");

    for (int i = 0; i < props.size(); i++) {
      JSONObject d = props.getJSONObject(i);
      JSONArray x = coords.getJSONArray(0);
      JSONArray y = coords.getJSONArray(1);
      JSONArray z = coords.getJSONArray(2);
//  Destination(int i, float x, float y, float z, float size, float mass) {

      Destination dest = new Destination(d.getInt("id"), (float)x.getDouble(i), (float)y.getDouble(i), (float)z.getDouble(i), (float)d.getDouble("size"), (float)d.getDouble("mass"));
      destinations.add(dest);
      this._nextDestId = d.getInt("id") + 1;
      for(Particle p : S) {
        p.addDestination(dest);
      }
//      println(d.getInt("id") + ":" + d.getFloat("size") + " x:" + x.getDouble(i) + " y:" + y.getDouble(i) + " z:" + z.getDouble(i));
    }

//    println("OBSTACLES:");
    props = json.getJSONObject("obstacles").getJSONArray("props");
    coords = json.getJSONObject("obstacles").getJSONArray("coords");

    for (int i = 0; i < props.size(); i++) {
      JSONObject o = props.getJSONObject(i);
      JSONArray x = coords.getJSONArray(0);
      JSONArray y = coords.getJSONArray(1);
      JSONArray z = coords.getJSONArray(2);
//      Obstacle(int i, float x, float y, float z, float Ob, float size, float mass) {
      obstacles.add(new Obstacle(o.getInt("id"), (float)x.getDouble(i), (float)y.getDouble(i), (float)z.getDouble(i), (float)o.getDouble("ob"), (float)o.getDouble("size"), (float)o.getDouble("mass")));
      this._nextObsId = o.getInt("id") + 1;
//      println(o.getInt("id") + ":" + o.getFloat("size") + " x:" + x.getDouble(i) + " y:" + y.getDouble(i) + " z:" + z.getDouble(i));
    }

    // String[] lines = loadStrings("save/P-"+_modelId+"-agents.dat");
    // float[] params = float(split(lines[0], ','));
    // this._Cb = params[1];
    // this._Rb = params[2];
    // this._kr = params[3];
    // this._kc = params[4];
    // this._kd = params[5];
    // this._pc = params[6];
    // this._pr = params[7];

    // this.S.clear();
    // for (int i = 1 ; i < lines.length; i++) {
    //   float[] nums = float(split(lines[i], ','));
    //   try {
    //     S.add(new Particle(int(nums[0]), nums[1], nums[2], nums[3], nums[4], nums[5], nums[6], nums[7]));
    //     this._nextParticleId = int(nums[0]) + 1;
    //   } catch (Exception e) {
    //     println(e);
    //     exit();
    //   }
    // }
    // lines = loadStrings("save/P-"+_modelId+"-obstacles.dat");
    // this.obstacles.clear();
    // for (String data : lines) {
    //   float[] nums = float(split(data, ','));
    //   obstacles.add(new Obstacle(int(nums[0]), nums[1], nums[2], nums[3], nums[4], nums[5], nums[6]));
    //   this._nextObsId = int(nums[0]) + 1;
    // }

    // lines = loadStrings("save/P-"+_modelId+"-destinations.dat");
    // this.destinations.clear();
    // for (String data : lines) {
    //   float[] nums = float(split(data, ','));
    //   Destination d = new Destination(int(nums[0]), nums[1], nums[2], nums[3], nums[4], nums[5]);
    //   destinations.add(d);
    //   this._nextDestId = int(nums[0]) + 1;
    //   for(Particle p : S) {
    //     p.addDestination(d);
    //   }
    // }
    this.init(); 
  }
  
  public void moveReset() {
    if(this._run) {
      for(Particle p : this.S) {
        p.move();
        p.reset();
      }
    }
  }
  
  public PVector avoidObstacles(Particle p) {
/** 
* obstacle avoidance calculation - Calculates the repulsion
* 
* @param p The particle that is currently being checked
*/
    PVector result = new PVector(0,0,0);
// GET ALL THE IN RANGE OBSTACLES
    for(Obstacle o : this.obstacles) {
      if (PVector.dist(p._loc,o._loc) <= o._Ob) {
         result.add(PVector.sub(o._loc,p._loc));
      }
    }
    result.add(calcLineRepulsion(p));
    return result.mult(-_ko);
  }

  public PVector calcLineRepulsion(Particle p) {
    PVector result = new PVector(0,0,0);
    if (system.obstacles.size() > 1 && this._obstacleLink) {
      for (int i = 1; i < this.obstacles.size(); i++) {
        float x0 = p._loc.x;
        float y0 = p._loc.y;
        float x1 = this.obstacles.get(i)._loc.x;
        float y1 = this.obstacles.get(i)._loc.y;
        float x2 = this.obstacles.get(i-1)._loc.x;
        float y2 = this.obstacles.get(i-1)._loc.y;
        float dir = ((x2-x1) * (y1-y0)) - ((x1-x0) * (y2-y1)); // above or below line segment
        float distance = distBetweenPointAndLine(x0,y0,x1,y1,x2,y2);
        ArrayList<PVector> polygon = new ArrayList<PVector>();

        PVector start = system.obstacles.get(i)._loc;
        PVector end = system.obstacles.get(i-1)._loc;
        PVector d = PVector.sub(end,start);
        d.rotate(HALF_PI).setMag(system._Ob); 
        polygon.add(PVector.add(start,d));
        polygon.add(PVector.add(end,d));
        polygon.add(PVector.sub(end,d));
        polygon.add(PVector.sub(start,d));
        if (distance <= system._Ob && pointInRectangle(p._loc,polygon)) {
          if (dir > 0) {
            result.add(d);
          } else {
            result.sub(d);
          }
        }
      }
    }
    return result;
  }

  public float distBetweenPointAndLine(float x, float y, float x1, float y1, float x2, float y2) {
    // A - the standalone point (x, y)
    // B - start point of the line segment (x1, y1)
    // C - end point of the line segment (x2, y2)
    // D - the crossing point between line from A to BC
    float AB = distBetween(x, y, x1, y1);
    float BC = distBetween(x1, y1, x2, y2);
    float AC = distBetween(x, y, x2, y2);

    // Heron's formula
    float AD;
    float s = (AB + BC + AC) / 2;
    float area = (float) Math.sqrt(s * (s - AB) * (s - BC) * (s - AC));
    AD = (2 * area) / BC;
    return AD;
  }

  public float distBetween(float x, float y, float x1, float y1) {
    float xx = x1 - x;
    float yy = y1 - y;
    return (float) Math.sqrt(xx * xx + yy * yy);
  }

  public boolean pointInRectangle(PVector p, ArrayList<PVector> polygon) {
    boolean isInside = false;
    for (int i = 0, j = polygon.size() - 1; i < polygon.size(); j = i++) {
        if ( (polygon.get(i).y > p.y) != (polygon.get(j).y > p.y) &&
                p.x < (polygon.get(j).x - polygon.get(i).x) * (p.y - polygon.get(i).y) / (polygon.get(j).y - polygon.get(i).y) + polygon.get(i).x ) {
            isInside = !isInside;
        }
    }
    return isInside;
  }

  public void addDestination(float x, float y, float z) {
/** 
* Add Destination in 3D
* 
* @param x X Position
* @param y Y Position
* @param z Z Position
*/
    Destination d = new Destination(_nextDestId++,x,y,z);
    this.destinations.add(d);
    for(Particle p : S) {
      p.addDestination(d);
    }
  }

  public void deleteDestination(Destination d) {
/** 
* Delete Destination
* 
* @param d Destination
*/
    for (int i = this.destinations.size() - 1; i >= 0; i--) {
      Destination dest = this.destinations.get(i);
      if (d == dest) {
        for(Particle p : S) {
          p.removeDestination(d);
        }
        this.destinations.remove(i);
      }
    }
  }

  public void addParticle(float x, float y, float z) {
/** 
* Add Particle/Agent in 3D
* 
* @param x X Position
* @param y Y Position
* @param z Z Position
*/
    try {
      // create agent in centred quartile.
      Particle p = new Particle(this._nextParticleId++,x,y,z,this._Cb,this._Rb);
      p.setDestinations((ArrayList<Destination>) this.destinations.clone());
      this.S.add(p);
    } catch (Exception e) {
      println(e);
      exit();
    }
  }
  
  public void deleteParticle(Particle p) {
/** 
* Delete Particle/Agent
* 
* @param p Particle
*/
    for (int i = this.S.size() - 1; i >= 0; i--) {
      Particle part = this.S.get(i);
      if (part == p) {
        this.S.remove(i);
      }
    }
  }

  public void deleteObstacle(Obstacle o) {
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

  public void addObstacle(float x, float y, float z) {
/** 
* Add Destination in 3D
* 
* @param x X Position
* @param y Y Position
* @param z Z Position
*/
    this.obstacles.add(new Obstacle(_nextObsId++,x,y,z,this._Ob));
  }

  public boolean hasObstacles() {
    return (this.obstacles.size() > 0);
  }
}
