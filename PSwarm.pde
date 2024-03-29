/**************************************************
* PSwarm
***************************************************
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
import processing.sound.*;

java.util.Properties properties = new java.util.Properties();
PSystem system;
Theme theme = new Theme(); 
PVectorDFactory pvectorDFactory = new PVectorDFactory();
Helper helper = new Helper();
String renderer = P2D;
ArrayList<PImage> mice1 = new ArrayList<PImage>();
ArrayList<PImage> mice2 = new ArrayList<PImage>();
ArrayList<InfoBox> displayWindows = new ArrayList<InfoBox>();
PImage mouse;
PImage mouse1;
PImage mouse2;
PImage logo;
PImage about;
PImage license;
String _NAME = "PSwarm";
String _AUTHORS = "(c) 2021";
String _VERSION = "0.3.0";
double _scale = 1.0; // Scaling factor
int _offsetX = 0; // Swarm display offsetX
int _offsetY = 0; // Swarm display offsetY
int _clickedOffsetX = 0; // Swarm display offsetX
int _clickedOffsetY = 0; // Swarm display offsetY
int _clickedMouseX = 0;
int _clickedMouseY = 0;
boolean mousePresent;
boolean _logo = true;
boolean _displayId = false; // Display Y/N
boolean _particleTicks = true; // Display Y/N
boolean _displayParticleFields = false; // Display Y/N
int _particleSize = 20;
boolean _lines = true; // Display Y/N
boolean _grid = true; // Display Y/N
boolean _displayDestinations = true; // Display Y/N
boolean _usePoint = false;
boolean _shadow = false;
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
InfoBox menuInfo1 = new InfoBox(2,2,theme.menuTheme[theme._theme][0],theme.menuTheme[theme._theme][1],theme.menuTheme[theme._theme][2],"MENU",false);
InfoBox menuInfo2 = new InfoBox(346,2,theme.menuTheme[theme._theme][0],theme.menuTheme[theme._theme][1],theme.menuTheme[theme._theme][2],"MENU",false);
InfoBox directionInfo = new InfoBox(2,605,theme.menuTheme[theme._theme][0],theme.menuTheme[theme._theme][1],theme.menuTheme[theme._theme][2],"Direction",false);
InfoBox frameRateInfo = new InfoBox(2,800,theme.menuTheme[theme._theme][0],theme.menuTheme[theme._theme][1],theme.menuTheme[theme._theme][2],"Frame Rate",false);
InfoBox aboutInfo = new InfoBox(10,10,theme.menuTheme[theme._theme][0],theme.menuTheme[theme._theme][1],theme.menuTheme[theme._theme][2],"About",false);

InfoBox destinationInfo = new InfoBox(0,0,theme.boxTheme[theme._theme][0],theme.boxTheme[theme._theme][1],theme.boxTheme[theme._theme][2],"Destination",true);
InfoBox pInfo = new InfoBox(0,0,theme.boxTheme[theme._theme][3],theme.boxTheme[theme._theme][4],theme.boxTheme[theme._theme][5],"Agent",true);
InfoBox obstacleInfo = new InfoBox(0,0,theme.boxTheme[theme._theme][6],theme.boxTheme[theme._theme][7],theme.boxTheme[theme._theme][8],"Obstacle",true);

void settings() {
    /** 
    * Video environment setup
    */ 
    try {
        properties.load(createReader("application.properties"));
    } catch(Exception e) {
        println(e);
        exit();
    }
    //FIX for linux default settings when using OpenGL
    System.setProperty("jogl.disable.openglcore", "false");
    if(boolean(properties.getProperty("perspective"))) renderer = P3D;
    if(boolean(properties.getProperty("fullScreen"))) {
        fullScreen(renderer,int(properties.getProperty("screen")));
        PJOGL.setIcon("icons/logo6.png");
    } else {
        size(int(properties.getProperty("width")),int(properties.getProperty("height")),renderer);
    }
    if(boolean(properties.getProperty("antialias"))) {
        smooth(int(properties.getProperty("smoothFactor")));
    } else {
        noSmooth();
    }
    println("SETTINGS COMPLETE");
}

