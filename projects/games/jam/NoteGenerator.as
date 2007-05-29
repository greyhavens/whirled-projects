package
{

public class NoteGenerator extends AudioNode
{
    protected var _f :Number;
    protected var _score :Score;
    protected var _player :int;

    // ADSR envelope, as a collection of points, where x is the time since the start
    // of the note in seconds, and y is the gain in [0, 1].
    protected var envelope :Array = new Array();

    // Relative volumes of the harmonic overtones. 
    protected var overtones :Array = new Array();
    
    protected var noteIndex :int = -1;
    protected var envelopeIndex :int = 0;

    protected var nextNoteStart :Number = 0; // in seconds since _globalStartTime
    protected var tNote :Number = 0; // in seconds since beginning of this note


    public function NoteGenerator (format :SoundFormat, score :Score, playerIndex :int)
    {
        super(format);
        _f = noteToFrequency(60); // initial note: middle C
        _score = score;
        _player = playerIndex;
        
        score.applyEnvelope(playerIndex, this);
        setOvertones();
    }

    /**
     * Sets the ADSR envelope for this note generator. All time values are measured in seconds,
     * and all volume values are in [0, 1], meaning no volume to full volume, respectively.
     * @param dt_v Length of attack, when volume increases from 0 to maxVolume.
     * @param dt_d Length of decay, when volume transitions from maxVolume to sustainVolume
     * @param dt_s Length of sustain, when volume stays at sustainVolume
     * @param dt_r Length of release, when volume decreases from sustainVolume back to 0
     * @param maxVolume Volume at the end of the attack phase
     * @param sustainVolume Volume during the sustain phase
     */     
    public function setEnvelope (
        dt_v :Number, dt_d :Number, dt_s :Number, dt_r :Number,
        maxVolume :Number, sustainVolume :Number) :void
    {
        var last :Env = null;
        envelope = new Array(6);
        last = envelope[0] = new Env(0, 0);                         // beginning of attack
        last = envelope[1] = new Env(last.t + dt_v, maxVolume);     // end of attack
        last = envelope[2] = new Env(last.t + dt_d, sustainVolume); // end of decay
        last = envelope[3] = new Env(last.t + dt_s, sustainVolume); // end of sustain
        last = envelope[4] = new Env(last.t + dt_r, 0);             // end of release
        envelope[5] = new Env(last.t + 1000, 0); // very very big number :)            
    }

    /**
     * Sets the relative values of harmonic overtones. Only the first three are supported.
     * @param vf relative volume of the fundamental tone (should be 1)
     * @param v2f relative volume of the first overtone (at frequency 2 * f)
     * @param v3f relative volume of the second overtone (at frequency 3 * f)
     * @param v4f relative volume of the third overtone (at frequency 4 * f)
     */
    public function setOvertones (
        vf :Number = 1, v2f :Number = 0, v3f :Number = 0, v4f :Number = 0) :void
    {
        overtones = new Array(5);
        overtones[0] = 0;   // dummy value, do not use
        overtones[1] = vf;  
        overtones[2] = v2f;
        overtones[3] = v3f;
        overtones[4] = v4f;
    }
     
    // documentation inherited from AudioNode
    override public function generateSamples (startTime :Number, buffer :Array) :void
    {
        var t :Number = startTime;                    // global time (used for sine wave)
        var dt :Number = 1 / _soundFormat.sampleRate; // time change per sample

        var x :Number = 2 * Math.PI * t;              // global phase, resuling in 1Hz wave
        var dx :Number = 2 * Math.PI * dt;            // phase change per sample

        // envelope parameters
        var e1 :Env, e2 :Env;        // current envelope segment end-points
        var v :Number, dv :Number;   // volume and rate of change per sample 
        var tSegment :Number = 0;    // time in current segment

        var updateEnvelopeParameters :Function = function () :void {
          e1 = envelope[envelopeIndex];
          e2 = envelope[envelopeIndex + 1];
          dv = computeVolumeDelta(e1, e2) * dt;  // volume change per sample
          tSegment = tNote - e1.t;               // time since segment started
          v = e1.v + dv * _soundFormat.sampleRate * tSegment;  // forcing volume to initial value
        }

        updateEnvelopeParameters();

        for (var i :int = 0; i < _soundFormat.bufferSize; ++i)
        {
            // check if we need to switch to a new note
            if (t >= nextNoteStart) {

                // pick the next note, update timestamps
                noteIndex = (noteIndex + 1) % Score.BEATS;
                var note :Number = _score.getBeat(_player, noteIndex);
                if (note != Score.BEAT_NONE) {
                    _f = noteToFrequency(note);
                    tNote = 0;

                    // reset the envelope
                    tSegment = 0;
                    envelopeIndex = 0;
                    updateEnvelopeParameters();
                }
                nextNoteStart += Score.DT_PER_BEAT;
            }

            // if we need to switch to a new envelope segment, update parameters
            if (tNote > e2.t) {
                envelopeIndex++;
                updateEnvelopeParameters();
            }

            // generate the sound wave at appropriate frequency
            var y :Number = 0;
            for (var o :int = 1; o < overtones.length; ++o) {
                y += Math.sin(x * _f * o) * overtones[o];
            }
            buffer[i] = y * v;

            // update our various parameters
            x += dx;
            t += dt;
            tNote += dt;
            v = Math.min(Math.max(v + dv, 0), 1);
        }
    }

    /**
     * Computes delta volume per second, for an envelope segment defined by e1 and e2.
     */
    protected function computeVolumeDelta (e1 :Env, e2 :Env) :Number
    {
        var dt :Number = e2.t - e1.t;
        if (dt == 0) return 0; // oh no, the discontinuity!
        
        var dv :Number = e2.v - e1.v;
        return dv / dt;
    }
        
    /**
     * Converts a note at the given MIDI number to a frequency in Hz.
     */
    protected function noteToFrequency (midiNumber :Number) :Number
    {
        // concert A is #69 on midi scale, defined as follows:
        // A5 = p = 69 + 12 * log2 (f / 440), therefore:
        // f = 440 * 2 ^ ((p - 69) / 12)
        return 440 * Math.pow (2, (midiNumber - 69) / 12);
    }

}
}


/**
 * Internal class used to store points that define envelope segments. Each point
 * stores a position in time-volume space.
 */
internal class Env {
    public var t :Number; // position of this segment point, in seconds since start of note
    public var v :Number; // volume at this point

    public function Env (t :Number, v :Number)
    {
        this.t = t;
        this.v = v;
    }

    public function toString () :String
    {
        return "Env[" + t + "," + v + "]";
    }
}
