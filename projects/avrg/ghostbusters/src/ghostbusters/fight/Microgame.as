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
     * For games that have a non-explicit duration, returns some arbitrary non-zero number.
     */
    function get timeRemainingMS () :Number;
    
    /**
     * Returns true when the game has completed, which could be some
     * short time after timeRemainingMS returns 0 if there are
     * game over animations that play.
     */
    function get isDone () :Boolean;
    
    /** Returns the result of a completed microgame. */
    function get gameResult () :MicrogameResult;
    
}

}
