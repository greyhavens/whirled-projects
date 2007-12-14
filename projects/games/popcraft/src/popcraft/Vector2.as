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


    /** Returns v1 + v2. v1 and v2 are not modified. */
    public static function add (v1 :Vector2, v2 :Vector2) :Vector2
    {
        return new Vector2(v1.x + v2.x, v1.y + v2.y);
    }

    /** Returns v1 - v2. v1 and v2 are not modified. */
    public static function subtract (v1 :Vector2, v2 :Vector2) :Vector2
    {
        return new Vector2(v1.x - v2.x, v1.y - v2.y);
    }

    /** Returns v * val. v is unmodified. */
    public static function scale (v :Vector2, val :Number) :Vector2
    {
        return new Vector2(v.x * val, v.y * val);
    }

    /**
     * Returns the smaller of the two angles between v1 and v2, in radians.
     * Result will be in range [0, pi].
     */
    public static function smallerAngleBetween (v1 :Vector2, v2 :Vector2) :Number
    {
        // v1 dot v2 == |v1||v2|cos(theta)
        // theta = acos ((v1 dot v2) / (|v1||v2|))

        var dot :Number = v1.dot(v2);
        var len1 :Number = v1.length;
        var len2 :Number = v2.length;

        return Math.acos(dot / (len1 * len2));
    }

    /**
     * Creates a Vector2 of magnitude 'len' that that has been rotated about the origin by 'angle'.
     */
    public static function fromAngle (angleRadians :Number, len :Number = 1) :Vector2
    {
       // we use the unit vector (1, 0)

        return new Vector2(
            Math.cos(angleRadians) * len,   // == len * (cos(theta)*x - sin(theta)*y)
            Math.sin(angleRadians) * len);  // == len * (sin(theta)*x + cos(theta)*y)
    }

    /**
     * Converts the Vector2 to a Point.
     */
    public function toPoint () :Point
    {
        return new Point(x, y);
    }

    /** Constructs a Vector2 from the given values. */
    public function Vector2 (x :Number = 0, y :Number = 0)
    {
        this.x = x;
        this.y = y;
    }

    /** Returns a copy of this Vector2. */
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
        var cosTheta :Number = Math.cos(angleRadians);
        var sinTheta :Number = Math.sin(angleRadians);

        var oldX :Number = x;
        x = (cosTheta * oldX) - (sinTheta * y);
        y = (sinTheta * oldX) + (cosTheta * y);
    }

    /** Normalizes the vector. */
    public function normalize () :void
    {
        var len :Number = this.length;

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
     * If ccw = true, the perpendicular vector is rotated 90 degrees counter-clockwise from this vector,
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
