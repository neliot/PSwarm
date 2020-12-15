/**************************************************
 * PSwarm
 **************************************************
 * AUTHOR: Dr. Neil Eliot 
 * See history.txt
 **************************************************/
PSystem system;
Theme theme = new Theme(); 
ArrayList<PImage> mice1 = new ArrayList<PImage>();
ArrayList<PImage> mice2 = new ArrayList<PImage>();
ArrayList<InfoBox> displayWindows = new ArrayList<InfoBox>();
PImage mouse;
PImage mouse1;
PImage mouse2;
PImage logo;
PImage license;
String _NAME = "PSwarm";
String _AUTHORS = "(c) 2020";
String _VERSION = "0.1.2";
float _scale = 1; // Scaling factor
int _offsetX = 0; // Swarm display offsetX
int _offsetY = 0; // Swarm display offsetY
boolean _logo = true;
boolean _dest = true; // Enable/diable destination seeking
boolean _run = false; // Enable/disable update calculations
boolean _displayId = false; // Display Y/N
boolean _particleTicks = true; // Display Y/N
boolean _perimCord = false; // Enable/disable only using perimeter particles for coordination to destination
boolean _lines = true; // Display Y/N
boolean _grid = true; // Display Y/N
boolean _perimCompress = false; // Compress the perimeter Y/N
boolean _usePoint = false;
boolean _loadSwarm = false;
int _gridSize = 40; // Size of canvas grid
int _lineSpacing = 25; // Line spacing of menu lines
int _displayParticleInfo = -1;
int _displayDestinationInfo = -1;
int _displayObstacleInfo = -1;
int _clickPosX = 0;
int _clickPosY = 0;
InfoBox _displayWindowInfo = null;
boolean _centroid = false;
boolean _menu = true;
int _model = 3;
int _mode = 0;
// MODES
int _AGENT = 0;
int _DESTINATION = 1;
int _OBSTACLE = 2;
int _WINDOW = 3;
//
String[] _modes = {"Agent (L-Add R-Remove)","Destination (L-Add R-Remove)","Obstacle (L-Add R-Remove)","Window (L-Grab)"};
InfoBox menuInfo1 = new InfoBox(2,2,340,375,25,theme.menuTheme[theme._theme][0],theme.menuTheme[theme._theme][1],theme.menuTheme[theme._theme][2],"MENU");
InfoBox menuInfo2 = new InfoBox(344,2,350,127,25,theme.menuTheme[theme._theme][0],theme.menuTheme[theme._theme][1],theme.menuTheme[theme._theme][2],"MENU");
InfoBox directionInfo = new InfoBox(345,2,78,78,25,theme.menuTheme[theme._theme][0],theme.menuTheme[theme._theme][1],theme.menuTheme[theme._theme][2],"Direction");

InfoBox destinationInfo = new InfoBox(0,0,340,78,25,theme.boxTheme[theme._theme][0],theme.boxTheme[theme._theme][1],theme.boxTheme[theme._theme][2],"Destination",true);
InfoBox agentInfo = new InfoBox(0,0,340,160,25,theme.boxTheme[theme._theme][3],theme.boxTheme[theme._theme][4],theme.boxTheme[theme._theme][5],"Agent",true);
InfoBox obstacleInfo = new InfoBox(0,0,340,103,25,theme.boxTheme[theme._theme][6],theme.boxTheme[theme._theme][7],theme.boxTheme[theme._theme][8],"Obstacle",true);

int _swarmSize = 100; // Number of agents.
//boolean _pLog = true; // Log data for analysis.

void settings() {
/** 
* Environment setup
*/ 
  if (platformNames[platform] == "linux") {
//    fullScreen(JAVA2D,SPAN);
    fullScreen(P2D,SPAN);
  } else {
    fullScreen(P2D);
//    fullScreen(P2D);
  }
  noSmooth();
}

void getModel() {
  String[] params = loadStrings("params.txt");
  if (params.length == 21 && params[0].substring(0,1).equals("Y")) {
    _model = int(split(params[19],' ')[0]);
  }
}

