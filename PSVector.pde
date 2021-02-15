import java.io.Serializable;

public class PSVector implements Serializable {
    private static final long serialVersionUID = 1L;

  /**
   * ( begin auto-generated from PSVector_x.xml )
   *
   * The x component of the vector. This field (variable) can be used to both
   * get and set the value (see above example.)
   *
   * ( end auto-generated )
   *
   * @webref pvector:field
   * @usage web_application
   * @brief The x component of the vector
   */
  public double x;

  /**
   * ( begin auto-generated from PSVector_y.xml )
   *
   * The y component of the vector. This field (variable) can be used to both
   * get and set the value (see above example.)
   *
   * ( end auto-generated )
   *
   * @webref pvector:field
   * @usage web_application
   * @brief The y component of the vector
   */
  public double y;

  /**
   * ( begin auto-generated from PSVector_z.xml )
   *
   * The z component of the vector. This field (variable) can be used to both
   * get and set the value (see above example.)
   *
   * ( end auto-generated )
   *
   * @webref pvector:field
   * @usage web_application
   * @brief The z component of the vector
   */
  public double z;

  /** Array so that this can be temporarily used in an array context */
  transient protected double[] array;


  /**
   * Constructor for an empty vector: x, y, and z are set to 0.
   */
  public PSVector() {
  }


  /**
   * Constructor for a 3D vector.
   *
   * @param  x the x coordinate.
   * @param  y the y coordinate.
   * @param  z the z coordinate.
   */
  public PSVector(double x, double y, double z) {
    this.x = x;
    this.y = y;
    this.z = z;
  }


  /**
   * Constructor for a 2D vector: z coordinate is set to 0.
   */
  public PSVector(double x, double y) {
    this.x = x;
    this.y = y;
    this.z = 0;
  }


  /**
   * ( begin auto-generated from PSVector_set.xml )
   *
   * Sets the x, y, and z component of the vector using two or three separate
   * variables, the data from a PSVector, or the values from a double array.
   *
   * ( end auto-generated )
   *
   * @webref pvector:method
   * @param x the x component of the vector
   * @param y the y component of the vector
   * @param z the z component of the vector
   * @brief Set the components of the vector
   */
  public PSVector set(double x, double y, double z) {
    this.x = x;
    this.y = y;
    this.z = z;
    return this;
  }


  /**
   * @param x the x component of the vector
   * @param y the y component of the vector
   */
  public PSVector set(double x, double y) {
    this.x = x;
    this.y = y;
    return this;
  }


  /**
   * @param v any variable of type PSVector
   */
  public PSVector set(PSVector v) {
    x = v.x;
    y = v.y;
    z = v.z;
    return this;
  }


  /**
   * Set the x, y (and maybe z) coordinates using a double[] array as the source.
   * @param source array to copy from
   */
  public PSVector set(double[] source) {
    if (source.length >= 2) {
      x = source[0];
      y = source[1];
    }
    if (source.length >= 3) {
      z = source[2];
    }
    return this;
  }


    public PSVector copy() {
    return new PSVector(x, y, z);
  }


  @Deprecated
  public PSVector get() {
    return copy();
  }


  /**
   * @param target
   */
  public double[] get(double[] target) {
    if (target == null) {
      return new double[] { x, y, z };
    }
    if (target.length >= 2) {
      target[0] = x;
      target[1] = y;
    }
    if (target.length >= 3) {
      target[2] = z;
    }
    return target;
  }


  /**
   * ( begin auto-generated from PSVector_mag.xml )
   *
   * Calculates the magnitude (length) of the vector and returns the result
   * as a double (this is simply the equation <em>sqrt(x*x + y*y + z*z)</em>.)
   *
   * ( end auto-generated )
   *
   * @webref pvector:method
   * @usage web_application
   * @brief Calculate the magnitude of the vector
   * @return magnitude (length) of the vector
   * @see PSVector#magSq()
   */
  public double mag() {
    return (double) Math.sqrt(x*x + y*y + z*z);
  }


