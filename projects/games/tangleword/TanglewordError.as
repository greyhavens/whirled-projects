package
{

/**
 * Used to notify the display that a word choice does not even
 * exist on the board, or is too short, or some other reason
 * that prevented Tangleword from sending out the word for validation.
 */
public class TangleWordError extends Error
{
    public function TangleWordError (msg :String)
    {
        super(msg);
    }
}

}

