package ghostbusters.fight {
    
import flash.display.Sprite;

public interface Microgame
{
    /** 
     * Returns the total duration, in milliseconds, of microgame.
     * Returns -1 if the microgame doesn't have an explicit duration associated with it. 
     */
    function get durationMS () :Number;
    
    /** 
     * Returns the number of milliseconds remaining in the game.
     * For games that have a non-explicit duration, returns some arbitrary non-zero number
     * until the game is over.
     */
    function get timeRemainingMS () :Number;
    
    /** Returns the result of a completed microgame. */
    function get gameResult () :MicrogameResult;
    
}

}