  /**
   * ( begin auto-generated from PSVector_mag.xml )
   *
   * Calculates the squared magnitude of the vector and returns the result
   * as a double (this is simply the equation <em>(x*x + y*y + z*z)</em>.)
   * Faster if the real length is not required in the
   * case of comparing vectors, etc.
   *
   * ( end auto-generated )
   *
   * @webref pvector:method
   * @usage web_application
   * @brief Calculate the magnitude of the vector, squared
   * @return squared magnitude of the vector
   * @see PSVector#mag()
   */
  public double magSq() {
    return (x*x + y*y + z*z);
  }


  /**
   * ( begin auto-generated from PSVector_add.xml )
   *
   * Adds x, y, and z components to a vector, adds one vector to another, or
   * adds two independent vectors together. The version of the method that
   * adds two vectors together is a static method and returns a PSVector, the
   * others have no return value -- they act directly on the vector. See the
   * examples for more context.
   *
   * ( end auto-generated )
   *
   * @webref pvector:method
   * @usage web_application
   * @param v the vector to be added
   * @brief Adds x, y, and z components to a vector, one vector to another, or two independent vectors
   */
  public PSVector add(PSVector v) {
    x += v.x;
    y += v.y;
    z += v.z;
    return this;
  }


  /**
   * @param x x component of the vector
   * @param y y component of the vector
   */
  public PSVector add(double x, double y) {
    this.x += x;
    this.y += y;
    return this;
  }


  /**
   * @param z z component of the vector
   */
  public PSVector add(double x, double y, double z) {
    this.x += x;
    this.y += y;
    this.z += z;
    return this;
  }


  /**
   * Add two vectors
   * @param v1 a vector
   * @param v2 another vector
   */
  public PSVector add(PSVector v1, PSVector v2) {
    return add(v1, v2, null);
  }


  /**
   * Add two vectors into a target vector
   * @param target the target vector (if null, a new vector will be created)
   */
  public PSVector add(PSVector v1, PSVector v2, PSVector target) {
    if (target == null) {
      target = new PSVector(v1.x + v2.x,v1.y + v2.y, v1.z + v2.z);
    } else {
      target.set(v1.x + v2.x, v1.y + v2.y, v1.z + v2.z);
    }
    return target;
  }


  /**
   * ( begin auto-generated from PSVector_sub.xml )
   *
   * Subtracts x, y, and z components from a vector, subtracts one vector
   * from another, or subtracts two independent vectors. The version of the
   * method that subtracts two vectors is a static method and returns a
   * PSVector, the others have no return value -- they act directly on the
   * vector. See the examples for more context.
   *
   * ( end auto-generated )
   *
   * @webref pvector:method
   * @usage web_application
   * @param v any variable of type PSVector
   * @brief Subtract x, y, and z components from a vector, one vector from another, or two independent vectors
   */
  public PSVector sub(PSVector v) {
    x -= v.x;
    y -= v.y;
    z -= v.z;
    return this;
  }


  /**
   * @param x the x component of the vector
   * @param y the y component of the vector
   */
  public PSVector sub(double x, double y) {
    this.x -= x;
    this.y -= y;
    return this;
  }


  /**
   * @param z the z component of the vector
   */
  public PSVector sub(double x, double y, double z) {
    this.x -= x;
    this.y -= y;
    this.z -= z;
    return this;
  }


  /**
   * Subtract one vector from another
   * @param v1 the x, y, and z components of a PSVector object
   * @param v2 the x, y, and z components of a PSVector object
   */
  public PSVector sub(PSVector v1, PSVector v2) {
    return sub(v1, v2, null);
  }


