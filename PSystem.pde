/************************************************
* Psystem Class - abstract class for 
*                 implementation of models
*************************************************
* See history.txt
*/
import java.io.FileInputStream;  
import java.io.File;
import java.nio.file.Files;
import java.time.LocalDate;
import java.time.LocalTime;

abstract class PSystem {
  java.util.Properties modelProperties = new java.util.Properties();
  ArrayList<Particle> S = new ArrayList<Particle>();
  ArrayList<Destination> D = new ArrayList<Destination>();
  ArrayList<Obstacle> O = new ArrayList<Obstacle>();
  boolean _lines = true;
  int _swarmSize = 0;
//  double _kc = 0.3; // Must be < particle._topspeed to allow the swarm to stabalise to "pseudo equilibrium" (no jitter).
//  double _kr = 300; // Must be > _kc to prevent the swarm collapsing.
  double _kd = 80; // Must be > particle._topspeed to allow free S to coalesce.
  double _ko = 500; // Stay away from those obstacles Eugene.
  double _kg = 0; // mind the gap.
  boolean _rgf = false; // mind the gap.
//  double _Cb = 70; // Cohesion range, Must be greater than range to repulsion range. 
//  double _Rb = 50; // Repulsion range, Must be less than range to allow cohesion.
  double _Ob = 75; // GLobal Obstacle range (stored in each obstacle for future work)
  double[][] _kr = {{1.0,1.0},{1.0,1.0}}; // Compressed perimeter -> inner reduction weight
  double[][] _kc = {{1.0,1.0},{1.0,1.0}}; // Compressed perimeter reduction weight
  double[][] _R = {{1.0,1.0},{1.0,1.0}}; // Repulsion
  double _C = 1; // Cohesion
  double _stability_factor = 0.0; 
  int _seed = 1234;
  double _grid = 500;
  double _speed = 3.0; // Global agent speed (stored in each agent for future work)
  boolean _obstacleLink = true;
  boolean _dest = true;
  boolean _run = true;
  int _step = 0;
  boolean _perimCoord = false;
  boolean _perimCompress = false;
  boolean _particleOptimise = false;
  boolean _logMin = true;

  String _model; // Text of model type
  String _modelId; // Model number.

  int _nextParticleId = 0;
  int _nextDestId = 0;
  int _nextObsId = 0;
  PVectorD _swarmDirection = new PVectorD();
  boolean _loggingP = false;
  boolean _loggingN = false;
  Logger plog;
  Logger nClog;
  Logger nRlog;

// Abstract methods for model implementation
  abstract void update();
  abstract PVectorD cohesion(Particle p);
  abstract PVectorD repulsion(Particle p);
  abstract PVectorD direction(Particle p);
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
//  JAVA-BASED PROPERTIES (Processing Mangles the paths)
//      modelProperties.load(new FileInputStream("Model" + this._modelId + ".properties"));
    } catch(Exception e) {
      println(e);
      exit();
    }
