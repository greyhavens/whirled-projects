package ghostbusters.fight {
    
import flash.display.Sprite;

public interface Microgame
{
    /** Begins the microgame. */
    function begin () :void;
    
    /** Returns true if the microgame has completed. */
    function get isDone () :Boolean;
    
    /** Returns the result of a completed microgame. */
    function get microgameResult () :MicrogameResult;
    
    /** Returns the sprite associated with this microgame. */
    function get sprite () :Sprite;
    
}

}