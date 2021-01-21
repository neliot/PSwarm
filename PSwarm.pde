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
java.util.Properties properties = new java.util.Properties();
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
String _AUTHORS = "(c) 2021";
String _VERSION = "0.1.5";
float _scale = 1f; // Scaling factor
int _offsetX = 0; // Swarm display offsetX
int _offsetY = 0; // Swarm display offsetY
int _clickedOffsetX = 0; // Swarm display offsetX
int _clickedOffsetY = 0; // Swarm display offsetY
int _clickedMouseX = 0;
int _clickedMouseY = 0;
boolean _logo = true;
boolean _displayId = false; // Display Y/N
boolean _particleTicks = true; // Display Y/N
boolean _displayParticleFields = false; // Display Y/N
boolean _lines = true; // Display Y/N
boolean _grid = true; // Display Y/N
boolean _displayDestinations = true; // Display Y/N
boolean _usePoint = false;
boolean _loadSwarm = false;
int _swarmSize = 0;
int _gridSize = 40; // Size of canvas grid
int _lineSpacing = 25; // Line spacing of menu lines
Particle _currentParticle = null; 
Destination _currentDestination = null; 
Obstacle _currentObstacle = null; 
InfoBox _displayWindowInfo = null;
int _clickPosX = 0;
int _clickPosY = 0;
boolean _displayCentroid = false;
boolean _menu = true;
int _mode = 0;
// MODES
// Should be implemented with an enum but it's a bit messy in Java. Maybe later eh!
int _AGENT = 0;
int _DESTINATION = 1;
int _OBSTACLE = 2;
int _WINDOW = 3;
//
String[] _modes = {"Agent (L-Add R-Remove)","Destination (L-Add R-Remove)","Obstacle (L-Add R-Remove)","Window (L-Grab R-Minimise)"};
InfoBox menuInfo1 = new InfoBox(2,2,340,375,25,theme.menuTheme[theme._theme][0],theme.menuTheme[theme._theme][1],theme.menuTheme[theme._theme][2],"MENU");
InfoBox menuInfo2 = new InfoBox(344,2,350,127,25,theme.menuTheme[theme._theme][0],theme.menuTheme[theme._theme][1],theme.menuTheme[theme._theme][2],"MENU");
InfoBox directionInfo = new InfoBox(2,605,78,78,25,theme.menuTheme[theme._theme][0],theme.menuTheme[theme._theme][1],theme.menuTheme[theme._theme][2],"Direction");
InfoBox frameRateInfo = new InfoBox(2,800,95,78,25,theme.boxTheme[theme._theme][0],theme.boxTheme[theme._theme][1],theme.boxTheme[theme._theme][2],"Frame Rate");

InfoBox destinationInfo = new InfoBox(0,0,340,78,25,theme.boxTheme[theme._theme][0],theme.boxTheme[theme._theme][1],theme.boxTheme[theme._theme][2],"Destination",true);
InfoBox agentInfo = new InfoBox(0,0,340,160,25,theme.boxTheme[theme._theme][3],theme.boxTheme[theme._theme][4],theme.boxTheme[theme._theme][5],"Agent",true);
InfoBox obstacleInfo = new InfoBox(0,0,340,103,25,theme.boxTheme[theme._theme][6],theme.boxTheme[theme._theme][7],theme.boxTheme[theme._theme][8],"Obstacle",true);

void settings() {
/** 
* Environment setup
*/ 
  String renderer = P2D;
//  logo = loadImage("icons/logo" + (int(random(6))+ 1) + ".png");
  logo = loadImage("icons/logo6.png");
  try {
    properties.load( createReader("application.properties") );
  } catch(Exception e) {
    println(e);
    exit();
  }
  if (boolean(properties.getProperty("perspective"))) renderer=P3D;
  if (boolean(properties.getProperty("fullScreen"))) {
    fullScreen(renderer,int(properties.getProperty("screen")));
//    PJOGL.setIcon("icons/logo" + (int(random(6))+ 1) + ".png");
    PJOGL.setIcon("icons/logo6.png");
  } else {
    size(int(properties.getProperty("width")),int(properties.getProperty("height")),renderer);
  }
  if (boolean(properties.getProperty("antialias"))) {
    smooth(int(properties.getProperty("smoothFactor")));
  } else {
    noSmooth();
  }
}

