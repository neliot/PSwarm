class PVectorDFactory {
    PRNG rand = new PRNG();

    PVectorDFactory() {
    }

    public PVectorD add(PVectorD v1, PVectorD v2) {
        PVectorD result = new PVectorD((v1.x + v2.x),(v1.y + v2.y),(v1.z + v2.z));
        return result;
    }

    public PVectorD add(PVectorD v1, PVectorD v2, PVectorD target) {
        if (target == null) {
            target = new PVectorD(v1.x + v2.x, v1.y + v2.y, v1.z + v2.z);
        } else {
            target.set(v1.x + v2.x, v1.y + v2.y, v1.z + v2.z);
        }
        return target;
    }
    
    public PVectorD sub(PVectorD v1, PVectorD v2) {
        PVectorD result = new PVectorD((v1.x - v2.x),(v1.y - v2.y),(v1.z - v2.z));
        return result;
    }

    public PVectorD sub(PVectorD v1, PVectorD v2, PVectorD target) {
        if (target == null) {
            target = new PVectorD(v1.x - v2.x, v1.y - v2.y, v1.z - v2.z);
        } else {
            target.set(v1.x - v2.x, v1.y - v2.y, v1.z - v2.z);
        }
        return target;
    }

    public PVectorD mult(PVectorD v, double n, PVectorD target) {
        if (target == null) {
            target = new PVectorD(v.x*n, v.y*n, v.z*n);
        } else {
            target.set(v.x*n, v.y*n, v.z*n);
        }
        return target;
    }

    public PVectorD div(PVectorD v, double n) {
        v.set(v.x*n, v.y*n, v.z*n);
        return div(v, n, null);
    }

    public PVectorD div(PVectorD v, double n, PVectorD target) {
        if (target == null) {
        target = new PVectorD(v.x/n, v.y/n, v.z/n);
        } else {
        target.set(v.x/n, v.y/n, v.z/n);
        }
        return target;
    }

    public double dist(PVectorD v1, PVectorD v2) {
        double dx = v1.x - v2.x;
        double dy = v1.y - v2.y;
        double dz = v1.z - v2.z;
        return Math.sqrt(dx*dx + dy*dy + dz*dz);
    }

    public double dot(PVectorD v1, PVectorD v2) {
        return v1.x*v2.x + v1.y*v2.y + v1.z*v2.z;
    }

    public PVectorD cross(PVectorD v1, PVectorD v2, PVectorD target) {
        double crossX = v1.y * v2.z - v2.y * v1.z;
        double crossY = v1.z * v2.x - v2.z * v1.x;
        double crossZ = v1.x * v2.y - v2.x * v1.y;

        if (target == null) {
            target = new PVectorD(crossX, crossY, crossZ);
        } else {
            target.set(crossX, crossY, crossZ);
        }
        return target;
    }

    public PVectorD random2D() {
        PVectorD result = new PVectorD(0.5-rand.nextDouble(),0.5-rand.nextDouble());
        result.setMag(1);
        return result;
    }

    public double angleBetween(PVectorD v1, PVectorD v2) {

        if (v1.x == 0 && v1.y == 0 && v1.z == 0 ) return 0.0d;
        if (v2.x == 0 && v2.y == 0 && v2.z == 0 ) return 0.0d;

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
            return Math.PI;
        } else if (amt >= 1) {
        // http://code.google.com/p/processing/issues/detail?id=435
            return 0;
        }
        return Math.acos(amt);
    }
}