/************************************************
* PVectorD Class - double based inplementation of 
* PVector
*************************************************
* See history.txt
*/

class PVectorD {
    double x;
    double y;
    double z;

    PVectorD() {
    }

    PVectorD(double xx, double yy) {
        this.x=xx;
        this.y=yy;
        this.z=0;
    }

    PVectorD(double xx, double yy, double zz) {
        this.x=xx;
        this.y=yy;
        this.z=zz;
    }

    public PVectorD set (double xx, double yy) {
        this.x=xx;
        this.y=yy;
        return this;
    }

    public PVectorD set (double xx, double yy, double zz) {
        this.x=xx;
        this.y=yy;
        this.z=zz;
        return this;
    }

    public PVectorD set (PVectorD p) {
        this.x=p.x;
        this.y=p.y;
        this.z=p.z;
        return this;
    }


    public String toString() {
        return "[ " + this.x + ", " + this.y + ", " + this.z + " ]";
    }

    public PVectorD copy() {
        return new PVectorD(this.x, this.y, this.z);
    }

    public PVectorD get() {
        return this.copy();
    }

    public double mag() {
        return (double) Math.sqrt(this.x*this.x + this.y*this.y + this.z*this.z);
    }

    public double magSq() {
        return (this.x*this.x + this.y*this.y + this.z*this.z);
    }

    public PVectorD add(PVectorD v) {
        this.x += v.x;
        this.y += v.y;
        this.z += v.z;
        return this;
    }

    public PVectorD add(double x, double y) {
        this.x += x;
        this.y += y;
        return this;
    }

    public PVectorD add(double x, double y, double z) {
        this.x += x;
        this.y += y;
        this.z += z;
        return this;
    }

    public PVectorD sub(PVectorD v) {
        this.x -= v.x;
        this.y -= v.y;
        this.z -= v.z;
        return this;
    }

    public PVectorD sub(double x, double y) {
        this.x -= x;
        this.y -= y;
        return this;
    }

    public PVectorD mult(double n) {
        this.x *= n;
        this.y *= n;
        this.z *= n;
        return this;
    }

    public PVectorD div(double n) {
        this.x /= n;
        this.y /= n;
        this.z /= n;
        return this;
    }

    public double dist(PVectorD v) {
        double dx = x - v.x;
        double dy = y - v.y;
        double dz = z - v.z;
        return (double) Math.sqrt(dx*dx + dy*dy + dz*dz);
    }

    public double dot(PVectorD v) {
        return x*v.x + y*v.y + z*v.z;
    }

    public double dot(double x, double y, double z) {
        return this.x*x + this.y*y + this.z*z;
    }

    public PVectorD cross(PVectorD v) {
        return cross(v, null);
    }

    public PVectorD cross(PVectorD v, PVectorD target) {
        double crossX = y * v.z - v.y * z;
        double crossY = z * v.x - v.z * x;
        double crossZ = x * v.y - v.x * y;

        if (target == null) {
            target = new PVectorD(crossX, crossY, crossZ);
        } else {
            target.set(crossX, crossY, crossZ);
        }
        return target;
    }

    public PVectorD normalize() {
        double m = mag();
        if (m != 0 && m != 1) {
            div(m);
        }
        return this;
    }

    public PVectorD normalize(PVectorD target) {
        if (target == null) {
            target = new PVectorD();
        }
        double m = mag();
        if (m > 0) {
            target.set(x/m, y/m, z/m);
        } else {
            target.set(x, y, z);
        }
        return target;
    }

    public PVectorD limit(double max) {
        if (magSq() > max*max) {
            this.normalize();
            this.mult(max);
        }
        return this;
    }

    public PVectorD setMag(double len) {
        this.normalize();
        this.mult(len);
        return this;
    }

    public PVectorD setMag(PVectorD target, double len) {
        target = this.normalize(target);
        target.mult(len);
        return target;
    }

    public double heading() {
        double angle = (double) Math.atan2(y, x);
        return angle;
    }

    public PVectorD rotate(double theta) {
        double temp = x;
        x = x*Math.cos(theta) - y*Math.sin(theta);
        y = temp*Math.sin(theta) + y*Math.cos(theta);
        return this;
    }

    public double[] array() {
        double[] array = new double[3];
        array[0] = this.x;
        array[1] = this.y;
        array[2] = this.z;
        return array;
    }

    public boolean equals(Object obj) {
        if (!(obj instanceof PVectorD)) {
            return false;
        }
        final PVectorD p = (PVectorD) obj;
        return x == p.x && y == p.y && z == p.z;
    }

    public int hashCode() {
        int result = 1;
        result = 31 * result + Float.floatToIntBits((float)x);
        result = 31 * result + Float.floatToIntBits((float)y);
        result = 31 * result + Float.floatToIntBits((float)z);
        return result;
    }
}