void setup() {
/** 
* Sets up frame rate and the initial swarm
* 
*/
  frameRate(int(properties.getProperty("frameRate")));
  if (!boolean(properties.getProperty("fullScreen"))) {
    surface.setTitle(_NAME + " : " +_VERSION);
    surface.setResizable(boolean(properties.getProperty("scalable")));
    surface.setLocation(0, 0);
    surface.setIcon(logo);
  }
  noCursor();
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

  switch (int(properties.getProperty("model"))) {
    case 1:
      system = new Model1(); 
      break;
    case 2:
      system = new Model2(); 
      break;
    case 3:
      system = new Model3(); 
      break;
    case 4:
      system = new Model4(); 
      break;
    case 5:
      system = new Model5(); 
      break;
    case 6:
      system = new Model6(); 
      break;
    case 7:
      system = new Model7(); 
      break;
    default:
      system = new Model8(); 
  }
  
  directionInfo._visible = boolean(properties.getProperty("directionBox"));
  frameRateInfo._visible = boolean(properties.getProperty("frameRateBox"));
  _displayId = boolean(properties.getProperty("displayId"));
  _particleTicks = boolean(properties.getProperty("particleTicks"));
  _displayParticleFields = boolean(properties.getProperty("displayParticleFields"));
  _lines = boolean(properties.getProperty("lines"));
  _grid = boolean(properties.getProperty("grid"));
  _displayDestinations = boolean(properties.getProperty("displayDestinations"));
  _displayCentroid = boolean(properties.getProperty("displayCentroid"));
  _usePoint = boolean(properties.getProperty("usePoint"));

  displayWindows.add(menuInfo1);
  displayWindows.add(menuInfo2);
  displayWindows.add(directionInfo);
  displayWindows.add(frameRateInfo);
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
  if (boolean(properties.getProperty("perspective"))) {
    translate(height/2,width/2);
    rotateX(radians(float(properties.getProperty("angle"))));
    translate(-height/2,-width/2);
  }

  if (_grid) displayGrid();
  if (_displayCentroid) displayCentroid();
  system.update();
  _currentParticle = null;
  _currentDestination = null;
  _currentObstacle = null;
  _displayWindowInfo = null;
  if (_menu) { 
    generateMenu();
    generateDirectionInfo();
    generateFrameRateInfo();
    for(InfoBox b : displayWindows) {
      if (b._visible) {
        b.draw();
        if (mouseOver(b)) _displayWindowInfo = b;
      }
    }
  }
  if (_displayDestinations) {
    for (Destination d : system.destinations) {
      displayDestination(d);
      if (mouseOver(d)) _currentDestination = d;
    }
  }
  for (Obstacle o : system.obstacles) {
    displayObstacle(o);
    if (mouseOver(o)) _currentObstacle = o;
  }  
  if (_lines) displayLines();
  for(Particle p : system.particles) {
    displayParticle(p);
    if (mouseOver(p)) _currentParticle = p;
  }
  image(mouse,mouseX-10,mouseY-10,32,32);
  if (_currentParticle != null && _mode == _AGENT) displayAgentInfo(_currentParticle);
  if (_currentDestination != null && _mode == _DESTINATION) displayDestinationInfo(_currentDestination);
  if (_currentObstacle != null && _mode == _OBSTACLE) displayObstacleInfo(_currentObstacle);
  system.moveReset();
  fill(0);
  textSize(10);
  text(_AUTHORS, 10, height-25);
  image(license,width-88,height-31,88,31);
  if (keyPressed) {
    scalers();
  }
}

