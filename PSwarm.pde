/**************************************************
 * PSwarm
 **************************************************
 * AUTHOR: Dr. Neil Eliot 
 * See history.txt
 ***************************************************************************
 *   This program is free software: you can redistribute it and/or modify
 *   it under the terms of the GNU General Public License as published by
 *   the Free Software Foundation, either version 3 of the License, or
 *   (at your option) any later version.

 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details.
 *
 *   You should have received a copy of the GNU General Public License
 *   along with this program.  If not, see <https://www.gnu.org/licenses/>.
 ****************************************************************************/
java.util.Properties properties;
java.util.Properties modelProperties;
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
String _VERSION = "0.1.3";
float _scale = 1f; // Scaling factor
int _offsetX = 0; // Swarm display offsetX
int _offsetY = 0; // Swarm display offsetY
boolean _logo = true;
boolean _dest = false; // Enable/diable destination seeking
boolean _run = false; // Enable/disable update calculations
boolean _displayId = false; // Display Y/N
boolean _particleTicks = true; // Display Y/N
boolean _perimCoord = false; // Enable/disable only using perimeter particles for coordination to destination
boolean _lines = true; // Display Y/N
boolean _grid = true; // Display Y/N
boolean _displayDestinations = true; // Display Y/N
boolean _perimCompress = false; // Compress the perimeter Y/N
boolean _usePoint = false;
boolean _loadSwarm = false;
int _swarmSize = 0;
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
String[] _modes = {"Agent (L-Add R-Remove)","Destination (L-Add R-Remove)","Obstacle (L-Add R-Remove)","Window (L-Grab R-Minimise)"};
InfoBox menuInfo1 = new InfoBox(2,2,340,375,25,theme.menuTheme[theme._theme][0],theme.menuTheme[theme._theme][1],theme.menuTheme[theme._theme][2],"MENU");
InfoBox menuInfo2 = new InfoBox(344,2,350,127,25,theme.menuTheme[theme._theme][0],theme.menuTheme[theme._theme][1],theme.menuTheme[theme._theme][2],"MENU");
InfoBox directionInfo = new InfoBox(345,2,78,78,25,theme.menuTheme[theme._theme][0],theme.menuTheme[theme._theme][1],theme.menuTheme[theme._theme][2],"Direction");

InfoBox destinationInfo = new InfoBox(0,0,340,78,25,theme.boxTheme[theme._theme][0],theme.boxTheme[theme._theme][1],theme.boxTheme[theme._theme][2],"Destination",true);
InfoBox agentInfo = new InfoBox(0,0,340,160,25,theme.boxTheme[theme._theme][3],theme.boxTheme[theme._theme][4],theme.boxTheme[theme._theme][5],"Agent",true);
InfoBox obstacleInfo = new InfoBox(0,0,340,103,25,theme.boxTheme[theme._theme][6],theme.boxTheme[theme._theme][7],theme.boxTheme[theme._theme][8],"Obstacle",true);

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