void getParams() {
/** 
* Parameter setup
*/ 
  String[] params = loadStrings("params.txt");
  if (params.length == 21 && params[0].substring(0,1).equals("Y")) {
    println("Using Parameter File");
    println("===================================");
    _swarmSize = int(split(params[1],' ')[0]);
    system._particleRange = float(split(params[2],' ')[0]); 
    system._particleRepulse = float(split(params[3],' ')[0]);
    system._repulsionBias = float(split(params[4],' ')[0]);
    system._cohesionBias = float(split(params[5],' ')[0]);
    system._directionBias = float(split(params[6],' ')[0]);
    system._obstacleBias = float(split(params[7],' ')[0]);
    system._obstacleRange = float(split(params[8],' ')[0]);
    system._repulseProportion = float(split(params[9],' ')[0]); // Compressed perimeter reduction divisor
    system._cohesionProportion = float(split(params[10],' ')[0]); // Compressed perimeter reduction divisor
    if (params[11].substring(0,1).equals("Y")) {system._loggingP = true;} else {system._loggingP = false;};
    if (params[12].substring(0,1).equals("Y")) {system._loggingN = true;} else {system._loggingN = false;};
    if (params[13].substring(0,1).equals("Y")) {_run = true;} else {_run = false;};
    if (params[14].substring(0,1).equals("Y")) {_displayId = true;} else {_displayId = false;}; // N         Display Id boolean _displayId = false; // Display Y/N
    if (params[15].substring(0,1).equals("Y")) {_particleTicks = true;} else {_particleTicks = false;}; //Y         Display Ticks boolean _particleTicks = true; // Display Y/N
    if (params[16].substring(0,1).equals("Y")) {_lines = true;} else {_lines = false;}; // Y         Lines boolean _lines = true; // Display Y/N
    if (params[17].substring(0,1).equals("Y")) {_grid = true;} else {_grid = false;}; //Y         Grid boolean _grid = true; // Display Y/N
    if (params[18].substring(0,1).equals("Y")) {_loadSwarm = true;} else {_loadSwarm=false;}; //Y         Load environment // Display Y/N

    println("Size:\t\t\t"+_swarmSize);
    println("Cohesion Range:\t\t"+ system._particleRange);
    println("Replusion Range:\t"+ system._particleRepulse);
    println("Repulsion Bias:\t\t"+ system._repulsionBias);
    println("Particle Logging:\t\t"+ system._loggingP);
    println("Neighbour Logging:\t\t"+ system._loggingN);
    println("Cohesion Bias:\t\t"+ system._cohesionBias);
    println("Direction Bias:\t\t"+ system._directionBias);
    println("Obstacle Bias:\t\t"+ system._obstacleBias);
    println("Obstacle Range:\t\t"+ system._obstacleRange);
    println("Perim R Prop:\t\t"+ system._repulseProportion);
    println("Perim C Prop:\t\t"+ system._cohesionProportion);
    println("===================================");
  } else {
    println("Not using Parameter File");
  }
}

void setup() {
/** 
* Sets up frame rate and the initial swarm
* 
*/
  frameRate(30);
  logo = loadImage("icons/logo" + (int(random(6))+ 1) + ".png");
  license = loadImage("icons/license.png");    
  mice1.add(loadImage("icons/1.png"));    
  mice2.add(loadImage("icons/2.png"));    
  mice1.add(loadImage("icons/3.png"));    
  mice2.add(loadImage("icons/4.png"));    
  mice1.add(loadImage("icons/5.png"));    
  mice2.add(loadImage("icons/6.png"));    
  mice1.add(loadImage("icons/7.png"));    
  mice2.add(loadImage("icons/8.png"));    
  mouse1 = mice1.get(_mode);
  mouse2 = mice2.get(_mode);
  mouse = mouse1;
  getModel();
  if (_model == 1) {
    system = new Model1(); 
  } else if (_model == 2) {
    system = new Model2(); 
  } else {
    system = new Model3(); 
  }
  getParams();

  if (_loadSwarm) {
    system.loadSwarm();
  } else {
    system.populate(_swarmSize);
  }

  directionInfo.setPos(width,2);
  displayWindows.add(menuInfo1);
  displayWindows.add(menuInfo2);
  displayWindows.add(directionInfo);
  background(theme.desktopTheme[theme._theme][0]);
}