  /**
   * Subtract one vector from another and store in another vector
   * @param target PSVector in which to store the result
   */
  public PSVector sub(PSVector v1, PSVector v2, PSVector target) {
    if (target == null) {
      target = new PSVector(v1.x - v2.x, v1.y - v2.y, v1.z - v2.z);
    } else {
      target.set(v1.x - v2.x, v1.y - v2.y, v1.z - v2.z);
    }
    return target;
  }


  /**
   * ( begin auto-generated from PSVector_mult.xml )
   *
   * Multiplies a vector by a scalar or multiplies one vector by another.
   *
   * ( end auto-generated )
   *
   * @webref pvector:method
   * @usage web_application
   * @brief Multiply a vector by a scalar
   * @param n the number to multiply with the vector
   */
  public PSVector mult(double n) {
    x *= n;
    y *= n;
    z *= n;
    return this;
  }


  /**
   * @param v the vector to multiply by the scalar
   */
  public PSVector mult(PSVector v, double n) {
    return mult(v, n, null);
  }


  /**
   * Multiply a vector by a scalar, and write the result into a target PSVector.
   * @param target PSVector in which to store the result
   */
  public PSVector mult(PSVector v, double n, PSVector target) {
    if (target == null) {
      target = new PSVector(v.x*n, v.y*n, v.z*n);
    } else {
      target.set(v.x*n, v.y*n, v.z*n);
    }
    return target;
  }


  /**
   * ( begin auto-generated from PSVector_div.xml )
   *
   * Divides a vector by a scalar or divides one vector by another.
   *
   * ( end auto-generated )
   *
   * @webref pvector:method
   * @usage web_application
   * @brief Divide a vector by a scalar
   * @param n the number by which to divide the vector
   */
  public PSVector div(double n) {
    x /= n;
    y /= n;
    z /= n;
    return this;
  }


  /**
   * Divide a vector by a scalar and return the result in a new vector.
   * @param v the vector to divide by the scalar
   * @return a new vector that is v1 / n
   */
  public PSVector div(PSVector v, double n) {
    return div(v, n, null);
  }


  /**
   * Divide a vector by a scalar and store the result in another vector.
   * @param target PSVector in which to store the result
   */
  public PSVector div(PSVector v, double n, PSVector target) {
    if (target == null) {
      target = new PSVector(v.x/n, v.y/n, v.z/n);
    } else {
      target.set(v.x/n, v.y/n, v.z/n);
    }
    return target;
  }


  /**
   * ( begin auto-generated from PSVector_dist.xml )
   *
   * Calculates the Euclidean distance between two points (considering a
   * point as a vector object).
   *
   * ( end auto-generated )
   *
   * @webref pvector:method
   * @usage web_application
   * @param v the x, y, and z coordinates of a PSVector
   * @brief Calculate the distance between two points
   */
  public double dist(PSVector v) {
    double dx = x - v.x;
    double dy = y - v.y;
    double dz = z - v.z;
    return (double) Math.sqrt(dx*dx + dy*dy + dz*dz);
  }


  /**
   * @param v1 any variable of type PSVector
   * @param v2 any variable of type PSVector
   * @return the Euclidean distance between v1 and v2
   */
  public double dist(PSVector v1, PSVector v2) {
    double dx = v1.x - v2.x;
    double dy = v1.y - v2.y;
    double dz = v1.z - v2.z;
    return (double) Math.sqrt(dx*dx + dy*dy + dz*dz);
  }


  /**
   * ( begin auto-generated from PSVector_dot.xml )
   *
   * Calculates the dot product of two vectors.
   *
   * ( end auto-generated )
   *
   * @webref pvector:method
   * @usage web_application
   * @param v any variable of type PSVector
   * @return the dot product
   * @brief Calculate the dot product of two vectors
   */
  public double dot(PSVector v) {
    return x*v.x + y*v.y + z*v.z;
  }


  /**
   * @param x x component of the vector
   * @param y y component of the vector
   * @param z z component of the vector
   */
  public double dot(double x, double y, double z) {
    return this.x*x + this.y*y + this.z*z;
  }


