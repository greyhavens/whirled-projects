package popcraft.util {

/**
 File:      MoonCalculation.java
 Author:    Angus McIntyre <angus@pobox.com>
 Date:      31.05.96
 Updated:   01.06.96

 Java class to calculate the phase of the moon, given a date. The
 'moonPhase' method is a Java port of some public domain C source which
 was apparently originally part of the Decus C distribution (whatever
 that was). Details of the algorithm are given below.

 To use this in a program, create an object of class 'MoonCalculation'.

 I'm not convinced that the algorithm is entirely accurate, but I don't
 know enough to confirm whether it is or not.

    HISTORY
    -------

    31.05.96    SLAM    Converted from C
    01.06.96    SLAM    Added 'phaseName' to return the name of a phase.
                        Fixed leap year test in 'daysInMonth'.

    LEGAL
    -----

    This software is free. It can be used and modified in any way you
    choose. The author assumes no liability for any loss or damage you
    may incur through use of or inability to use this software. This
    disclaimer must appear on any modified or unmodified version of
    the software in which the name of the author also appears.

**/

public class MoonCalculation
{
    public static const PHASE_NEW :int = 0;
    public static const PHASE_WAXING_CRESCENT :int = 1;
    public static const PHASE_FIRST_QUARTER :int = 2;
    public static const PHASE_WAXING_GIBBOUS :int = 3;
    public static const PHASE_FULL :int = 4;
    public static const PHASE_WANING_GIBBOUS :int = 5;
    public static const PHASE_THIRD_QUARTER :int = 6;
    public static const PHASE_WANING_CRESCENT :int = 7;

    public static function get isFullMoonToday () :Boolean
    {
        return (moonPhaseFromDate(new Date()) == PHASE_FULL);
    }

    public static function moonPhaseFromDate (date :Date) :int
    {
        return moonPhase(date.fullYear, date.month + 1, date.date);
    }

    // MoonPhase
    //
    // Output the phase of the moon for the given year, month, day.
    // The routine calculates the year's epact (the age of the moon on Jan 1.),
    // adds this to the number of days in the year, and calculates the phase
    // of the moon for this date.
    //
    // In the algorithm:
    //
    //      diy     Is the day of the year - 1 (i.e., Jan 1 is day 0).
    //
    //      golden  Is the number of the year in the Mentonic cycle, used to
    //              determine the position of the calender moon.
    //
    //      epact   Is the age of the calender moon (in days) at the beginning
    //              of the year.  To calculate epact, two century-based
    //              corrections are applied:
    //              Gregorian:      (3 * cent)/4 - 12
    //                      is the number of years such as 1700, 1800 when
    //                      leap year was not held.
    //              Clavian:        (((8 * cent) + 5) / 25) - 5
    //                      is a correction to the Mentonic cycle of about
    //                      8 days every 2500 years.  Note that this will
    //                      overflow 16 bits in the year 409600.  Beware.
    //
    // The algorithm is accurate for the Gregorian calender only.
    //
    // The magic numbers used in the phase calculation are as follows:
    //       29.5           The moon's period in days.
    //      177             29.5 scaled by 6
    //       22             (29.5 / 8) scaled by 6 (this gets the phase)
    //       11             ((29.5 / 8) / 2) scaled by 6
    //
    // Theoretically, this should yield a number in the range 0 .. 7.  However,
    // two days per year, things don't work out too well.
    //
    // Epact is calculated by the algorithm given in Knuth vol. 1 (calculation
    // of Easter).  See also the article on Calenders in the Encyclopaedia
    // Britannica and Knuth's algorithm in CACM April 1962, page 209.
    //
    // Arguments to the function are:
    //
    // int     year     1978 = 1978
    // int     month    Jan = 1
    // int     day      1 = 1

    public static function moonPhase (year :int, month :int, day :int) :int
    {
        var             phase :int;          // Moon phase
        var             cent :int;           // Century number (1979 = 20)
        var             epact :int;          // Age of the moon on Jan. 1
        var             diy :int;            // Day in the year
        var             golden :int;         // Moon's golden number

        if (month < 0 || month > 12) {
            month = 0;     // Just in case
        }

        diy = day + DAY_YEAR[month];                // Day in the year

        if ((month > 2) && isLeapYearP(year)) {
            diy++;                                  // Leapyear fixup
        }

        cent = (year / 100) + 1;                    // Century number
        golden = (year % 19) + 1;                   // Golden number
        epact = ((11 * golden) + 20                 // Golden number
                + (((8 * cent) + 5) / 25) - 5       // 400 year cycle
                - (((3 * cent) / 4) - 12)) % 30;    //Leap year correction

        if (epact <= 0) {
                epact += 30;                        // Age range is 1 .. 30
        }

        if ((epact == 25 && golden > 11) || epact == 24) {
                epact++;
        }
        // Calculate the phase, using the magic numbers defined above.
        // Note that (phase and 7) is equivalent to (phase mod 8) and
        // is needed on two days per year (when the algorithm yields 8).

        phase = (((((diy + epact) * 6) + 11) % 177) / 22) & 7;

        return phase;
    }

    // daysInMonth
    //
    // Returns the number of days in a month given the month and the year.

    protected static function daysInMonth (month :int, year :int) :int
    {
        var result :int = 31;
        switch (month) {
            case 4:
            case 6:
            case 9:
            case 11:
                result = 30;
                break;
            case 2:
                result = ( isLeapYearP(year) ? 29 : 28 );
        }

        return result;
    }

    // isLeapYearP
    //
    // Return true if the year is a leapyear

    protected static function isLeapYearP (year :int) :Boolean
    {
        return ((year % 4 == 0) &&
                ((year % 400 == 0) || (year % 100 != 0)));
    }

    // DAY_YEAR - gives the day of the year for the first day of each
    // month -1. i.e. 1st January is the 0th day of the year, 1st
    // February is the 31st etc. Used by 'moonPhase'.

    private static const DAY_YEAR :Array =   [ -1, -1, 30, 58, 89, 119,
                                               150, 180, 211, 241, 272,
                                               303, 333 ];
}

}