void draw() {
/** 
* Render the application
*/ 
  if (millis() < 5000) {
    background(0);
    image(logo, (width - logo.width)/2, (height - logo.height)/2);
    textSize(24);
    text("Version: " + _VERSION + " (" + system._model + ")", (width - logo.width)/2, ((height - logo.height)/2) - 5);
    return;
  } else {
    background(theme.desktopTheme[theme._theme][0]);
  }
  if (_grid) displayGrid();
  if (_centroid) displayCentroid();
  system.update(_run, _dest, _perimCord, _perimCompress);
  _displayParticleInfo = -1;
  _displayDestinationInfo = -1;
  _displayObstacleInfo = -1;
  _displayWindowInfo = null;
  if (_menu) { 
    generateMenu();
    generateDirectionInfo();
    for(InfoBox b : displayWindows) {
      b.draw();
      if (overWindow(b)) _displayWindowInfo = b;
    }
  }
  for (Destination d : system.destinations) {
    displayDestination(d);
    if (overDestination(transposeX(d._location.x),transposeY(d._location.y),10,10)) _displayDestinationInfo = d._id;
  }
  for (Obstacle o : system.obstacles) {
    displayObstacle(o);
    if (overObstacle(transposeX(o._location.x),transposeY(o._location.y),10,10)) _displayObstacleInfo = o._id;
  }  
  if (_lines) displayLines();
  for(Particle p : system.particles) {
    displayParticle(p);
    if (overAgent(transposeX(p._location.x),transposeY(p._location.y),10,10)) _displayParticleInfo = p._id;
    if (_particleTicks) displayTick(p);
    if (_displayId) displayId(p);
  }
  if (_displayParticleInfo != -1 && _mode == _AGENT) { displayAgentInfo(system.getParticleWithId(_displayParticleInfo)); agentInfo.draw();};
  if (_displayDestinationInfo != -1 && _mode == _DESTINATION) { displayDestinationInfo(system.getDestinationWithId(_displayDestinationInfo)); destinationInfo.draw();};
  if (_displayObstacleInfo != -1 && _mode == _OBSTACLE) { displayObstacleInfo(system.getObstacleWithId(_displayObstacleInfo)); obstacleInfo.draw();};
  if (_run) system.moveReset();
  fill(0);
  textSize(10);
  text(_AUTHORS, 10, height-25);
  noCursor();
  image(mouse,mouseX-10,mouseY-10,32,32);
  image(license,width-88,height-31,88,31);
  if (keyPressed) {
    scalers();
  }
}

void mousePressed() {
  mouse = mouse2;
  if (mouseButton == LEFT && _mode == _DESTINATION) {
    system.addDestination(rTransposeX(mouseX),rTransposeY(mouseY),0);
  }
  if (mouseButton == RIGHT && _mode == _DESTINATION && _displayDestinationInfo != -1) {
    system.deleteDestinationById(_displayDestinationInfo);
  }
  if (mouseButton == LEFT && _mode == _AGENT) {
    system.addParticle(rTransposeX(mouseX),rTransposeY(mouseY),0);
  }  
  if (mouseButton == RIGHT && _mode == _AGENT && _displayParticleInfo != -1) {
    system.deleteParticleById(_displayParticleInfo);
  }  
  if (mouseButton == LEFT && _mode == _OBSTACLE) {
    system.addObstacle(rTransposeX(mouseX),rTransposeY(mouseY),0);
  }  
  if (mouseButton == RIGHT && _mode == _OBSTACLE && _displayObstacleInfo != -1) {
    system.deleteObstacleById(_displayObstacleInfo);
  }
  if (mouseButton == LEFT && _mode == _WINDOW && _displayWindowInfo != null) {
    _clickPosX = _displayWindowInfo._posX - mouseX;
    _clickPosY = _displayWindowInfo._posY - mouseY;
  }  
  
}

void mouseReleased() {
  mouse = mouse1;
}

void mouseDragged() {
  if (mouseButton == LEFT && _mode == _WINDOW && _displayWindowInfo != null) {
    _displayWindowInfo.setPos(mouseX + _clickPosX, mouseY + _clickPosY);
  }  
}