  /**
   * @param v1 any variable of type PSVector
   * @param v2 any variable of type PSVector
   */
  public double dot(PSVector v1, PSVector v2) {
    return v1.x*v2.x + v1.y*v2.y + v1.z*v2.z;
  }


  /**
   * ( begin auto-generated from PSVector_cross.xml )
   *
   * Calculates and returns a vector composed of the cross product between
   * two vectors.
   *
   * ( end auto-generated )
   *
   * @webref pvector:method
   * @param v the vector to calculate the cross product
   * @brief Calculate and return the cross product
   */
  public PSVector cross(PSVector v) {
    return cross(v, null);
  }


  /**
   * @param v any variable of type PSVector
   * @param target PSVector to store the result
   */
  public PSVector cross(PSVector v, PSVector target) {
    double crossX = y * v.z - v.y * z;
    double crossY = z * v.x - v.z * x;
    double crossZ = x * v.y - v.x * y;

    if (target == null) {
      target = new PSVector(crossX, crossY, crossZ);
    } else {
      target.set(crossX, crossY, crossZ);
    }
    return target;
  }


  /**
   * @param v1 any variable of type PSVector
   * @param v2 any variable of type PSVector
   * @param target PSVector to store the result
   */
  public PSVector cross(PSVector v1, PSVector v2, PSVector target) {
    double crossX = v1.y * v2.z - v2.y * v1.z;
    double crossY = v1.z * v2.x - v2.z * v1.x;
    double crossZ = v1.x * v2.y - v2.x * v1.y;

    if (target == null) {
      target = new PSVector(crossX, crossY, crossZ);
    } else {
      target.set(crossX, crossY, crossZ);
    }
    return target;
  }


  /**
   * ( begin auto-generated from PSVector_normalize.xml )
   *
   * Normalize the vector to length 1 (make it a unit vector).
   *
   * ( end auto-generated )
   *
   * @webref pvector:method
   * @usage web_application
   * @brief Normalize the vector to a length of 1
   */
  public PSVector normalize() {
    double m = mag();
    if (m != 0 && m != 1) {
      div(m);
    }
    return this;
  }


  /**
   * @param target Set to null to create a new vector
   * @return a new vector (if target was null), or target
   */
  public PSVector normalize(PSVector target) {
    if (target == null) {
      target = new PSVector();
    }
    double m = mag();
    if (m > 0) {
      target.set(x/m, y/m, z/m);
    } else {
      target.set(x, y, z);
    }
    return target;
  }


  /**
   * ( begin auto-generated from PSVector_limit.xml )
   *
   * Limit the magnitude of this vector to the value used for the <b>max</b> parameter.
   *
   * ( end auto-generated )
   *
   * @webref pvector:method
   * @usage web_application
   * @param max the maximum magnitude for the vector
   * @brief Limit the magnitude of the vector
   */
  public PSVector limit(double max) {
    if (magSq() > max*max) {
      normalize();
      mult(max);
    }
    return this;
  }


  /**
   * ( begin auto-generated from PSVector_setMag.xml )
   *
   * Set the magnitude of this vector to the value used for the <b>len</b> parameter.
   *
   * ( end auto-generated )
   *
   * @webref pvector:method
   * @usage web_application
   * @param len the new length for this vector
   * @brief Set the magnitude of the vector
   */
  public PSVector setMag(double len) {
    normalize();
    mult(len);
    return this;
  }


  /**
   * Sets the magnitude of this vector, storing the result in another vector.
   * @param target Set to null to create a new vector
   * @param len the new length for the new vector
   * @return a new vector (if target was null), or target
   */
  public PSVector setMag(PSVector target, double len) {
    target = normalize(target);
    target.mult(len);
    return target;
  }