void mousePressed() {
  mouse = mouse2;
  if (mouseButton == LEFT && _mode == _DESTINATION && _currentDestination == null) {
    system.addDestination(tranX(mouseX),tranY(mouseY),0);
  }
  if (mouseButton == RIGHT && _mode == _DESTINATION && _currentDestination != null) {
    system.deleteDestination(_currentDestination);
  }
  if (mouseButton == LEFT && _mode == _AGENT && _currentParticle == null) {
    system.addParticle(tranX(mouseX),tranY(mouseY),0);
  }  
  if (mouseButton == RIGHT && _mode == _AGENT && _currentParticle != null) {
    system.deleteParticle(_currentParticle);
  }  
  if (mouseButton == LEFT && _mode == _OBSTACLE && _currentObstacle == null) {
    system.addObstacle(tranX(mouseX),tranY(mouseY),0);
  }  
  if (mouseButton == RIGHT && _mode == _OBSTACLE && _currentObstacle != null) {
    system.deleteObstacle(_currentObstacle);
  }
  if (mouseButton == LEFT && _mode == _WINDOW && _displayWindowInfo != null) {
    _clickPosX = _displayWindowInfo._posX - mouseX;
    _clickPosY = _displayWindowInfo._posY - mouseY;
  }  
  if (mouseButton == RIGHT && _mode == _WINDOW && _displayWindowInfo != null) {
    _displayWindowInfo._minimised = !_displayWindowInfo._minimised;
  }
  if (mouseButton == CENTER) {
    _clickedMouseX = mouseX;
    _clickedMouseY = mouseY;
    _clickedOffsetX = _offsetX;
    _clickedOffsetY = _offsetY;
  }  
}

void mouseReleased() {
  mouse = mouse1;
}

void mouseWheel(MouseEvent event) {
  float e = event.getCount();
  if (e > 0) {if (_scale >= 0.2) _scale -= 0.01;}
  if (e < 0) {if (_scale <= 5.0) _scale += 0.01;}
}

void mouseDragged() {
  if (mouseButton == LEFT && _mode == _AGENT && _currentParticle != null) {
    _currentParticle.setPos(tranX(mouseX),tranY(mouseY),0);
  }  
  if (mouseButton == LEFT && _mode == _WINDOW && _displayWindowInfo != null) {
    _displayWindowInfo.setPos(mouseX + _clickPosX, mouseY + _clickPosY);
  }  
  if (mouseButton == LEFT && _mode == _OBSTACLE && _currentObstacle != null) {
    _currentObstacle.setPos(tranX(mouseX),tranY(mouseY),0);
  }  
  if (mouseButton == LEFT && _mode == _DESTINATION && _currentDestination != null) {
    _currentDestination.setPos(tranX(mouseX),tranY(mouseY),0);
  }
  if (mouseButton == CENTER) {
    int moveX = mouseX - _clickedMouseX;
    int moveY = mouseY - _clickedMouseY;
    if(_offsetX + moveX >= -10000 && _offsetX + moveX <= 10000) _offsetX = _clickedOffsetX + moveX;
    if(_offsetY + moveY >= -10000 && _offsetY + moveY <= 10000) _offsetY = _clickedOffsetY + moveY;
  }
}

void keyPressed() {
/** 
* Menu selection
*/ 
  if (key == 'o') {saveSwarm();}
  if (key == 'y') {loadSwarm();}
  if (key == '?') {_menu = !_menu;}
  if (key == 'r') {system._run = !system._run;}
  if (key == ' ') {system._dest = !system._dest;}
  if (key == 'q') {if (_gridSize > 10) _gridSize -= 10;}
  if (key == 'w') {if (_gridSize < 100) _gridSize += 10;}
  if (key == 'p') {system._perimCoord = !system._perimCoord;}  
  if (key == 'c') {system._perimCompress = !system._perimCompress;} 
  if (key == 'g') {_grid = !_grid;}
  if (key == 'l') {_lines = !_lines;} 
  if (key == 'i') {_displayId = !_displayId;}
  if (key == 't') {_particleTicks = !_particleTicks;}
  if (key == 'x') {_displayCentroid = !_displayCentroid;}
  if (key == 'z') {_displayDestinations = !_displayDestinations;}
  if (key == '0') {_displayParticleFields = !_displayParticleFields;}
  if (key == '1') {screenGrab();}
  if (key == 'm') {changeMode();}
  if (key == '2') {changeTheme();} 
}

void changeMode(){
  _mode += 1;
  if (_mode > 3) {
    _mode = 0;
  } 
  mouse1 = mice1.get(_mode);  
  mouse2 = mice2.get(_mode);
  mouse = mouse1;
};

void changeTheme() {
  theme._theme += 1;
  if (theme._theme > 1) {
    theme._theme = 0;
  } 
}

void saveSwarm() {
  system.saveSwarm();
  println("Swarm Saved");
}

void loadSwarm() {
  system.loadSwarm();
  println("Swarm Loaded");
}