void keyPressed() {
/** 
* Menu selection
*/ 
  if (key == 'o') {
    system.saveSwarm();
    print("Swarm Saved");
  }
  if (key == 'y') {
    system.loadSwarm();
    print("Swarm Loaded");
  }
  // Menu 
  if (key == '?') {_menu = !_menu;}
  if (key == 'r') {_run = !_run;}
  if (key == ' ') {_dest = !_dest;}
  if (key == 'q') {if (_gridSize > 10) _gridSize -= 10;}
  if (key == 'w') {if (_gridSize < 100) _gridSize += 10;}
  // if (key == 'h') {if (_offsetX >= -10000) _offsetX -= 2;}
  // if (key == 'k') {if (_offsetX <= (width + 10000)) _offsetX += 2;}
  // if (key == 'u') {if (_offsetY >= -10000) _offsetY -= 2;}
  // if (key == 'n') {if (_offsetY <= (height + 10000)) _offsetY += 2;}
  // if (key == 'j') {_offsetX = 0; _offsetY = 0;}
  // if (key == 'a') {if (_scale >= 0.2) _scale -= 0.1;}
  // if (key == 's') {_scale = 1;}
  // if (key == 'd') {if (_scale <= 5.0) _scale += 0.1;}
  if (key == 'p') {_perimCord = !_perimCord;}  
  if (key == 'c') {_perimCompress = !_perimCompress;} 
  if (key == 'g') {_grid = !_grid;}
  if (key == 'l') {_lines = !_lines;} 
  if (key == 'i') {_displayId = !_displayId;}
  if (key == 't') {_particleTicks = !_particleTicks;}
  if (key == 'x') {_centroid = !_centroid;}
  if (key == '1') {saveFrame("screen.png");}
  if (key == 'm') {
    _mode += 1;
    if (_mode > 3) {
      _mode = 0;
    } 
    mouse1 = mice1.get(_mode);  
    mouse2 = mice2.get(_mode);
    mouse = mouse1;
  }
 if (key == '0') {
    theme._theme += 1;
    if (theme._theme > 1) {
      theme._theme = 0;
    } 
  } 
}

void scalers() {
  if (key == 'h') {if (_offsetX >= -10000) _offsetX -= 15;}
  if (key == 'k') {if (_offsetX <= (width + 10000)) _offsetX += 15;}
  if (key == 'u') {if (_offsetY >= -10000) _offsetY -= 15;}
  if (key == 'n') {if (_offsetY <= (height + 10000)) _offsetY += 15;}
  if (key == 'j') {_offsetX = 0; _offsetY = 0;}
  if (key == 'a') {if (_scale >= 0.2) _scale -= 0.01;}
  if (key == 's') {_scale = 1;}
  if (key == 'd') {if (_scale <= 5.0) _scale += 0.01;}
}