void setup() {
    /** 
    * Load system images setup Swarm model
    * 
    */
    println("SETUP STARTED");
    logo = loadImage("icons/logo6.png");
    aboutInfo.setGraphic(loadImage("icons/about.jpg"));
    aboutInfo.setSound(new SoundFile(this, "/sound/about.mp3"));
    frameRate(int(properties.getProperty("frameRate")));
    if(!boolean(properties.getProperty("fullScreen"))) {
        surface.setTitle(_NAME + " : " + _VERSION);
        surface.setResizable(boolean(properties.getProperty("scalable")));
        surface.setLocation(0, 0);
        surface.setIcon(logo);
    }
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
    _offsetX = width/2;
    _offsetY = height/2;
    try {
        switch(int(properties.getProperty("model"))) {
            case 1:
            system = new Model1(); 
            println("MODEL LOADED");
            break;
        }
        system.init();
    } catch (Exception e) {
        System.out.println(e);
        System.exit(-1);
    }
    _scale = Double.parseDouble(system.modelProperties.getProperty("scale"));

    directionInfo._visible = boolean(properties.getProperty("directionBox"));
    frameRateInfo._visible = boolean(properties.getProperty("frameRateBox"));
    aboutInfo._visible = false;
    aboutInfo._canMinimise = false;
    menuInfo1._visible = boolean(properties.getProperty("menu1Box"));
    menuInfo2._visible = boolean(properties.getProperty("menu2Box"));
    menuInfo1._minimised = boolean(properties.getProperty("menu1BoxMinimised"));
    menuInfo2._minimised = boolean(properties.getProperty("menu2BoxMinimised"));
    _displayId = boolean(properties.getProperty("displayId"));
    _particleTicks = boolean(properties.getProperty("particleTicks"));
    _particleSize = int(properties.getProperty("particleSize"));
    _displayParticleFields = boolean(properties.getProperty("displayParticleFields"));
    _lines = boolean(properties.getProperty("lines"));
    _grid = boolean(properties.getProperty("grid"));
    _displayDestinations = boolean(properties.getProperty("displayDestinations"));
    _displayCentroid = boolean(properties.getProperty("displayCentroid"));
    _usePoint = boolean(properties.getProperty("usePoint"));
    _shadow = boolean(properties.getProperty("shadow"));
    
    displayWindows.add(menuInfo1);
    displayWindows.add(menuInfo2);
    displayWindows.add(directionInfo);
    displayWindows.add(frameRateInfo);
    displayWindows.add(aboutInfo);
    frameRateInfo.setPos(width - (frameRateInfo._width + 2),2);
    background(theme.desktopTheme[theme._theme][0]);
    println("SETUP COMPLETE");
}

public void mouseExited() {
   	mousePresent = false;
}
    
public void mouseEntered() {
   	mousePresent = true;
}

void draw() {
    /** 
    * Render the application
    */ 
    if(millis() < 5000) {
        background(0);
        image(logo,(width - logo.width) / 2,(height - logo.height) / 2);
        textSize(24);
        text("V:" + _VERSION + " - " + system._model,(width - logo.width) / 2,((height - logo.height) / 2) - 5);
        return;
    } else {
//        scale(1,-1);
        background(theme.desktopTheme[theme._theme][0]);
    }
    if ( focused && mousePresent ) {
        noCursor();
    } else {
        cursor();
    }
    if(boolean(properties.getProperty("perspective"))) {
        translate(height / 2,width / 2);
        rotateX(radians(float(properties.getProperty("angle"))));
        translate( - height / 2, - width / 2);
    }
    
    if(_grid) displayGrid();
    if(_displayCentroid) displayCentroid();
    system.update();
    _currentParticle = null;
    _currentDestination = null;
    _currentObstacle = null;
    _displayWindowInfo = null;
    if(_menu) { 
        generateMenu();
        generateDirectionInfo();
        generateFrameRateInfo();
        for (InfoBox b : displayWindows) {
           if (b._visible) {
                b.draw();
                if (mouseOver(b)) _displayWindowInfo = b;
            }
        }
    }
    if(_displayDestinations) {
        for (Destination d : system.D) {
            displayDestination(d);
           if (mouseOver(d)) _currentDestination = d;
        }
    }
    for (Obstacle o : system.O) {
        displayObstacle(o);
        if (mouseOver(o)) _currentObstacle = o;
    } 
    if(_lines) displayLines();
    for (Particle p : system.S) {
        displayParticle(p);
        if (mouseOver(p)) _currentParticle = p;
    }
    image(mouse,mouseX - 10,mouseY - 10,32,32);
    if(_currentParticle != null && _mode == _AGENT) displayAgentInfo(_currentParticle);
    if(_currentDestination != null && _mode == _DESTINATION) displayDestinationInfo(_currentDestination);
    if(_currentObstacle != null && _mode == _OBSTACLE) displayObstacleInfo(_currentObstacle);
    system.moveReset();
    fill(0);
    textSize(10);
    text(_NAME + " - " + _AUTHORS, 10, height - 25);
    image(license,width - 88,height - 31,88,31);
    if(keyPressed) {
        scalers();
    }
}