void screenGrab(){
  saveFrame("screen.png"); 
  println("Snapshot taken!");
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
    menuInfo1.setColour(theme.menuTheme[theme._theme][0],theme.menuTheme[theme._theme][3],theme.menuTheme[theme._theme][2]);
  } else {
    menuInfo1.setTitle("Menu - " + theme._themeName[theme._theme]);
    menuInfo1.setColour(theme.menuTheme[theme._theme][0],theme.menuTheme[theme._theme][1],theme.menuTheme[theme._theme][2]);
  }
  menuInfo1.clearData();
  menuInfo1.add("(SPACE) Destinations Active: " + system._dest);
  menuInfo1.add("(z) Display Destinations: " + _displayDestinations);
  menuInfo1.add("(r) Run: " + system._run);
  menuInfo1.add("(i) Display Ids: " + _displayId);
  menuInfo1.add("(g) Display Grid: " + _grid);
  menuInfo1.add("(l) Display Link Lines: " + _lines);
  menuInfo1.add("(t) Display particle ticks: " + _particleTicks);
  menuInfo1.add("(x) Display centroid: " + _displayCentroid);
  menuInfo1.add("(p) Perimeter Coordination: " + system._perimCoord);
  menuInfo1.add("(c) Perimeter Compress: " + system._perimCompress);
  menuInfo1.add("(0) Display Particle Fields: " + _displayParticleFields);
  menuInfo1.add("===========PAN============");
  menuInfo1.add("(h/k) X:" + _offsetX);
  menuInfo1.add("(u/n) Y:" + _offsetY);
  menuInfo1.add("(j) RESET - Offset");  
  menuInfo1.add("===========ZOOM===========");
  menuInfo1.add("(a) <-20% (s) 100% (d) 500%-> : " + String.format("%.2f",_scale));
  menuInfo1.add("==========================");
  menuInfo1.add("(q) -10 (w) +10 - Grid :" + _gridSize);  
  menuInfo1.add("(y) load (o) Save - Snapshot");
  menuInfo1.add("(m) MODE:" + _modes[_mode]);  
  menuInfo1.add("(1) Screen Grab");  
  menuInfo1.add("(ESC) EXIT");

  menuInfo2.setTitle(system._model);
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

void generateFrameRateInfo() {
  frameRateInfo.setColour(theme.menuTheme[theme._theme][0],theme.menuTheme[theme._theme][1],theme.menuTheme[theme._theme][2]);
  frameRateInfo.clearData();
  frameRateInfo.add(Float.toString(frameRate));
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
  agentInfo.add("Neighbours: ["+ agent._neighbours.size() +"]");
  agentInfo.draw();
}

void displayDestinationInfo(Destination dest) {
  destinationInfo.setTitle("ID:" + dest._id + " [X:" + String.format("%.2f",dest._location.x) + ", Y:"+ String.format("%.2f",dest._location.y) +"]");
  destinationInfo.setColour(theme.boxTheme[theme._theme][0],theme.boxTheme[theme._theme][1],theme.boxTheme[theme._theme][2]);
  destinationInfo.clearData();
  destinationInfo.add("Size: ["+ dest._size +"]");
  destinationInfo.add("Mass: ["+ dest._mass +"]");
  destinationInfo.draw();
}

void displayObstacleInfo(Obstacle o) {
  obstacleInfo.setTitle("ID:" + o._id + " [X:" + String.format("%.2f",o._location.x) + ", Y:"+ String.format("%.2f",o._location.y) +"]");
  obstacleInfo.setColour(theme.boxTheme[theme._theme][6],theme.boxTheme[theme._theme][7],theme.boxTheme[theme._theme][8]);
  obstacleInfo.clearData();
  obstacleInfo.add("Size: ["+ o._size +"]");
  obstacleInfo.add("Range: ["+ o._range +"]");
  obstacleInfo.add("Mass: ["+ o._mass +"]");
  obstacleInfo.draw();
}

void displayCentroid() {
  float _size1 = 45;
  float _size2 = 30;
  float _size3 = 15;
  PVector center = system.getCentroid();
  float x = transX(center.x);
  float y = transY(center.y);
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
  for(int x = -width; x < width*2; x = x + _gridSize) {
    if (alt) {
      strokeWeight(1);
      stroke(theme.desktopTheme[theme._theme][1]);
    } else {
      strokeWeight(1.5);
      stroke(theme.desktopTheme[theme._theme][2]);
    }
    alt = !alt;
    line(x,-height*2,x,height);      
  }
  alt = true;
  for(int y = -height*2; y < height; y = y + _gridSize) {
    if (alt) {
      strokeWeight(1);
      stroke(theme.desktopTheme[theme._theme][1]);
    } else {
      strokeWeight(1.5);
      stroke(theme.desktopTheme[theme._theme][2]);
    }
    alt = !alt;
    line(-width,y,width*2,y);      
  }
  strokeWeight(1);
}