void generateMenu() {
/** 
* Generate menu
*/ 
  if (system._loggingP) {
    menuInfo1.setTitle("Menu - " + theme._themeName[theme._theme] + " (LOGGING)");
  } else {
    menuInfo1.setTitle("Menu - " + theme._themeName[theme._theme]);
  }
  menuInfo1.setColour(theme.menuTheme[theme._theme][0],theme.menuTheme[theme._theme][1],theme.menuTheme[theme._theme][2]);
  menuInfo1.clearData();
  menuInfo1.add("(SPACE) Destination:" + _dest);
  menuInfo1.add("(r) Run:" + _run);
  menuInfo1.add("(i) Display Ids:" + _displayId);
  menuInfo1.add("(g) Display Grid:" + _grid);
  menuInfo1.add("(l) Display Link Lines:" + _lines);
  menuInfo1.add("(t) Display particle ticks:" + _particleTicks);
  menuInfo1.add("(x) Display centroid:" + _centroid);
  menuInfo1.add("(p) Perimeter Coordination:" + _perimCord);
  menuInfo1.add("(c) Perimeter Compress:" + _perimCompress);
  menuInfo1.add("(q) -10 Grid [10-100]");  
  menuInfo1.add("(w) +10 Grid [10-100]");  
  menuInfo1.add("(y) load (o) Save - Snapshot");
  menuInfo1.add("(1) Screen Grab");  
  menuInfo1.add("(ESC) EXIT");
  //if (_pLog) {menuInfo1.setFill(color(200,0,50,20));} else {menuInfo1.setFill(color(0,0,100,20));}

  menuInfo2.setTitle(system._model + " Model ("+frameRate+")");
  menuInfo2.setColour(theme.menuTheme[theme._theme][0],theme.menuTheme[theme._theme][1],theme.menuTheme[theme._theme][2]);
  menuInfo2.clearData();
  menuInfo2.add("Agents:" + system.particles.size() + " Destinations:" + system.destinations.size() + " Obstacles:" + system.obstacles.size());
  menuInfo2.add("(m) MODE:" + _modes[_mode]);  
  menuInfo2.add("Scale (a) <-20% (s) 100% (d) 500%->");
  menuInfo2.add("Offset X:(h) " + _offsetX + " (k) - Y:(u) " + _offsetY + " (n) - (j) RESET ");  
  //if (_pLog) {menuInfo2.setFill(color(200,0,50,20));} else {menuInfo2.setFill(color(0,0,100,20));}
}

void generateDirectionInfo() {
  directionInfo.setGraphic(swarmDirectionImage()); 
  directionInfo.setColour(theme.menuTheme[theme._theme][0],theme.menuTheme[theme._theme][1],theme.menuTheme[theme._theme][2]);
}

void displayAgentInfo(Particle agent) {
  agentInfo.setTitle("ID:" + agent._id + " [X:" + String.format("%.2f",agent._location.x) + ", Y:"+ String.format("%.2f",agent._location.y) +"]");
  agentInfo.setColour(theme.boxTheme[theme._theme][3],theme.boxTheme[theme._theme][4],theme.boxTheme[theme._theme][5]);
  agentInfo.clearData();
  agentInfo.add("Perim: ["+ agent._isPerimeter +"]");
  agentInfo.add("Mass: ["+ agent._mass +"]");
  agentInfo.add("R Range: ["+ agent._repulse +"]");
  agentInfo.add("Speed: ["+ agent._topspeed +"]");
  agentInfo.add("Size: ["+ agent._size +"]");
}

void displayDestinationInfo(Destination dest) {
  destinationInfo.setTitle("ID:" + dest._id + " [X:" + String.format("%.2f",dest._location.x) + ", Y:"+ String.format("%.2f",dest._location.y) +"]");
  destinationInfo.setColour(theme.boxTheme[theme._theme][0],theme.boxTheme[theme._theme][1],theme.boxTheme[theme._theme][2]);
  destinationInfo.clearData();
  destinationInfo.add("Size: ["+ dest._size +"]");
  destinationInfo.add("Mass: ["+ dest._mass +"]");
}

void displayObstacleInfo(Obstacle o) {
  obstacleInfo.setTitle("ID:" + o._id + " [X:" + String.format("%.2f",o._location.x) + ", Y:"+ String.format("%.2f",o._location.y) +"]");
  obstacleInfo.setColour(theme.boxTheme[theme._theme][6],theme.boxTheme[theme._theme][7],theme.boxTheme[theme._theme][8]);
  obstacleInfo.clearData();
  obstacleInfo.add("Size: ["+ o._size +"]");
  obstacleInfo.add("Range: ["+ o._range +"]");
  obstacleInfo.add("Mass: ["+ o._mass +"]");
}

void displayCentroid() {
  float _size1 = 45;
  float _size2 = 30;
  float _size3 = 15;
  PVector center = system.getCentroid();
  float x = transposeX(center.x);
  float y = transposeY(center.y);
  noStroke();
  fill(0,0,100,100);
  ellipse(x,y,(_size1*_scale),(_size1*_scale));
  fill(0,100,0,100);
  ellipse(x,y,(_size2*_scale),(_size2*_scale));
  fill(100,0,0,200);
  ellipse(x,y,(_size3*_scale),(_size3*_scale));
 }

