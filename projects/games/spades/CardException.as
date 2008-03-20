package {


/**
 * Thrown when something goes wrong in a card game.
 */
public class CardException extends Error
{
    /** Create a new error with a description */
    public function CardException (problem :String)
    {
        super(problem);
    }
}

}