// Default model properties
    this._swarmSize = int(modelProperties.getProperty("size"));
    this._seed = int(modelProperties.getProperty("seed"));
    this._grid = Double.parseDouble(modelProperties.getProperty("grid"));
    this._kd = Double.parseDouble(modelProperties.getProperty("kd"));
    this._ko = Double.parseDouble(modelProperties.getProperty("ko"));
    this._kg = Double.parseDouble(modelProperties.getProperty("kg"));
    this._rgf = boolean(modelProperties.getProperty("rgf"));
    this._Ob = Double.parseDouble(modelProperties.getProperty("Ob"));
    this._speed = Double.parseDouble(modelProperties.getProperty("speed"));
    this._obstacleLink = boolean(modelProperties.getProperty("obstacleLink"));
    this._kr = getArray(modelProperties.getProperty("kr"));
    this._kc = getArray(modelProperties.getProperty("kc"));
    this._R = getArray(modelProperties.getProperty("rb"));
    this._C = Double.parseDouble(modelProperties.getProperty("cb"));
    this._stability_factor = Double.parseDouble(modelProperties.getProperty("stability_factor"));
    this._dest = boolean(modelProperties.getProperty("dest"));
    this._perimCoord = boolean(modelProperties.getProperty("perimCoord"));
    this._perimCompress = boolean(modelProperties.getProperty("perimCompress"));
    this._run = boolean(modelProperties.getProperty("run"));
    this._logMin = boolean(modelProperties.getProperty("logMin"));
    this._loggingP = boolean(modelProperties.getProperty("loggingP"));
    this._loggingN = boolean(modelProperties.getProperty("loggingN"));
    if (this._loggingP) {
      this.plog = new Logger("data/csv/"+modelProperties.getProperty("swarmData"));
      this.nClog = new Logger("data/csv/"+modelProperties.getProperty("cohesionData"));
      this.nRlog = new Logger("data/csv/"+modelProperties.getProperty("repulsionData"));
      if (this._logMin) {
        this.plog.dump("STEP,ID,X,Y,PERIM,CX,CY,CMAG,RX,RY,RMAG,IX,IY,IMAG,DX,DY,DMAG,CHANGEX,CHANGEY,CHANGEMAG\n");    
        this.nClog.dump("STEP,PID,PX,PY,PPERIM,NID,NX,NY,NPERIM,COHX,COHY,COHZ,MAG,DIST\n");    
        this.nRlog.dump("STEP,PID,PX,PY,PPERIM,NID,NX,NY,NPERIM,REPX,REPY,REPZ,MAG\n");  
      } else {
        this.plog.dump("STEP,ID,X,Y,Z,RANGE,REPULSE,SIZE,MASS,PERIM,CX,CY,CZ,CMAG,RX,RY,RZ,RMAG,IX,IY,IZ,IMAG,AX,AY,AZ,AMAG,DX,DY,DZ,DMAG,CHANGEX,CHANGEY,CHANGEZ,CHANGEMAG\n");    
        this.nClog.dump("STEP,PID,NID,X,Y,Z,RANGE,REPULSE,SIZE,MASS,PERIM,COHX,COHY,COHZ,MAG,DIST\n");    
        this.nRlog.dump("STEP,PID,NID,X,Y,Z,RANGE,REPULSE,SIZE,MASS,PERIM,REPX,REPY,REPZ,MAG\n");  
      }
    }