void setup() {
/** 
* Sets up frame rate and the initial swarm
* 
*/
  properties = new java.util.Properties();
  modelProperties = new java.util.Properties();
  try {
    properties.load( createReader("application.properties") );
    _model = int(properties.getProperty("model"));
    modelProperties.load( createReader("Model"+_model+".properties") );
  } catch(Exception e) {
    
  }

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

  if (_model == 1) {
    system = new Model1(); 
  } else if (_model == 2) {
    system = new Model2(); 
  } else if (_model == 3) {
    system = new Model3(); 
  } else if (_model == 4) {
    system = new Model4(); 
  } else if (_model == 5) {
    system = new Model5(); 
  } else {
    system = new Model6(); 
  }

  _swarmSize = int(modelProperties.getProperty("size"));
  system._particleRange = float(modelProperties.getProperty("particleRange"));
  system._particleRepulse = float(modelProperties.getProperty("particleRepulse"));
  system._repulsionBias = float(modelProperties.getProperty("repulsionBias"));
  system._cohesionBias = float(modelProperties.getProperty("cohesionBias"));
  system._directionBias = float(modelProperties.getProperty("directionBias"));
  system._obstacleBias = float(modelProperties.getProperty("obstacleBias"));
  system._obstacleRange = float(modelProperties.getProperty("obstacleRange"));
  system._repulseProportion = float(modelProperties.getProperty("repulseProportion"));
  system._cohesionProportion = float(modelProperties.getProperty("cohesionProportion"));
  _dest = boolean(modelProperties.getProperty("dest"));
  _perimCoord = boolean(modelProperties.getProperty("perimCoord"));
  _loadSwarm = boolean(modelProperties.getProperty("loadSwarm"));
  system._loggingP = boolean(modelProperties.getProperty("loggingP"));
  system._loggingN = boolean(modelProperties.getProperty("loggingN"));
  
  
  directionInfo._visible = boolean(properties.getProperty("directionBox"));
  _run = boolean(properties.getProperty("run"));
  _displayId = boolean(properties.getProperty("displayId"));
  _particleTicks = boolean(properties.getProperty("particleTicks"));
  _lines = boolean(properties.getProperty("lines"));
  _grid = boolean(properties.getProperty("grid"));
  _displayDestinations = boolean(properties.getProperty("displayDestinations"));

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
    text("V:" + _VERSION + " - " + system._model, (width - logo.width)/2, ((height - logo.height)/2) - 5);
    return;
  } else {
    background(theme.desktopTheme[theme._theme][0]);
  }
  if (_grid) displayGrid();
  if (_centroid) displayCentroid();
  system.update(_run, _dest, _perimCoord, _perimCompress);
  _displayParticleInfo = -1;
  _displayDestinationInfo = -1;
  _displayObstacleInfo = -1;
  _displayWindowInfo = null;
  if (_menu) { 
    generateMenu();
    generateDirectionInfo();
    for(InfoBox b : displayWindows) {
      if (b._visible) {
        b.draw();
        if (overWindow(b)) _displayWindowInfo = b;
      }
    }
  }
  if (_displayDestinations) {
    for (Destination d : system.destinations) {
      displayDestination(d);
      if (overDestination(transposeX(d._location.x),transposeY(d._location.y),10,10)) _displayDestinationInfo = d._id;
      if (_displayId) displayId(d);
    }
  }
  for (Obstacle o : system.obstacles) {
    displayObstacle(o);
    if (overObstacle(transposeX(o._location.x),transposeY(o._location.y),10,10)) _displayObstacleInfo = o._id;
    if (_displayId) displayId(o);
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
  if (mouseButton == RIGHT && _mode == _WINDOW && _displayWindowInfo != null) {
    _displayWindowInfo._minimised = !_displayWindowInfo._minimised;
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
  if (key == 'p') {_perimCoord = !_perimCoord;}  
  if (key == 'c') {_perimCompress = !_perimCompress;} 
  if (key == 'g') {_grid = !_grid;}
  if (key == 'l') {_lines = !_lines;} 
  if (key == 'i') {_displayId = !_displayId;}
  if (key == 't') {_particleTicks = !_particleTicks;}
  if (key == 'x') {_centroid = !_centroid;}
  if (key == 'z') {_displayDestinations = !_displayDestinations;}
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
  menuInfo1.add("(SPACE) Destinations Active: " + _dest);
  menuInfo1.add("(z) Display Destinations: " + _displayDestinations);
  menuInfo1.add("(r) Run: " + _run);
  menuInfo1.add("(i) Display Ids: " + _displayId);
  menuInfo1.add("(g) Display Grid: " + _grid);
  menuInfo1.add("(l) Display Link Lines: " + _lines);
  menuInfo1.add("(t) Display particle ticks: " + _particleTicks);
  menuInfo1.add("(x) Display centroid: " + _centroid);
  menuInfo1.add("(p) Perimeter Coordination: " + _perimCoord);
  menuInfo1.add("(c) Perimeter Compress: " + _perimCompress);
  menuInfo1.add("(a) <-20% (s) 100% (d) 500%-> : "+ _scale);
  menuInfo1.add("(h) X:" + _offsetX + " (k) - Y:(u) " + _offsetY + " (n) - (j) RESET - Offset");  
  menuInfo1.add("(q) -10 (w) +10 - Grid :" + _gridSize);  
  menuInfo1.add("(y) load (o) Save - Snapshot");
  menuInfo1.add("(m) MODE:" + _modes[_mode]);  
  menuInfo1.add("(1) Screen Grab");  
  menuInfo1.add("(ESC) EXIT");

  menuInfo2.setTitle(system._model + " (" + frameRate + ")");
  menuInfo2.setColour(theme.menuTheme[theme._theme][0],theme.menuTheme[theme._theme][1],theme.menuTheme[theme._theme][2]);
  menuInfo2.clearData();
  menuInfo2.add("Agents:" + system.particles.size() + " Destinations:" + system.destinations.size() + " Obstacles:" + system.obstacles.size());
  menuInfo2.add("==========================");  
  menuInfo2.add("Cohesion Range: " + system._particleRange);
  menuInfo2.add("Cohesion Bias: " + system._cohesionBias);
  menuInfo2.add("Repulsion Range: " + system._particleRepulse);
  menuInfo2.add("Repulsion Bias: " + system._repulsionBias);
  menuInfo2.add("Obstacle Range: " + system._obstacleRange);
  menuInfo2.add("Obstacle Bias: " + system._obstacleBias);
  menuInfo2.add("Direction Bias: " + system._directionBias);
  menuInfo2.add("==========================");  
  menuInfo2.add("Repulsion Proportion: " + system._repulseProportion);
  menuInfo2.add("Cohesion Proportion: " + system._cohesionProportion);
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
  fill(0, 0, 0,255);
  text(agent._id,transposeX(agent._location.x),transposeY(agent._location.y));
}

void displayId(Destination d) {
/** 
* Renders the particleId onto the canvas
* 
*/
  textSize(12);
  textAlign(CENTER,CENTER);
  fill(0, 0, 0,255);
  text(d._id,transposeX(d._location.x),transposeY(d._location.y));
}

void displayId(Obstacle o) {
/** 
* Renders the particleId onto the canvas
* 
*/
  textSize(12);
  textAlign(CENTER,CENTER);
  fill(255,255,255,255);
  text(o._id,transposeX(o._location.x),transposeY(o._location.y));
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
