class Theme  {

  int _theme = 0;
  String[] _themeName = {"Dark","Light"};
  color[][] menuTheme = {
  // |   borderColour           fillColour               textColour             loggingColour  |
    {color(0  ,0  ,0  ,255),color(70 ,75 ,70 ,150),color(0  ,0  ,0  ,255),color(70 ,50 ,50 ,150)},
    {color(0  ,0  ,0  ,255),color(255,255,255,150),color(0  ,0  ,0  ,255),color(255,150,150,150)}
  };
  color[][] boxTheme = {
  // | destination                                                         | agent                                                               | obstacle                                                         |   
  // |   borderColour           fillColour               textColour        |   borderColour           fillColour               textColour        |   borderColour           fillColour               textColour     |       
    {color(0  ,0  ,0  ,255),color(150,25 ,25 ,200),color(0  ,0  ,0  ,255), color(0  ,0  ,0  ,255),color(25 ,150,25 ,200),color(0  ,0  ,0  ,255), color(0  ,0  ,0  ,255),color(50 ,50 ,150,200),color(0  ,0  ,0  ,255)},
    {color(255,0  ,0  ,255),color(255,150,150,200),color(0  ,0  , 0 ,255), color(0  ,255,0  ,255),color(150,255,155,200),color(0  ,0  ,0  ,255), color(0  ,0  ,255,255),color(150,150,255,200),color(0  ,0  ,0  ,255)}
  };
  color[][] desktopTheme = {
  // | background           | grid1                | grid2               |  
    {color(200,200,200,100),color(80 ,80 ,80 ,100),color(0  ,0  ,0  ,100)},
    {color(255,255,255,0),color(100,100,100,100),color(50 ,50 ,50 ,100)}
  };

  color[][] particleTheme = {
  // | stroke               | fill1                | fill2     |  
    {color(0  ,0  ,0  ,255),color(25 ,100,25 ,255),color(50 ,175,50 ,255)},
    {color(0  ,0  ,0  ,255),color(50 ,150,50 ,255),color(200,255,200,255)}
  };

  color[][] obstacleTheme = {
  // | stroke               | fill                  | boundary             |  
    {color(0  ,0  ,0  ,255),color(10 ,10 ,150 ,255),color(10 ,10 ,150,255)},
    {color(0  ,0  ,0  ,255),color(0  ,0  ,255 ,255),color(0  ,  0,255,255)}
  };

  color[][] destinationTheme = {
  // | stroke               | fill               |
    {color(0  ,0  ,0  ,255),color(150,10 ,10 ,255)}, 
    {color(0  ,0  ,0  ,255),color(255,0  ,0  ,255)}
  };

  color[] lineTheme = {
  //| line               |
    color(0  ,0  ,0  ,255), 
    color(100,100,100,255)
  };

}