// Random swarm or load current saved model
    if (boolean(modelProperties.getProperty("loadSwarm"))) {
      this.loadSwarm();
    } else {
      this.populate();
    }
    this.init();  
  }

  public double[][] getArray(String data) {
    double[][] result = new double[2][2];
    String[] vals = data.split(",");
    result[0][0] = Double.parseDouble(vals[0]);
    result[0][1] = Double.parseDouble(vals[1]);
    result[1][0] = Double.parseDouble(vals[2]);
    result[1][1] = Double.parseDouble(vals[3]);
    return result;
  }

  public boolean checkUsed(double x, double y) {
    for(Particle p : S) {      
      if (p._loc.x == x && p._loc.y == y) {
        return true;
      }
    }
    return false;
  }

  public PVectorD getCentroid() {
    PVectorD center = new PVectorD(0,0);
    for(Particle p : this.S) {
        center.add(p._loc);
    }    
    center.div(this.S.size());
    return center;
  }

  public void saveSwarm() {
/** 
* Save environment settings to JSON file.
* 
*/  
    int i = 0;
    JSONObject json = new JSONObject();
    JSONObject jsonParams = new JSONObject();
    JSONObject jsonInfo = new JSONObject();
    jsonInfo.put("date",LocalDate.now());
    jsonInfo.put("time",LocalTime.now());
    jsonInfo.put("by","PSywarm " + _VERSION);

    JSONArray jsonParamsKr = new JSONArray();
    JSONArray jsonParamsKrData = new JSONArray();

    JSONArray jsonParamsR = new JSONArray();
    JSONArray jsonParamsRData = new JSONArray();

    JSONArray jsonParamsKc = new JSONArray();
    JSONArray jsonParamsKcData = new JSONArray();

    JSONObject jsonAgents = new JSONObject();
//    JSONArray jsonAgentsProps = new JSONArray();
    JSONArray jsonAgentsCoords = new JSONArray();
    JSONArray jsonAgentsX = new JSONArray();
    JSONArray jsonAgentsY = new JSONArray();
    JSONArray jsonAgentsZ = new JSONArray();

    JSONObject jsonDestinations = new JSONObject();
//    JSONArray jsonDestinationsProps = new JSONArray();
    JSONArray jsonDestinationsCoords = new JSONArray();
    JSONArray jsonDestinationsX = new JSONArray();
    JSONArray jsonDestinationsY = new JSONArray();
    JSONArray jsonDestinationsZ = new JSONArray();

    JSONObject jsonObstacles = new JSONObject();
//    JSONArray jsonObstaclesProps = new JSONArray();
    JSONArray jsonObstaclesCoords = new JSONArray();
    JSONArray jsonObstaclesX = new JSONArray();
    JSONArray jsonObstaclesY = new JSONArray();
    JSONArray jsonObstaclesZ = new JSONArray();
    
    PrintWriter output;
    jsonParams.setDouble("kd",this._kd);
    jsonParams.setDouble("kg",this._kg);
    jsonParams.setBoolean("rgf",this._rgf);
    jsonParams.setDouble("cb",this._C);
    jsonParams.setDouble("speed",this._speed);
    jsonParams.setBoolean("perim_coord",this._perimCoord);
//  CROSS COMPATABILITY SETTINGS FOR PYTHON MODEL
    jsonParams.setString("scaling","linear");
    jsonParams.setDouble("stability_factor", this._stability_factor);
    jsonParams.setDouble("exp_rate", 0.2);

    jsonParamsKrData.setDouble(0,this._kr[0][0]);
    jsonParamsKrData.setDouble(1,this._kr[0][1]);
    jsonParamsKr.setJSONArray(0,jsonParamsKrData);
    jsonParamsKrData = new JSONArray();
    jsonParamsKrData.setDouble(0,this._kr[1][0]);
    jsonParamsKrData.setDouble(1,this._kr[1][1]);
    jsonParamsKr.setJSONArray(1,jsonParamsKrData);
    jsonParams.put("kr",jsonParamsKr);

    jsonParamsKcData.setDouble(0,this._kc[0][0]);
    jsonParamsKcData.setDouble(1,this._kc[0][1]);
    jsonParamsKc.setJSONArray(0,jsonParamsKcData);
    jsonParamsKcData = new JSONArray();
    jsonParamsKcData.setDouble(0,this._kc[1][0]);
    jsonParamsKcData.setDouble(1,this._kc[1][1]);
    jsonParamsKc.setJSONArray(1,jsonParamsKcData);
    jsonParams.put("kc",jsonParamsKc);

    jsonParamsRData.setDouble(0,this._R[0][0]);
    jsonParamsRData.setDouble(1,this._R[0][1]);
    jsonParamsR.setJSONArray(0,jsonParamsRData);
    jsonParamsRData = new JSONArray();
    jsonParamsRData.setDouble(0,this._R[1][0]);
    jsonParamsRData.setDouble(1,this._R[1][1]);
    jsonParamsR.setJSONArray(1,jsonParamsRData);
    jsonParams.put("rb",jsonParamsR);

    i = 0;
    for(Particle p : S) {
//      jsonAgentsProps.setJSONObject(i,p.getJSONProps());
      jsonAgentsX.setDouble(i,p._loc.x);
      jsonAgentsY.setDouble(i,p._loc.y);
      jsonAgentsZ.setDouble(i,p._loc.z);
      i++;
    }
    
    jsonAgentsCoords.setJSONArray(0,jsonAgentsX);
    jsonAgentsCoords.setJSONArray(1,jsonAgentsY);
    jsonAgentsCoords.setJSONArray(2,jsonAgentsZ);

    jsonAgents.put("coords",jsonAgentsCoords);
//    jsonAgents.put("props",jsonAgentsProps);

     i = 0;
    for(Obstacle o : this.O) {
//      jsonObstaclesProps.setJSONObject(i,o.getJSONProps());
      jsonObstaclesX.setDouble(i,o._loc.x);
      jsonObstaclesY.setDouble(i,o._loc.y);
      jsonObstaclesZ.setDouble(i,o._loc.z);
      i++;
    } 

    jsonObstaclesCoords.setJSONArray(0,jsonObstaclesX);
    jsonObstaclesCoords.setJSONArray(1,jsonObstaclesY);
    jsonObstaclesCoords.setJSONArray(2,jsonObstaclesZ);

    jsonObstacles.put("coords",jsonObstaclesCoords);
//    jsonObstacles.put("props",jsonObstaclesProps);
    i = 0;
    for(Destination d : D) {
//      jsonDestinationsProps.setJSONObject(i,d.getJSONProps());
      jsonDestinationsX.setDouble(i,d._loc.x);
      jsonDestinationsY.setDouble(i,d._loc.y);
      jsonDestinationsZ.setDouble(i,d._loc.z);
      i++;
    }        

    jsonDestinationsCoords.setJSONArray(0,jsonDestinationsX);
    jsonDestinationsCoords.setJSONArray(1,jsonDestinationsY);
    jsonDestinationsCoords.setJSONArray(2,jsonDestinationsZ);

    jsonDestinations.put("coords",jsonDestinationsCoords);
//    jsonDestinations.put("props",jsonDestinationsProps);
    json.put("obstacles",jsonObstacles);
    json.put("destinations",jsonDestinations);
    json.put("agents",jsonAgents);
    json.put("params",jsonParams);
    json.put("info",jsonInfo);
    saveJSONObject(json, "data/json/" + modelProperties.getProperty("swarmName"));
  }

  public void loadSwarm(String file) {
    JSONObject json = loadJSONObject("data/json/" + file);
    load(json);  
  }

  public void loadSwarm() {
    JSONObject json = loadJSONObject("data/json/" + modelProperties.getProperty("swarmName"));
    load(json);  
  }

  public void load(JSONObject json) {
/** 
* Load environment settings from JSON file.
*
*/
    JSONObject params = json.getJSONObject("params");
    JSONArray kr = json.getJSONObject("params").getJSONArray("kr");
    for(int x = 0; x < 2 ; x++) {
      for(int y = 0; y < 2; y++) {
        this._kr[x][y] = kr.getJSONArray(x).getDouble(y);
      }
    }

    JSONArray kc = json.getJSONObject("params").getJSONArray("kc");
    for(int x = 0; x < 2 ; x++) {
      for(int y = 0; y < 2; y++) {
        this._kc[x][y] = kc.getJSONArray(x).getDouble(y);
      }
    }

    JSONArray R = json.getJSONObject("params").getJSONArray("rb");
    for(int x = 0; x < 2 ; x++) {
      for(int y = 0; y < 2; y++) {
        this._R[x][y] = R.getJSONArray(x).getDouble(y);
      }
    }
    this._C = params.getDouble("cb");
    this._kd = params.getDouble("kd");
    this._kg = params.getDouble("kg");
    this._rgf = params.getBoolean("rgf");
    this._speed = params.getDouble("speed");
    this._stability_factor = params.getDouble("stability_factor");
    this._perimCoord = params.getBoolean("perim_coord");
    this.S.clear();

// Commented JSON components to created reduced data set. These might be resurrected later.
//    JSONArray props = json.getJSONObject("agents").getJSONArray("props");
    JSONArray coords = json.getJSONObject("agents").getJSONArray("coords");

    for (int i = 0; i < coords.getJSONArray(0).size(); i++) {
//      JSONObject p = props.getJSONObject(i);
      JSONArray x = coords.getJSONArray(0);
      JSONArray y = coords.getJSONArray(1);
      JSONArray z = coords.getJSONArray(2);
      try {
        S.add(new Particle(i, (double)x.getDouble(i), (double)y.getDouble(i), (double)z.getDouble(i), this._speed));
        this._nextParticleId = i + 1;
      } catch (Exception e) {
        println(e);
        exit();
      }
    }

//    props = json.getJSONObject("destinations").getJSONArray("props");
    coords = json.getJSONObject("destinations").getJSONArray("coords");

    for (int i = 0; i < coords.getJSONArray(0).size(); i++) {
//      JSONObject d = props.getJSONObject(i);
      JSONArray x = coords.getJSONArray(0);
      JSONArray y = coords.getJSONArray(1);
      JSONArray z = coords.getJSONArray(2);

      Destination dest = new Destination(i, (double)x.getDouble(i), (double)y.getDouble(i), (double)z.getDouble(i));
      D.add(dest);
      this._nextDestId = i + 1;
      for(Particle p : S) {
        p.addDestination(dest);
      }
    }

//    props = json.getJSONObject("obstacles").getJSONArray("props");
    coords = json.getJSONObject("obstacles").getJSONArray("coords");

    for (int i = 0; i < coords.getJSONArray(0).size(); i++) {
//      JSONObject o = props.getJSONObject(i);
      JSONArray x = coords.getJSONArray(0);
      JSONArray y = coords.getJSONArray(1);
      JSONArray z = coords.getJSONArray(2);
      this.O.add(new Obstacle(i, (double)x.getDouble(i), (double)y.getDouble(i), (double)z.getDouble(i), this._Ob));
      this._nextObsId = i + 1;
    }
// Initialise the swarm based on current model requirements.    
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
  
  public PVectorD avoidObstacles(Particle p) {
/** 
* obstacle avoidance calculation - Calculates the repulsion
* 
* @param p The particle that is currently being checked
*/
    PVectorD result = new PVectorD(0,0,0);
// GET ALL THE IN RANGE OBSTACLES
    for(Obstacle o : this.O) {
      if (pvectorDFactory.dist(p._loc,o._loc) <= o._Ob) {
         result.add(pvectorDFactory.sub(o._loc,p._loc));
      }
    }
    result.add(calcLineRepulsion(p));
    return result.mult(-_ko);
  }

  public PVectorD calcLineRepulsion(Particle p) {
    PVectorD result = new PVectorD(0,0,0);
    if (system.O.size() > 1 && this._obstacleLink) {
      for (int i = 1; i < this.O.size(); i++) {
        double x0 = p._loc.x;
        double y0 = p._loc.y;
        double x1 = this.O.get(i)._loc.x;
        double y1 = this.O.get(i)._loc.y;
        double x2 = this.O.get(i-1)._loc.x;
        double y2 = this.O.get(i-1)._loc.y;
        double dir = ((x2-x1) * (y1-y0)) - ((x1-x0) * (y2-y1)); // above or below line segment
        double distance = distBetweenPointAndLine(x0,y0,x1,y1,x2,y2);
        ArrayList<PVectorD> polygon = new ArrayList<PVectorD>();

        PVectorD start = system.O.get(i)._loc;
        PVectorD end = system.O.get(i-1)._loc;
        PVectorD d = pvectorDFactory.sub(end,start);
        d.rotate(Math.PI/2).setMag(system._Ob); 
        polygon.add(pvectorDFactory.add(start,d));
        polygon.add(pvectorDFactory.add(end,d));
        polygon.add(pvectorDFactory.sub(end,d));
        polygon.add(pvectorDFactory.sub(start,d));
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

  public double distBetweenPointAndLine(double x, double y, double x1, double y1, double x2, double y2) {
    // A - the standalone point (x, y)
    // B - start point of the line segment (x1, y1)
    // C - end point of the line segment (x2, y2)
    // D - the crossing point between line from A to BC
    double AB = distBetween(x, y, x1, y1);
    double BC = distBetween(x1, y1, x2, y2);
    double AC = distBetween(x, y, x2, y2);

    // Heron's formula
    double AD;
    double s = (AB + BC + AC) / 2;
    double area = (double) Math.sqrt(s * (s - AB) * (s - BC) * (s - AC));
    AD = (2 * area) / BC;
    return AD;
  }

  public double distBetween(double x, double y, double x1, double y1) {
    double xx = x1 - x;
    double yy = y1 - y;
    return (double) Math.sqrt(xx * xx + yy * yy);
  }

  public boolean pointInRectangle(PVectorD p, ArrayList<PVectorD> polygon) {
    boolean isInside = false;
    for (int i = 0, j = polygon.size() - 1; i < polygon.size(); j = i++) {
        if ( (polygon.get(i).y > p.y) != (polygon.get(j).y > p.y) &&
                p.x < (polygon.get(j).x - polygon.get(i).x) * (p.y - polygon.get(i).y) / (polygon.get(j).y - polygon.get(i).y) + polygon.get(i).x ) {
            isInside = !isInside;
        }
    }
    return isInside;
  }

  public void addDestination(double x, double y, double z) {
/** 
* Add Destination in 3D
* 
* @param x X Position
* @param y Y Position
* @param z Z Position
*/
    Destination d = new Destination(_nextDestId++,(double)x,(double)y,(double)z);
    this.D.add(d);
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
    for (int i = this.D.size() - 1; i >= 0; i--) {
      Destination dest = this.D.get(i);
      if (d == dest) {
        for(Particle p : S) {
          p.removeDestination(d);
        }
        this.D.remove(i);
      }
    }
  }

  public void addParticle(double x, double y, double z) {
/** 
* Add Particle/Agent in 3D
* 
* @param x X Position
* @param y Y Position
* @param z Z Position
*/
    try {
      // create agent in centred quartile.
      Particle p = new Particle(this._nextParticleId++, (double)x, (double)y, (double)z, 10.0, 1.0, this._speed);
      p.setDestinations(this.D);
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
    for (int i = this.O.size() - 1; i >= 0; i--) {
      Obstacle obs = this.O.get(i);
      if (obs == o) {
        this.O.remove(i);
      }
    }
  }

  public void addObstacle(double x, double y, double z) {
/** 
* Add Destination in 3D
* 
* @param x X Position
* @param y Y Position
* @param z Z Position
*/
    this.O.add(new Obstacle(_nextObsId++,(double)x,(double)y,(double)z,this._Ob));
  }

  public boolean hasObstacles() {
    return (this.O.size() > 0);
  }
}
