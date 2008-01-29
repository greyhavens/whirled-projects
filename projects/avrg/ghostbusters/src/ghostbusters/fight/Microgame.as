package ghostbusters.fight {
    
import flash.display.Sprite;

public interface Microgame
{
    /** 
     * Returns the total duration, in milliseconds, of microgame.
     * Returns -1 if the microgame doesn't have an explicit duration associated with it. 
     */
    function get duration () :Number;
    
    /** 
     * Returns the number of milliseconds remaining in the game.
     * For games that have a non-explicit duration, returns some arbitrary non-zero number
     * until the game is over.
     */
    function get timeRemaining () :Number;
    
    /** Begins the microgame. */
    function begin () :void;
    
    /** Returns the result of a completed microgame. */
    function get microgameResult () :MicrogameResult;
    
    /** Returns the sprite associated with this microgame. */
    function get sprite () :Sprite;
    
}

}