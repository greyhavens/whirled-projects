package {

import flash.display.Sprite;
import flash.events.Event;
import flash.utils.Timer;
import flash.events.TimerEvent;

public class Jam extends Sprite
{
    private var engine: SoundEngine;
    
    public function Jam ()
    {
        var fmt :SoundFormat = new SoundFormat();

        var score :Score = new Score();

        score.setBeat(0, 0, 60);
        score.setBeat(0, 2, 69);
        score.setBeat(0, 4, 67);
        score.setBeat(0, 6, 69);
        score.setBeat(0, 8, 60);
        score.setBeat(0, 10, 69);
        score.setBeat(0, 12, 67);
        score.setBeat(0, 14, 69);
        score.setEnvelope(0, [0.0, 0.1, 0.6, 0.2, 0.9, 0.4]);

        score.setBeat(1, 0, 48);
        score.setBeat(1, 8, 55);
        score.setEnvelope(1, [0.8, 0.2, 0.5, 0.2, 0.5, 0.4]);

        var mix :AudioNode = new NoteGenerator(fmt, score, 0);
        
        for (var i :int = 1; i < Score.PARTICIPANTS; i++) {
            mix = new SummationFilter(fmt, new NoteGenerator(fmt, score, i), mix);
        }
        
        
        var sm :SmoothingFilter = new SmoothingFilter(fmt, mix);
        engine = new SoundEngine(mix);
        engine.addEventListener (SoundEngine.READY, engineReady, false, 0, true);

        addChild(new BeatGrid(score, 0));
    }
    
    private function engineReady (event:Event) :void
    {
        engine.start(); 
    }
    
}
}
