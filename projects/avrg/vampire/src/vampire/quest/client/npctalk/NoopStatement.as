package vampire.quest.client.npctalk {

public class NoopStatement
    implements Statement
{
    public static const INSTANCE :NoopStatement = new NoopStatement();

    public function update (dt :Number) :Number
    {
        return 0;
    }

    public function get isDone () :Boolean
    {
        return true;
    }
}

}