void displayGrid() {
/** 
* Display the grid
*/ 
  boolean alt = true;
  for(int x = 0; x < width; x = x + _gridSize) {
    if (alt) {
      strokeWeight(1);
      stroke(theme.desktopTheme[theme._theme][1]);
    } else {
      strokeWeight(1.5);
      stroke(theme.desktopTheme[theme._theme][2]);
    }
    alt = !alt;
    line(x,0,x,height);      
  }
  alt = true;
  for(int y = 0; y < height; y = y + _gridSize) {
    if (alt) {
      strokeWeight(1);
      stroke(theme.desktopTheme[theme._theme][1]);
    } else {
      strokeWeight(1.5);
      stroke(theme.desktopTheme[theme._theme][2]);
    }
    alt = !alt;
    line(0,y,width,y);      
  }
  strokeWeight(1);
}

void displayParticle(Particle p) {
/** 
* Renders the particle onto the canvas
* 
*/
    if (_usePoint) {
      point(transposeX(p._location.x),transposeY(p._location.y));
    } else {
      strokeWeight(1);
      stroke(theme.particleTheme[theme._theme][0]);
      if (p._isPerimeter) {
         fill(theme.particleTheme[theme._theme][1]);
      } else {
         fill(theme.particleTheme[theme._theme][2]);
      }
      ellipse(transposeX(p._location.x),transposeY(p._location.y),(p._size*p._mass*_scale),(p._size*p._mass*_scale));
    }
}

void displayDestination(Destination d) {
  strokeWeight(constrain(2*_scale,1,4));
  stroke(theme.destinationTheme[theme._theme][0]);
  fill(theme.destinationTheme[theme._theme][1]);
  ellipse(transposeX(d._location.x),transposeY(d._location.y),constrain(20*_scale,10,25),constrain(20*_scale,10,25));
}

void displayObstacle(Obstacle o) {
/** 
* Renders the obstacle onto the canvas
* 
*/
  strokeWeight(constrain(2*_scale,1,4));
  stroke(theme.obstacleTheme[theme._theme][0]);
  fill(theme.obstacleTheme[theme._theme][1]);
  ellipse(transposeX(o._location.x),transposeY(o._location.y),constrain(20*_scale,10,25),constrain(20*_scale,10,25));
  noFill();
  strokeWeight(1);
  stroke(theme.obstacleTheme[theme._theme][2]);
  ellipse(transposeX(o._location.x),transposeY(o._location.y), o._range * 2 * _scale, o._range * 2 * _scale);
}

PImage swarmDirectionImage() {
    int sizeXY = 150;
    PVector lineStart = new PVector(sizeXY/2,sizeXY/2); 
    PVector lineEnd = system._swarmDirection.copy();
    String out;
    float adjust;
    lineEnd.setMag((sizeXY/2) - 5);
    lineEnd.add(lineStart);
    PGraphics myImage = createGraphics(sizeXY,sizeXY, JAVA2D);
    myImage.beginDraw();
    myImage.background(0,0);
    myImage.fill(180,150);
    myImage.stroke(0);
    myImage.circle(sizeXY/2,sizeXY/2,sizeXY-4);
    myImage.strokeWeight(5);
    myImage.stroke(0);
    myImage.fill(0);
    myImage.line(lineStart.x,lineStart.y,lineEnd.x,lineEnd.y);
    myImage.strokeWeight(1);
    myImage.fill(200);
    myImage.circle(sizeXY/2,sizeXY/2,sizeXY-80);
    myImage.textAlign(CENTER, CENTER);
    myImage.fill(0);
    if (system._swarmDirection.mag() > 0) {adjust = 180;} else {adjust = 0;};
    out = String.format("%.2f\u00B0",degrees(atan2(system._swarmDirection.y,system._swarmDirection.x))+adjust);
    myImage.text(out,sizeXY/2,sizeXY/2);
    myImage.textAlign(RIGHT,BASELINE);
    myImage.endDraw();
    return myImage;
}