  /**
   * ( begin auto-generated from PSVector_setMag.xml )
   *
   * Calculate the angle of rotation for this vector (only 2D vectors)
   *
   * ( end auto-generated )
   *
   * @webref pvector:method
   * @usage web_application
   * @return the angle of rotation
   * @brief Calculate the angle of rotation for this vector
   */
  public double heading() {
    double angle = (double) Math.atan2(y, x);
    return angle;
  }


  @Deprecated
  public double heading2D() {
    return heading();
  }


  /**
   * ( begin auto-generated from PSVector_rotate.xml )
   *
   * Rotate the vector by an angle (only 2D vectors), magnitude remains the same
   *
   * ( end auto-generated )
   *
   * @webref pvector:method
   * @usage web_application
   * @brief Rotate the vector by an angle (2D only)
   * @param theta the angle of rotation
   */
  public PSVector rotate(double theta) {
    double temp = x;
    // Might need to check for rounding errors like with angleBetween function?
    x = x*(double)Math.cos((double)theta) - y*(double)Math.sin((double)theta);
    y = temp*(double)Math.sin((double)theta) + y*(double)Math.cos((double)theta);
    return this;
  }

  
  /**
   * ( begin auto-generated from PSVector_angleBetween.xml )
   *
   * Calculates and returns the angle (in radians) between two vectors.
   *
   * ( end auto-generated )
   *
   * @webref pvector:method
   * @usage web_application
   * @param v1 the x, y, and z components of a PSVector
   * @param v2 the x, y, and z components of a PSVector
   * @brief Calculate and return the angle between two vectors
   */
  public double angleBetween(PSVector v1, PSVector v2) {

    // We get NaN if we pass in a zero vector which can cause problems
    // Zero seems like a reasonable angle between a (0,0,0) vector and something else
    if (v1.x == 0 && v1.y == 0 && v1.z == 0 ) return 0.0f;
    if (v2.x == 0 && v2.y == 0 && v2.z == 0 ) return 0.0f;

    double dot = v1.x * v2.x + v1.y * v2.y + v1.z * v2.z;
    double v1mag = Math.sqrt(v1.x * v1.x + v1.y * v1.y + v1.z * v1.z);
    double v2mag = Math.sqrt(v2.x * v2.x + v2.y * v2.y + v2.z * v2.z);
    // This should be a number between -1 and 1, since it's "normalized"
    double amt = dot / (v1mag * v2mag);
    // But if it's not due to rounding error, then we need to fix it
    // http://code.google.com/p/processing/issues/detail?id=340
    // Otherwise if outside the range, acos() will return NaN
    // http://www.cppreference.com/wiki/c/math/acos
    if (amt <= -1) {
      return (double)Math.PI;
    } else if (amt >= 1) {
      // http://code.google.com/p/processing/issues/detail?id=435
      return 0;
    }
    return (double) Math.acos(amt);
  }


  @Override
  public String toString() {
    return "[ " + x + ", " + y + ", " + z + " ]";
  }


  /**
   * ( begin auto-generated from PSVector_array.xml )
   *
   * Return a representation of this vector as a double array. This is only
   * for temporary use. If used in any other fashion, the contents should be
   * copied by using the <b>PSVector.get()</b> method to copy into your own array.
   *
   * ( end auto-generated )
   *
   * @webref pvector:method
   * @usage: web_application
   * @brief Return a representation of the vector as a double array
   */
  public double[] array() {
    if (array == null) {
      array = new double[3];
    }
    array[0] = x;
    array[1] = y;
    array[2] = z;
    return array;
  }


  @Override
  public boolean equals(Object obj) {
    if (!(obj instanceof PSVector)) {
      return false;
    }
    final PSVector p = (PSVector) obj;
    return x == p.x && y == p.y && z == p.z;
  }


//   @Override
//   public int hashCode() {
//     int result = 1;
//     result = 31 * result + Double.doubleToIntBits(x);
//     result = 31 * result + Float.doubleToIntBits(y);
//     result = 31 * result + Float.doubleToIntBits(z);
//     return result;
//   }
}