void displayParticle(Particle p) {
/** 
* Render the particle onto the canvas
*
* @param p Particle/Agent to render.
* 
*/
    if (_usePoint) {
      point(transX(p._location.x),transY(p._location.y));
    } else {
      strokeWeight(1);
      stroke(theme.particleTheme[theme._theme][0]);
      if (p._isPerimeter) {
         fill(theme.particleTheme[theme._theme][1]);
      } else {
         fill(theme.particleTheme[theme._theme][2]);
      }
      ellipse(transX(p._location.x),transY(p._location.y),(p._size*p._mass*_scale),(p._size*p._mass*_scale));
      if (_particleTicks) displayTick(p);
      if (_displayId) displayId(p);
      if (_displayParticleFields) {
        noFill();
        strokeWeight(1);
        stroke(150,0,0);
        ellipse(transX(p._location.x),transY(p._location.y), p._repulse * 2 * _scale, p._repulse * 2 * _scale);
        stroke(0,150,0);
        ellipse(transX(p._location.x),transY(p._location.y), p._range * 2 * _scale, p._range * 2 * _scale);
      }
    }
}

void displayDestination(Destination d) {
/** 
* Renders the Destination onto the canvas
*
* @param d Destination to render.
* 
*/
  strokeWeight(constrain(2*_scale,1,4));
  stroke(theme.destinationTheme[theme._theme][0]);
  fill(theme.destinationTheme[theme._theme][1]);
  ellipse(transX(d._location.x),transY(d._location.y),constrain(20*_scale,10,25),constrain(20*_scale,10,25));
  if (_displayId) displayId(d);
}

void displayObstacle(Obstacle o) {
/** 
* Render the obstacle onto the canvas
*
* @param o Obstacle to render.
* 
*/
  strokeWeight(constrain(2*_scale,1,4));
  stroke(theme.obstacleTheme[theme._theme][0]);
  fill(theme.obstacleTheme[theme._theme][1]);
  ellipse(transX(o._location.x),transY(o._location.y),constrain(20*_scale,10,25),constrain(20*_scale,10,25));
  noFill();
  strokeWeight(1);
  stroke(theme.obstacleTheme[theme._theme][2]);
  ellipse(transX(o._location.x),transY(o._location.y), o._range * 2 * _scale, o._range * 2 * _scale);
  if (_displayId) displayId(o);
  if (system._obstacleLink) displayObstacleLines();
}

void displayObstacleLines(){
  if (system.obstacles.size() > 1) {
    for (int i = 1; i < system.obstacles.size(); i++) {
      strokeWeight(1);
      stroke(theme.obstacleTheme[theme._theme][2]);
      PVector start = system.obstacles.get(i)._location;
      PVector end = system.obstacles.get(i-1)._location;
      PVector d = PVector.sub(end,start);
      d.rotate(HALF_PI).setMag(system._obstacleRange);
      line(transX(start.x),transY(start.y),transX(end.x),transY(end.y));
      line(transX(start.x + d.x),transY(start.y + d.y),transX(end.x + d.x),transY(end.y + d.y));
      line(transX(start.x - d.x),transY(start.y - d.y),transX(end.x - d.x),transY(end.y - d.y));
    }
  }
}

PImage swarmDirectionImage() {
/** 
* Generate Direction Image.
* 
*/
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

void displayLines() {
  if (_usePoint) {
    displayPointLines();
  } else {
    displayParticleLines();
  }
}

void displayParticleLines() {
/** 
* Display cohesion lines.
* Start and endpoints moved to particle borders 
* Slower?
*/ 
  for(Particle i : system.particles) {
    for(Particle j : system.particles) {
      if (PVector.dist(i._location,j._location) < i._range & i != j) {
// Calculate start point
        PVector atb = PVector.sub(i._location,j._location);
        atb.normalize().setMag(i._mass * j._size/2);
        PVector start = i._location.copy();
        start.sub(atb);
// Calculate end point  
        PVector bta = PVector.sub(j._location,i._location);
        bta.normalize().setMag(j._mass * j._size/2);
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
        line(transX(start.x),transY(start.y),transX(end.x),transY(end.y));
        strokeWeight(1);
      }
    }
  }
}

 void displayPointLines() {
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
         line(transX(start.x),transY(start.y),transX(end.x),transY(end.y));
         strokeWeight(1);
       }
     }
   }
 }

