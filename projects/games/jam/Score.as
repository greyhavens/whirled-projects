package {


/**
 * The score class holds the data about notes currently being played.
 */
public class Score
{
    /** Beats per minute. */
    public static const BPM :int = 120;

    /** Time delta between beats (in seconds). */
    public static const DT_PER_BEAT :Number = 60.0 / BPM;

    /** Total number of beats per measure. */
    public static const BEATS :int = 16;

    /** Total number of participants. */
    public static const PARTICIPANTS :int = 4;

    /** Constant that signifies a given beat was not specified. */
    public static const BEAT_NONE :int = -1;
    
    /**
     * Score is an array of tracks, one per participant, which contain arrays of notes.
     */
    public var score :Array = new Array();

    /**
     * Envelope settings per participant.
     */
    public var env :Array = new Array();
    
    public function Score ()
    {
        score = new Array(PARTICIPANTS);
        env = new Array(PARTICIPANTS);

        for (var i :int = 0; i < PARTICIPANTS; i++) {
            env[i] = [0, 0, 0, 0, 0, 0];
            score[i] = new Array(BEATS);
            for (var b :int = 0; b < BEATS; b++) {
                score[i][b] = BEAT_NONE;
            }
        }
    }

    public function getBeat (playerIndex :int, beatIndex :int) :int
    {
        return score[playerIndex][beatIndex];
    }

    public function setBeat (playerIndex :int, beatIndex :int, note :Number) :void
    {
        score[playerIndex][beatIndex] = note;
    }

    public function setEnvelope (playerIndex :int, values :Array) :void
    {
        env[playerIndex] = values;
    }

    public function applyEnvelope (playerIndex :int, generator :NoteGenerator) :void
    {
        if (env[playerIndex].length == 6) {
            generator.setEnvelope.apply(generator, env[playerIndex]);
        }
    }

    
}
}
