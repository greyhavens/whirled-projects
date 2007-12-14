package popcraft {
    import flash.geom.Point;


public class Vector2
{
    public var x :Number = 0;
    public var y :Number = 0;

    /**
     * Infinite vector - often the result of normalizing a zero vector.
     */
    public static const INFINITE :Vector2 = new Vector2(Infinity, Infinity);

    /**
     * Converts Point p to a Vector2.
     */
    public static function fromPoint (p :Point) :Vector2
    {
        return new Vector2(p.x, p.y);
    }

    /**
     * Creates a Vector2 of magnitude 'len' that that has been rotated about the origin by 'angle'.
     */
    public static function fromAngle (angleRadians :Number, len :Number = 1)
    {
        var cosTheta :Number = Math.cos(angleRadians);
        var sinTheta :Number = Math.sin(angleRadians);

        // we use the unit vector (1, 0)

        return new Vector2(
            Math.cos(angleRadians) * len,   // == len * (cos(theta)*x - sin(theta)*y)
            Math.sin(angleRadians) * len);  // == len * (sin(theta)*x + cos(theta)*y)
    }

    public function Vector2 (x :Number = 0, y :Number = 0)
    {
        this.x = x;
        this.y = y;
    }

    public function clone () :Vector2
    {
        return new Vector2(x, y);
    }

    /** Returns this vector's length. */
    public function get length () :Number
    {
        if (this == INFINITE || x == Infinity || y == Infinity) {
            return Infinity;
        } else {
            return Math.sqrt(x * x + y * y);
        }
    }

    /** Sets this vector's length. */
    public function set length (newLen :Number) :void
    {
        var curLen :Number = this.length;
        if (curLen == Infinity) {
            return;
        } else {
            var scale :Number = newLen / curLen;
            x *= scale;
            y *= scale;
        }
    }

    /** Returns the square of this vector's length. */
    public function get lengthSquared () :Number
    {
        if (this == INFINITE || x == Infinity || y == Infinity) {
            return Infinity;
        } else {
            return (x * x + y * y);
        }
    }

    /** Rotates the vector by 'angleRadians' radians. */
    public function rotate (angleRadians :Number) :void
    {
        var cosTheta = Math.cos(angleRadians);
        var sinTheta = Math.sin(angleRadians);

        var oldX :Number = x;
        x = (cosTheta * oldX) - (sinTheta * y);
        y = (sinTheta * oldX) + (cosTheta * y);
    }

    /** Normalizes the vector. */
    public function normalize () :void
    {
        var len :Number = length();

        x /= len;
        y /= len;
    }

    /** Returns the dot product of this vector with vector v. */
    public function dot (v :Vector2) :Number
    {
        return x * v.x + y * v.y;
    }

    /** Adds another Vector2 to this. */
    public function add (v :Vector2) :void
    {
        x += v.x;
        y += v.y;
    }

    /** Subtracts another vector from this. */
    public function subtract (v :Vector2) :void
    {
        x -= v.x;
        y -= v.y;
    }

    /**
     * Returns a vector that is perpendicular to this.
     * If ccw = true, the perpendicular vector is rotated 90 degrees counter-clockwise rotation from this vector,
     * otherwise it's rotated 90 degrees clockwise.
     */
    public function getPerp (ccw :Boolean = true) :Vector2
    {
        if (ccw) {
            return new Vector2(-y, x);
        } else {
            return new Vector2(y, -x);
        }
    }

    /**
     * Scales this vector by value.
     */
    public function scale (value :Number) :void
    {
        x *= value;
        y *= value;
    }

    /**
     * Returns a new vector that is the linear interpolation of vectors a and b
     * at proportion p, where p is in [0, 1], p = 0 means the result is equal to a,
     * and p = 1 means the result is equal to b.
     */
    public static function interpolate (a :Vector2, b :Vector2, p :Number) :Vector2
    {
        // todo: maybe convert this into a non-static function, to fit the rest of the class?
        var q :Number = 1 - p;
        return new Vector2(q * a.x + p * b.x,
                           q * a.y + p * b.y);
    }

    public function toString () :String
    {
        return "[" + x + ", " + y + "]";
    }
}

}
