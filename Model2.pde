class Model2 extends PSystem {
//  String _model = "Random Walkers";
  Model2(int size, float particleRange, float particleRepulse, float obstacleRange, float cohesionBias, float repulsionBias, float obstacleBias, float directionBias) {
    super(size, particleRange, particleRepulse, obstacleRange, cohesionBias, repulsionBias, obstacleBias, directionBias);
    _model = "Random Walkers";
  }

  Model2() {
    super();    
    _model = "Random Walkers";
  }

  void update(boolean run, boolean dest, boolean perimCoord, boolean perimCompress) {
/** 
* Update system - Updates particle positions based on forces and displays the result.
* 
* @param run Enables and disables the update of the particle velocities to freeze particle positions.
* @param dest Enables and disables the destination vector
* @param perimCoord Enables and disables the perimeter only directional vector
* @param perimCompress Enables and disables the reduction of the perimeter agents repulsion range
*/
    String pData = "";
    PVector move = new PVector(0,0,0);
    for(Particle p : particles) {      
      move = PVector.random2D();
      move.setMag(p._topspeed);
      p.setChange(move);
    }
    if (run) {
      _swarmDirection.set(0,0,0);
      for(Particle p : particles) {
        _swarmDirection.add(p._resultant);
        p.update();
      }
    }
  }

  PVector cohesion(Particle p, boolean perimCompress) {
    return new PVector(0,0,0);
  };
  PVector repulsion(Particle p, boolean perimCompress) {
    return new PVector(0,0,0);
  };

}