// void displayLines1() {
// /** 
// * Display cohesion lines.
// * Start and endpoints moved to particle borders 
// * Slower?
// */ 
//   for(Particle i : system.particles) {
//     for(Particle j : system.particles) {
//       if (PVector.dist(i._location,j._location) < i._range & i != j) {
// // Calculate start point
//         PVector atb = PVector.sub(i._location,j._location);
//         atb.normalize().setMag(i._mass * j._size/2);
//         PVector start = i._location.copy();
//         start.sub(atb);
// // Calculate end point  
//         PVector bta = PVector.sub(j._location,i._location);
//         bta.normalize().setMag(j._mass * j._size/2);
//         PVector end = j._location.copy();
//         end.sub(bta);
// // Enbolden perimeter lines
//         stroke(theme.lineTheme[theme._theme]);
//         if(i._isPerimeter && j._isPerimeter) {
//           strokeWeight(2);
//         } else {
//           strokeWeight(1);
//           stroke(100,100,100);
//         }
//         line(transposeX(start.x),transposeY(start.y),transposeX(end.x),transposeY(end.y));
//         strokeWeight(1);
//       }
//     }
//   }
// }

void displayLines() {
/** 
* Display cohesion lines.
* From centre to centre
* Faster?
*/ 
  for(Particle i : system.particles) {
    for(Particle j : system.particles) {
      if (PVector.dist(i._location,j._location) < i._range & i != j) {
// Calculate start point
        PVector atb = PVector.sub(i._location,j._location);
        PVector start = i._location.copy();
        start.sub(atb);
// Calculate end point  
        PVector bta = PVector.sub(j._location,i._location);
        PVector end = j._location.copy();
        end.sub(bta);
// Enbolden perimeter lines
        stroke(theme.lineTheme[theme._theme]);
        if(i._isPerimeter && j._isPerimeter) {
          strokeWeight(2);
        } else {
          strokeWeight(1);
          stroke(100,100,100);
        }
        line(transposeX(start.x),transposeY(start.y),transposeX(end.x),transposeY(end.y));
        strokeWeight(1);
      }
    }
  }
}

void displayId(Particle agent) {
/** 
* Renders the particleId onto the canvas
* 
*/
  textSize(12);
  textAlign(CENTER,CENTER);
  fill(0, 0, 0, 255);
  text(agent._id,transposeX(agent._location.x),transposeY(agent._location.y));
}

void displayTick(Particle agent) {
/** 
* Renders the particle's tick onto the canvas
* 
*/
  float _tickSize = 5.0;
  stroke(0);
  PVector tick = PVector.sub(agent._nextLocation,agent._location);
  tick.setMag((agent._mass * agent._size/2) + _tickSize);
  tick.add(agent._location);
  strokeWeight(2);
  line(transposeX(agent._location.x), transposeY(agent._location.y), transposeX(tick.x), transposeY(tick.y));
  strokeWeight(1);
}

float transposeX(float val) {
  val = val * _scale + _offsetX;
  return val;
}

float transposeY(float val) {
  val = val * _scale + _offsetY;
  return val;
}

float rTransposeX(float val) {
  val = val / _scale - _offsetX / _scale;
  return val;
}

float rTransposeY(float val) {
  val = val / _scale - _offsetY / _scale;
  return val;
}

PVector adjust(PVector location) {
  PVector _adjusted = new PVector((location.x / _scale), (location.y / _scale));
  return _adjusted;
};

boolean overWindow(InfoBox b) {
  if (mouseX >= b._posX && mouseX <= b._posX+b._width && 
      mouseY >= b._posY && mouseY <= b._posY+25) {
    return true;
  } else {
    return false;
  }
}

boolean overAgent(float x, float y, float w, float h) {
  if (mouseX >= x-w && mouseX <= x+w && 
      mouseY >= y-h && mouseY <= y+h) {
    return true;
  } else {
    return false;
  }
}

boolean overDestination(float x, float y, float w, float h) {
  if (mouseX >= x-w && mouseX <= x+w && 
      mouseY >= y-h && mouseY <= y+h) {
    return true;
  } else {
    return false;
  }
}

boolean overObstacle(float x, float y, float w, float h) {
  if (mouseX >= x-w && mouseX <= x+w && 
      mouseY >= y-h && mouseY <= y+h) {
    return true;
  } else {
    return false;
  }
}