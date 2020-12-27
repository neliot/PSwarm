class InfoBox {
  ArrayList<String> _data = new ArrayList<String>();
  String _title;
  color _borderColour;
  color _textColour;
  color _fillColour;
  int _posX;
  int _posY;
  int _width;
  int _height;
  int _lineHeight;
  boolean _minimised = false;
  boolean _mouse = false;
  boolean _visible = true;
  PImage _graphic;

  InfoBox(int x, int y, int boxWidth, int boxHeight, int lineHeight, color borderColour, color fillColour, color textColour, String title, ArrayList<String> content, boolean mouse) {
    this._posX = x;
    this._posY = y;
    this._width = boxWidth;
    this._height = boxHeight;
    this._title = title;
    this._data = content;
    this._fillColour = fillColour;
    this._borderColour = borderColour;
    this._textColour = textColour;
    this._lineHeight = lineHeight;
    this._mouse = mouse;
  }

  InfoBox(int x, int y, int boxWidth, int boxHeight, int lineHeight, color borderColour, color fillColour, color textColour, String title, ArrayList<String> content) {
    this._posX = x;
    this._posY = y;
    this._width = boxWidth;
    this._height = boxHeight;
    this._title = title;
    this._data = content;
    this._fillColour = fillColour;
    this._borderColour = borderColour;
    this._textColour = textColour;
    this._lineHeight = lineHeight;
    this._mouse = false;
  }

  InfoBox(int x, int y, int boxWidth, int boxHeight, int lineHeight, color borderColour, color fillColour, color textColour, String title, boolean mouse) {
    this._posX = x;
    this._posY = y;
    this._width = boxWidth;
    this._height = boxHeight;
    this._lineHeight = lineHeight;
    this._borderColour = borderColour;
    this._fillColour = fillColour;
    this._textColour = textColour;
    this._title = title;
    this._mouse = mouse;
  }

  InfoBox(int x, int y, int boxWidth, int boxHeight, int lineHeight, color borderColour, color fillColour, color textColour, String title) {
    this._posX = x;
    this._posY = y;
    this._width = boxWidth;
    this._height = boxHeight;
    this._lineHeight = lineHeight;
    this._borderColour = borderColour;
    this._fillColour = fillColour;
    this._textColour = textColour;
    this._title = title;
    this._mouse = false;
  }

  void setGraphic(PImage graphic) {
    this._graphic = graphic;
  }

  void setFill(color fillColour) {
    this._fillColour = fillColour;
  }

  void setColour(color borderColour, color fillColour, color textColour) {
    this._borderColour = borderColour;
    this._fillColour = fillColour;
    this._textColour = textColour;
  }

  void setTitle(String title) {
    this._title = title;
  }

  void setPos(int x, int y) {
    this._posX = x;
    this._posY = y;
  }

  void setContent(ArrayList<String> content) {
    this._data = content;
  }

  void add(String data) {
    this._data.add(data);
  }

  void clearData() {
    this._data.clear();
  }

  void draw() 
  { 
    int offX = 0;
    int offY = 0;
    if (_graphic != null) {
      this._height = this._graphic.height + 29;
      this._width = this._graphic.width + 4;
    }
    if (_mouse) {
      this._posX = mouseX;
      this._posY = mouseY;
      if (mouseX > width - this._width) {
        offX = -this._width;
      } else {
        offX = 0;
      }
      if (mouseY > (height - this._height)) {
        offY = -this._height;
      } else {
        offY = 0;
      }
    } else {
      if (this._posY < 2) this._posY = 2;
      if ((this._posY + this._height) > height) this._posY = height - (this._height+2);
      if (this._posX < 2) this._posX = 2;
      if ((this._posX + this._width) > width) this._posX = width - (this._width+2);
    }
    textSize(16);
    textAlign(LEFT,BOTTOM);
    int nextItem = 1;
    stroke(_borderColour);
    fill(this._fillColour);
    rect(this._posX+offX,this._posY+offY,this._width,25);
    if (_minimised) {
      this._height = 25;
      rect(this._posX+offX,this._posY+offY,this._width,25);
      fill(this._textColour);
      text(this._title,this._posX+offX+2,this._posY+offY+25);
    } else {
      if (this._graphic == null) {
        this._height = ((this._data.size() + 1) * 25);
      } else {
        this._height = this._graphic.height + 25 + 2;
      }
      rect(this._posX+offX,this._posY+offY,this._width,this._height);
      fill(this._textColour);
      text(this._title,this._posX+offX+2,this._posY+offY+25);
      if (this._graphic != null) {
        image(this._graphic,this._posX+offX+2,this._posY+offY + 25 + 2);
      } else {
        for (String d : _data) { 
          text(d, this._posX+offX+2, this._posY+offY+25 + (this._lineHeight * nextItem));
          nextItem++;
        }
      }
    }
  }
}