package popcraft.util {

/**
 * Adapted from http://www.voidware.com/phase.c
 */
public class MoonCalculation
{
    public static function get isFullMoonToday () :Boolean
    {
        return isFullMoon(new Date());
    }

    public static function isFullMoon (date :Date) :Boolean
    {
        var moonToday :Number = dateToMoonPhase(date);

        date.date -= 1;
        var moonYesterday :Number = dateToMoonPhase(date);

        date.date += 2;
        var moonTomorrow :Number = dateToMoonPhase(date);

        return (moonToday > moonYesterday && moonToday > moonTomorrow);
    }

    public static function dateToMoonPhase (date :Date) :Number
    {
        /*
          Calculates more accurately than Moon_phase , the phase of the moon at
          the given epoch.
          returns the moon phase as a real number (0-1)
          */

        var j :Number = dateToJulian(date)-2444238.5;
        var ls :Number = sun_position(j);
        var lm :Number = moon_position(j, ls);

        var t :Number = lm - ls;
        if (t < 0) { t += 360; }

        /*
        ip is an integer value from 0-7
        public static const PHASE_NEW :int = 0;
        public static const PHASE_WAXING_CRESCENT :int = 1;
        public static const PHASE_FIRST_QUARTER :int = 2;
        public static const PHASE_WAXING_GIBBOUS :int = 3;
        public static const PHASE_FULL :int = 4;
        public static const PHASE_WANING_GIBBOUS :int = 5;
        public static const PHASE_THIRD_QUARTER :int = 6;
        public static const PHASE_WANING_CRESCENT :int = 7;
        var ip :int = ((t + 22.5)/45) & 0x7;
        */

        return (1.0 - Math.cos((lm - ls)*RAD))/2;
    }

    protected static function sun_position (j :Number) :Number
    {
        var n :Number, x :Number, e :Number, l :Number, dl :Number, v :Number;
        var m2 :Number;
        var i :int;

        n=360/365.2422*j;
        i=n/360;
        n=n-i*360.0;
        x=n-3.762863;
        if (x<0) { x += 360; }
        x *= RAD;
        e=x;
        do {
            dl=e-.016718*Math.sin(e)-x;
            e=e-dl/(1-.016718*Math.cos(e));
        } while (Math.abs(dl)>=SMALL_FLOAT);

        v=360/Math.PI*Math.atan(1.01686011182*Math.tan(e/2));
        l=v+282.596403;
        i=l/360;
        l=l-i*360.0;

        return l;
    }

    protected static function moon_position (j :Number, ls :Number) :Number
    {
        var ms :Number, l :Number, mm :Number, n :Number, ev :Number, sms :Number, z :Number, x :Number, lm :Number, bm :Number, ae :Number, ec :Number;
        var d :Number;
        var ds :Number, as_ :Number, dm :Number;
        var i :int;

        /* ls = sun_position(j) */
        ms = 0.985647332099*j - 3.762863;
        if (ms < 0) { ms += 360.0; }
        l = 13.176396*j + 64.975464;
        i = l/360;
        l = l - i*360.0;
        if (l < 0) { l += 360.0; }
        mm = l-0.1114041*j-349.383063;
        i = mm/360;
        mm -= i*360.0;
        n = 151.950429 - 0.0529539*j;
        i = n/360;
        n -= i*360.0;
        ev = 1.2739*Math.sin((2*(l-ls)-mm)*RAD);
        sms = Math.sin(ms*RAD);
        ae = 0.1858*sms;
        mm += ev-ae- 0.37*sms;
        ec = 6.2886*Math.sin(mm*RAD);
        l += ev+ec-ae+ 0.214*Math.sin(2*mm*RAD);
        l= 0.6583*Math.sin(2*(l-ls)*RAD)+l;
        return l;
    }

    protected static function dateToJulian (date :Date) :Number
    {
        var day :Number = date.date + (date.hours / 24);
        var month :int = date.month;
        var year :int = date.fullYear;

        var a :int, b :int, c :int, e :int;

        if (month < 3) {
            year--;
            month += 12;
        }

        if (year > 1582 || (year == 1582 && month>10) || (year == 1582 && month==10 && day > 15)) {
            a=year/100;
            b=2-a+a/4;
        }

        c = 365.25*year;
        e = 30.6001*(month+1);

        return b+c+e+day+1720994.5;
    }

    protected static const RAD :Number = Math.PI / 180.0;
    protected static const SMALL_FLOAT :Number = 1e-12;
}

}