void mousePressed() {
    mouse = mouse2;
    if(mouseButton == LEFT && _mode == _DESTINATION && _currentDestination == null) {
        system.addDestination(tranX(mouseX),tranY(mouseY),0);
    }
    if(mouseButton == RIGHT && _mode == _DESTINATION && _currentDestination != null) {
        system.deleteDestination(_currentDestination);
    }
    if(mouseButton == LEFT && _mode == _AGENT && _currentParticle == null) {
        system.addParticle(tranX(mouseX),tranY(mouseY),0);
    } 
    if(mouseButton == RIGHT && _mode == _AGENT && _currentParticle != null) {
        system.deleteParticle(_currentParticle);
    } 
    if(mouseButton == LEFT && _mode == _OBSTACLE && _currentObstacle == null) {
        system.addObstacle(tranX(mouseX),tranY(mouseY),0);
    } 
    if(mouseButton == RIGHT && _mode == _OBSTACLE && _currentObstacle != null) {
        system.deleteObstacle(_currentObstacle);
    }
    if(mouseButton == LEFT && _mode == _WINDOW && _displayWindowInfo != null) {
        _clickPosX = _displayWindowInfo._posX - mouseX;
        _clickPosY = _displayWindowInfo._posY - mouseY;
    } 
    if(mouseButton == RIGHT && _mode == _WINDOW && _displayWindowInfo != null) {
        _displayWindowInfo._minimised = !_displayWindowInfo._minimised;
    }
    if(mouseButton == CENTER) {
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
    double e = event.getCount();
    if(e > 0) {if (_scale > 0.2) _scale -= 0.1;}
    if(e < 0) {if (_scale < 100.0) _scale += 0.1;}
}

void mouseDragged() {
    if(mouseButton == LEFT && _mode == _AGENT && _currentParticle != null) {
        _currentParticle.setPos(tranX(mouseX),tranY(mouseY),0);
    } 
    if(mouseButton == LEFT && _mode == _WINDOW && _displayWindowInfo != null) {
        _displayWindowInfo.setPos(mouseX + _clickPosX, mouseY + _clickPosY);
    } 
    if(mouseButton == LEFT && _mode == _OBSTACLE && _currentObstacle != null) {
        _currentObstacle.setPos(tranX(mouseX),tranY(mouseY),0);
    } 
    if(mouseButton == LEFT && _mode == _DESTINATION && _currentDestination != null) {
        _currentDestination.setPos(tranX(mouseX),tranY(mouseY),0);
    }
    if(mouseButton == CENTER) {
        int moveX = mouseX - _clickedMouseX;
        int moveY = mouseY - _clickedMouseY;
        if (_offsetX + moveX >= -10000 && _offsetX + moveX <= 10000) _offsetX = _clickedOffsetX + moveX;
        if (_offsetY + moveY >= -10000 && _offsetY + moveY <= 10000) _offsetY = _clickedOffsetY + moveY;
    }
}

void keyPressed() {
    /** 
    * Menu selection
    */ 
    if(key == 'o') {saveSwarm();}
    if(key == 'y') {loadSwarm();}
    if(key == '?') {_menu = !_menu;}
    if(key == 'r') {system._run = !system._run;}
    if(key == ' ') {system._dest = !system._dest;}
    if(key == 'q') {if (_gridSize > 20) _gridSize -= 20;}
    if(key == 'w') {if (_gridSize < 80) _gridSize += 20;}
    if(key == '6') {if (_particleSize < 150) _particleSize += 1;}
    if(key == '7') {if (_particleSize > 5) _particleSize -= 1;}
//    if(key == 'p') {system._perimCoord = !system._perimCoord;}  
//    if(key == 'c') {system._perimCompress = !system._perimCompress;} 
//    if(key == 'v') {system._adver = !system._adver;} 
    if(key == 'g') {_grid = !_grid;}
    if(key == 'l') {_lines = !_lines;} 
    if(key == 'i') {_displayId = !_displayId;}
    if(key == 't') {_particleTicks = !_particleTicks;}
    if(key == 'x') {_displayCentroid = !_displayCentroid;}
    if(key == 'z') {_displayDestinations = !_displayDestinations;}
    if(key == '0') {_displayParticleFields = !_displayParticleFields;}
    if(key == '1') {screenGrab();}
    if(key == 'm') {changeMode();}
    if(key == '2') {changeTheme();} 
    if(key == '\\') {displayAbout();} 
}

void displayAbout() {
    aboutInfo._visible=!aboutInfo._visible;
    if (aboutInfo._visible) {
        aboutInfo.playSound();
    }
};

void changeMode() {
    _mode += 1;
    if(_mode > 3) {
        _mode = 0;
    } 
    mouse1 = mice1.get(_mode);  
    mouse2 = mice2.get(_mode);
    mouse = mouse1;
};

void changeTheme() {
    theme._theme += 1;
    if(theme._theme > 1) {
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

void screenGrab() {
    saveFrame("screen.png"); 
    println("Snapshot taken!");
}

void scalers() {
    if(key == 'h') {if (_offsetX >= - 10000) _offsetX -= 15;}
    if(key == 'k') {if (_offsetX <= (width + 10000)) _offsetX += 15;}
    if(key == 'u') {if (_offsetY >= - 10000) _offsetY -= 15;}
    if(key == 'n') {if (_offsetY <= (height + 10000)) _offsetY += 15;}
    if(key == 'j') {_offsetX = width/2; _offsetY = height/2;}
    if(key == 'a') {if (_scale > 0.2) _scale -= 0.5;}
    if(key == 's') {_scale = 1;}
    if(key == 'd') {if (_scale < 100.0) _scale += 0.5;}
}

void generateMenu() {
    /** 
    * Generate menu
    */ 
    if(system._loggingP) {
        menuInfo1.setTitle("Menu - " + theme._themeName[theme._theme] + " (LOGGING)");
    } else {
        menuInfo1.setTitle("Menu - " + theme._themeName[theme._theme]);
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
    menuInfo1.add("(0) Display Particle Fields: " + _displayParticleFields);
    menuInfo1.add("===========PAN============");
    menuInfo1.add("(h/k) X:" + (_offsetX - width/2));
    menuInfo1.add("(u/n) Y:" + (_offsetY - height/2));
    menuInfo1.add("(j) RESET - Offset");  
    menuInfo1.add("===========ZOOM===========");
    menuInfo1.add("(a) <-20% (s) 100% (d) 500%-> : " + String.format("%.2f",_scale));
    menuInfo1.add("==========PARTICLE==========");
    menuInfo1.add("(6) +1 (7) -1 : " + _particleSize);
    menuInfo1.add("==========================");
    menuInfo1.add("(q) -20 (w) +20 - Grid :" + _gridSize);  
    menuInfo1.add("(y) load (o) Save - Snapshot");
    menuInfo1.add("(m) MODE:" + _modes[_mode]);  
    menuInfo1.add("(1) Screen Grab");  
    menuInfo1.add("(ESC) EXIT");
    
    menuInfo2.setTitle(system._model);
    menuInfo2.clearData();
    menuInfo2.add("Agents:" + system.S.size() + " Destinations:" + system.D.size() + " Obstacles:" + system.O.size());
    menuInfo2.add("==========================");
    if (boolean(system.modelProperties.getProperty("loadSwarm"))) {
        menuInfo2.add("JSON: " + system.modelProperties.getProperty("swarmName") + " (LOADED)");  
    } else {
        menuInfo2.add("JSON: " + system.modelProperties.getProperty("swarmName") + " (DEFAULT)");  
    }
    menuInfo2.add("==========================");  
    menuInfo2.add("Default Speed: " + system._speed);
    menuInfo2.add("Cohesion Range: " + system._C);
    menuInfo2.add("Obstacle Range: " + system._Ob);
    menuInfo2.add("Obstacle Weight: " + system._ko);
    menuInfo2.add("==========================");  
    menuInfo2.add("kd: " + "[" + system._kd[0] + "," + system._kd[1] +"]");
    menuInfo2.add("ka: " + "[" + system._ka[0] + "," + system._ka[1] +"]");
    menuInfo2.add("arange: " + "[" + system._arange + "]");
    menuInfo2.add("R: " + "[[" + system._R[0][0] + "," + system._R[0][1] +"],[" + system._R[1][0] + "," + system._R[1][1] + "]]");
    menuInfo2.add("kr: " + "[[" + system._kr[0][0] + "," + system._kr[0][1] +"],[" + system._kr[1][0] + "," + system._kr[1][1] + "]]");
    menuInfo2.add("kc: " + "[[" + system._kc[0][0] + "," + system._kc[0][1] +"],[" + system._kc[1][0] + "," + system._kc[1][1] + "]]");
    menuInfo2.add("kg: " + system._kg + " reflex: " + system._rgf);
    menuInfo2.add("Scaling: " + "[" + system._scaling + "]");
    menuInfo2.add("Gain: " + "[" + system._gain + "]");
    menuInfo2.add("==========================");  
    menuInfo2.add("Average Magnitude: " + String.format("%015.4f",system._swarmDirection.mag()));
}

void generateDirectionInfo() {
    directionInfo.setGraphic(swarmDirectionImage());
}

void generateFrameRateInfo() {
    frameRateInfo.clearData();
    frameRateInfo.add(String.format("%.4f", frameRate));
    frameRateInfo.add("STEP:" + String.format("%d", system._step));
}

void displayAgentInfo(Particle p) {
    char tick;    
    if (p._isPerim) {
        tick = '\u2713';
    } else {
        tick = ' ';
    }
    pInfo.setTitle("ID:" + p._id + " [X:" + String.format("%07.2f",p._loc.x) + " Y:" + String.format("%07.2f",p._loc.y) + "] " + tick);
    pInfo.setColour(theme.boxTheme[theme._theme][3],theme.boxTheme[theme._theme][4],theme.boxTheme[theme._theme][5]);
    pInfo.clearData();
    pInfo.add("Mass: [" + p._mass + "]");
    pInfo.add("Speed: [" + p._topspeed + "]");
    pInfo.add("Size: [" + p._size + "]");
    pInfo.add("Neighbours: [" + p._nbr.size() + "]");
    int i = 1;
    for (Particle n : p._nbr) {
        if(n._isPerim) {
            tick = '\u2713';
        } else {
            tick = ' ';
        }
//        pInfo.add("(" + String.format("%02d", i++) + ")-" + String.format("%03d",n._id) + " [X:" + String.format("%07.2f",n._loc.x) + " Y:" + String.format("%07.2f",n._loc.y) + " Z:" + String.format("%07.2f",n._loc.z) + "] " + tick);
        pInfo.add("(" + String.format("%02d", i++) + ")-" + String.format("%03d",n._id) + " [X:" + String.format("%07.2f",n._loc.x) + " Y:" + String.format("%07.2f",n._loc.y) + "] " + tick);
    }
    pInfo.draw();
}

void displayDestinationInfo(Destination dest) {
    destinationInfo.setTitle("ID:" + dest._id + " [X:" + String.format("%.2f",dest._loc.x) + ", Y:" + String.format("%.2f",dest._loc.y) + "]");
    destinationInfo.clearData();
    destinationInfo.add("Size: [" + dest._size + "]");
    destinationInfo.add("Mass: [" + dest._mass + "]");
    destinationInfo.draw();
}

void displayObstacleInfo(Obstacle o) {
    obstacleInfo.setTitle("ID:" + o._id + " [X:" + String.format("%.2f",o._loc.x) + ", Y:" + String.format("%.2f",o._loc.y) + "]");
    obstacleInfo.clearData();
    obstacleInfo.add("Size: [" + o._size + "]");
    obstacleInfo.add("Mass: [" + o._mass + "]");
    obstacleInfo.draw();
}

void displayCentroid() {
    double _size1 = 80;
    double _size2 = 50;
    double _size3 = 20;
    PVectorD center = system.getCentroid();
    double x = transX(center.x);
    double y = transY(center.y);
    noStroke();
    fill(0,0,100,100);
    ellipse((float)x,(float)y,(float)_size1,(float)_size1);
    fill(0,100,0,100);
    ellipse((float)x,(float)y,(float)_size2,(float)_size2);
    fill(100,0,0,200);
    ellipse((float)x,(float)y,(float)_size3,(float)_size3);
}

void displayGrid() {
    /** 
    * Display the grid
    */ 
    stroke(theme.desktopTheme[theme._theme][2]);
    strokeWeight(2);
    noFill();
    circle((float)_offsetX,(float)_offsetY,(float)(10*_scale));
    boolean alt = true;
    for (int x = - width * 2 + _offsetX; x < width * 2 + _offsetX; x += _gridSize) {
        if (!alt) {
            strokeWeight(1);
            stroke(theme.desktopTheme[theme._theme][1]);
        } else {
            strokeWeight(1.5);
            stroke(theme.desktopTheme[theme._theme][2]);
        }
        alt = !alt;
        if (x - _offsetX == 0) {
            strokeWeight(1.5);
            stroke(0);
        }
        line(x, - height * 2,x,height);      
    }
    alt = true;
    for (int y = -height * 2 + _offsetY; y < height * 2  + _offsetY; y += _gridSize) {
        if (alt) {
            strokeWeight(1);
            stroke(theme.desktopTheme[theme._theme][1]);
        } else {
            strokeWeight(1.5);
            stroke(theme.desktopTheme[theme._theme][2]);
        }
        alt = !alt;
        if (y - _offsetY == 0) {
            strokeWeight(1.5);
            stroke(0);
        }
        line( - width,y,width * 2,y);      
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
        point((float)transX(p._loc.x),(float)transY(p._loc.y));
    } else {
        strokeWeight(1);
        stroke(theme.particleTheme[theme._theme][0]);
        if(p._isPerim) {
            fill(theme.particleTheme[theme._theme][1]);
        } else {
            fill(theme.particleTheme[theme._theme][2]);
        }
        ellipse((float)transX(p._loc.x),(float)transY(p._loc.y),_particleSize,_particleSize);
        if (renderer == P3D && _shadow) {
            stroke(150,150,150,150);
            fill(150,150,150,150);
            ellipse((float)transX(p._loc.x),(float)transY(p._loc.y+100),_particleSize,_particleSize);
        }
        if(_particleTicks) displayTick(p);
        if(_displayId) displayId(p);
        if(_displayParticleFields) {
            noFill();
            strokeWeight(1);
            stroke(150,0,0);
            ellipse((float)transX(p._loc.x),(float)transY(p._loc.y), (float)(system._R[p.isPerim()][0] * 2 * _scale), (float)(system._R[p.isPerim()][0] * 2 * _scale));
            ellipse((float)transX(p._loc.x),(float)transY(p._loc.y), (float)(system._R[p.isPerim()][1] * 2 * _scale), (float)(system._R[p.isPerim()][1] * 2 * _scale));
            stroke(0,150,0);
            ellipse((float)transX(p._loc.x),(float)transY(p._loc.y), (float)(system._C * 2 * _scale), (float)(system._C * 2 * _scale));
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
    strokeWeight(2);
    stroke(theme.destinationTheme[theme._theme][0]);
    fill(theme.destinationTheme[theme._theme][1]);
    ellipse((float)transX(d._loc.x),(float)transY(d._loc.y),_particleSize*1.5,_particleSize*1.5);
    if(_displayId) displayId(d);
}

void displayObstacle(Obstacle o) {
    /** 
    * Render the obstacle onto the canvas
    *
    * @param o Obstacle to render.
    * 
    */
    strokeWeight(2);
    stroke(theme.obstacleTheme[theme._theme][0]);
    fill(theme.obstacleTheme[theme._theme][1]);
    ellipse((float)transX(o._loc.x),(float)transY(o._loc.y),_particleSize,_particleSize);
    noFill();
    strokeWeight(1);
    stroke(theme.obstacleTheme[theme._theme][2]);
    ellipse((float)transX(o._loc.x),(float)transY(o._loc.y), (float)(o._Ob * 2 * _scale),(float)(o._Ob * 2 * _scale));
    if(_displayId) displayId(o);
    if(system._obstacleLink) displayObstacleLines();
}

void displayObstacleLines() {
    if(system.O.size() > 1) {
        for (int i = 1; i < system.O.size(); i++) {
            strokeWeight(1);
            stroke(theme.obstacleTheme[theme._theme][2]);
            PVectorD start = new PVectorD(system.O.get(i)._loc.x,system.O.get(i)._loc.y);
            PVectorD end = new PVectorD(system.O.get(i - 1)._loc.x,system.O.get(i - 1)._loc.y);
            PVectorD d = pvectorDFactory.sub(end,start);
            d.rotate(Math.PI/2).setMag(system._Ob);
            line((float)transX(start.x),(float)transY(start.y),(float)transX(end.x),(float)transY(end.y));
            line((float)transX(start.x + d.x),(float)transY(start.y + d.y),(float)transX(end.x + d.x),(float)transY(end.y + d.y));
            line((float)transX(start.x - d.x),(float)transY(start.y - d.y),(float)transX(end.x - d.x),(float)transY(end.y - d.y));
        }
    }
}

PImage swarmDirectionImage() {
    /** 
    * Generate Direction Image.
    * 
    */
    int sizeXY = 150;
    PVectorD lineStart = new PVectorD(sizeXY / 2,sizeXY / 2); 
    PVectorD lineEnd = new PVectorD(system._swarmDirection.x,system._swarmDirection.y);
    String out;
    double adjust;
    lineEnd.setMag((sizeXY / 2) - 5);
    lineEnd.add(lineStart);
    PGraphics myImage = createGraphics(sizeXY,sizeXY, JAVA2D);
    myImage.beginDraw();
    myImage.background(0,0);
    myImage.fill(180,150);
    myImage.stroke(0);
    myImage.circle(sizeXY / 2,sizeXY / 2,sizeXY - 4);
    myImage.strokeWeight(5);
    myImage.stroke(0);
    myImage.fill(0);
    myImage.line((float)lineStart.x,(float)lineStart.y,(float)lineEnd.x,(float)lineEnd.y);
    myImage.strokeWeight(1);
    myImage.fill(200);
    myImage.circle(sizeXY / 2,sizeXY / 2,sizeXY - 80);
    myImage.textAlign(CENTER, CENTER);
    myImage.fill(0);
    if (system._swarmDirection.mag() > 0) {adjust = 180;} else {adjust = 0;};
    out = String.format("%.2f\u00B0",Math.toDegrees(Math.atan2(system._swarmDirection.y,system._swarmDirection.x)) + adjust);
    myImage.text(out,sizeXY / 2,sizeXY / 2);
    myImage.textAlign(RIGHT,BASELINE);
    myImage.endDraw();
    return myImage;
}

void displayLines() {
    if(_usePoint) {
        displayPointLines();
    } else {
        displayPointLines();
//        displayParticleLines();
    }
}

void displayParticleLines() {
    /** 
    * Display cohesion lines.
    * Start and endpoints moved to particle borders 
    * Slower?
    */ 
    for (Particle i : system.S) {
        for (Particle j : system.S) {
           if (pvectorDFactory.dist(i._loc,j._loc) < i._Cb & i != j) {
               // Calculate start point
                PVectorD atb = pvectorDFactory.sub(i._loc,j._loc);
                atb.normalize().setMag(i._mass * j._size / 2);
                PVectorD start = i._loc.copy();
                start.sub(atb);
               // Calculate endpoint  
                PVectorD bta = pvectorDFactory.sub(j._loc,i._loc);
                bta.normalize().setMag(j._mass * j._size / 2);
                PVectorD end = j._loc.copy();
                end.sub(bta);
                // Enbolden perimeter lines
                stroke(theme.lineTheme[theme._theme]);
                if (i._isPerim && j._isPerim) {
                    strokeWeight(2);
            } else {
                    strokeWeight(1);
                    stroke(100,100,100);
                }
                if (renderer == P3D && _shadow) {
                    stroke(150,150,150,150);
                    line((float)transX(start.x),(float)transY(start.y+100),(float)transX(end.x),(float)transY(end.y+100));
                }
                line((float)transX(start.x),(float)transY(start.y),(float)transX(end.x),(float)transY(end.y));
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
    for (Particle i : system.S) {
        for (Particle j : system.S) {
            if (pvectorDFactory.dist(i._loc,j._loc) <= system._C & i != j) {
                // Calculate start point
                PVectorD atb = pvectorDFactory.sub(i._loc,j._loc);
                PVectorD start = i._loc.copy();
                start.sub(atb);
                // Calculate end point  
                PVectorD bta = pvectorDFactory.sub(j._loc,i._loc);
                PVectorD end = j._loc.copy();
                end.sub(bta);
               // Enbolden perimeter lines
                stroke(theme.lineTheme[theme._theme]);
                if (i._isPerim && j._isPerim) {
                    strokeWeight(2);
            } else {
                    strokeWeight(1);
                    stroke(100,100,100);
            }
                line((float)transX(start.x),(float)transY(start.y),(float)transX(end.x),(float)transY(end.y));
                strokeWeight(1);
        }
    }
    }
}

void displayId(Particle p) {
    /** 
    * Renders the particleId onto the canvas
    *
    * @param p to apply Id
    */
    textSize(12);
    textAlign(CENTER,CENTER);
    fill(0, 0, 0,255);
    text(p._id,(float)transX(p._loc.x),(float)transY(p._loc.y));
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
    text(d._id,(float)transX(d._loc.x),(float)transY(d._loc.y));
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
    text(o._id,(float)transX(o._loc.x),(float)transY(o._loc.y));
}

void displayTick(Particle p) {
    /** 
    * Renders the particle's tick onto the canvas
    *
    * @param p Agent/Particle to apply tick to.
    * 
    */
//double _particleSize = 20;
    stroke(0);
    PVectorD tick = pvectorDFactory.sub(p._nextLocation,p._loc);
//    tick.setMag(((p._mass * p._size / 2)  + _tickSize)/_scale);
    tick.normalize();
//    tick.add(p._loc);
    strokeWeight(2);
//    line(transX(p._loc.x), transY(p._loc.y), transX(tick.x), transY(tick.y));
    line((float)transX(p._loc.x), (float)transY(p._loc.y), (float)transX(p._loc.x) + (float)(tick.x * (_particleSize/2)), (float)transY(p._loc.y) + (float)(tick.y * (_particleSize/2)));
    strokeWeight(1);
}

double transX(double val) {
    /** 
    * Scale and Pan Transpose
    *
    * @param val X value to transpose.
    * 
    */
    val = val * _scale + _offsetX;
    return val;
}

double transY(double val) {
    /** 
    * Scale and Pan Transpose
    *
    * @param val Y value to transpose.
    * 
    */
    val = val * _scale + _offsetY;
    return val;
}

double tranX(double val) {
    /** 
    * Reverse Scale and Pan Transpose
    *
    * @param val X value to transpose.
    * 
    */  
    val = val / _scale - _offsetX / _scale;
    return val;
}

double tranY(double val) {
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
    if(mouseX >= b._posX && mouseX <= b._posX + b._width && 
        mouseY >= b._posY && mouseY <= b._posY + 25) {
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
    double x = transX(p._loc.x);
    double y = transY(p._loc.y);
    int w = 10;
    int h = 10;
    if(mouseX >= x - w && mouseX <= x + w && 
        mouseY >= y - h && mouseY <= y + h) {
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
    double x = transX(d._loc.x);
    double y = transY(d._loc.y);
    int w = 10;
    int h = 10;  
    if(mouseX >= x - w && mouseX <= x + w && 
        mouseY >= y - h && mouseY <= y + h) {
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
    double x = transX(o._loc.x);
    double y = transY(o._loc.y);
    int w = 10;
    int h = 10;  
    if(mouseX >= x - w && mouseX <= x + w && 
        mouseY >= y - h && mouseY <= y + h) {
        return true;
    } else {
        return false;
    }
}