void displayId(Particle agent) {
/** 
* Renders the particleId onto the canvas
*
* @param agent to apply Id
*/
  textSize(12);
  textAlign(CENTER,CENTER);
  fill(0, 0, 0,255);
  text(agent._id,transX(agent._location.x),transY(agent._location.y));
}

void displayId(Destination d) {
/** 
* Renders the DestinationId onto the canvas
*
* @param Destination to apply Id
* 
*/
  textSize(12);
  textAlign(CENTER,CENTER);
  fill(0, 0, 0,255);
  text(d._id,transX(d._location.x),transY(d._location.y));
}

void displayId(Obstacle o) {
/** 
* Renders the ObstacleId onto the canvas
*
* @param Obstacle to apply Id
* 
*/
  textSize(12);
  textAlign(CENTER,CENTER);
  fill(255,255,255,255);
  text(o._id,transX(o._location.x),transY(o._location.y));
}


void displayTick(Particle agent) {
/** 
* Renders the particle's tick onto the canvas
*
* @param agent Agent/Particle to apply tick to.
* 
*/
  float _tickSize = 5.0;
  stroke(0);
  PVector tick = PVector.sub(agent._nextLocation,agent._location);
  tick.setMag((agent._mass * agent._size/2) + _tickSize);
  tick.add(agent._location);
  strokeWeight(2);
  line(transX(agent._location.x), transY(agent._location.y), transX(tick.x), transY(tick.y));
  strokeWeight(1);
}

float transX(float val) {
/** 
* Scale and Pan Transpose
*
* @param val X value to transpose.
* 
*/
  val = val * _scale + _offsetX;
  return val;
}

float transY(float val) {
/** 
* Scale and Pan Transpose
*
* @param val Y value to transpose.
* 
*/
  val = val * _scale + _offsetY;
  return val;
}

float tranX(float val) {
/** 
* Reverse Scale and Pan Transpose
*
* @param val X value to transpose.
* 
*/  
  val = val / _scale - _offsetX / _scale;
  return val;
}

float tranY(float val) {
/** 
* Reverse Scale and Pan Transpose
*
* @param val Y value to transpose.
* 
*/
  val = val / _scale - _offsetY / _scale;
  return val;
}

boolean mouseOver(InfoBox b) {
/** 
* Detect if mouse is over Window header
*
* @param b Box.
* 
*/
  if (mouseX >= b._posX && mouseX <= b._posX+b._width && 
      mouseY >= b._posY && mouseY <= b._posY+25) {
    return true;
  } else {
    return false;
  }
}

boolean mouseOver(Particle p) {
/** 
* Detect if mouse is over Agent/Particle
*
* @param p Particle.
* 
*/
  float x = transX(p._location.x);
  float y = transY(p._location.y);
  int w = 10;
  int h = 10;
  if (mouseX >= x-w && mouseX <= x+w && 
      mouseY >= y-h && mouseY <= y+h) {
    return true;
  } else {
    return false;
  }
}

boolean mouseOver(Destination d) {
/** 
* Detect if mouse is over Destination
*
* @param p Particle.
* 
*/
  float x = transX(d._location.x);
  float y = transY(d._location.y);
  int w = 10;
  int h = 10;  
  if (mouseX >= x-w && mouseX <= x+w && 
      mouseY >= y-h && mouseY <= y+h) {
    return true;
  } else {
    return false;
  }
}

boolean mouseOver(Obstacle o) {
/** 
* Detect if mouse is over Obstacle
*
* @param o Obstacle.
* 
*/
  float x = transX(o._location.x);
  float y = transY(o._location.y);
  int w = 10;
  int h = 10;  
  if (mouseX >= x-w && mouseX <= x+w && 
    mouseY >= y-h && mouseY <= y+h) {
    return true;
  } else {
    return false;
  }
}
