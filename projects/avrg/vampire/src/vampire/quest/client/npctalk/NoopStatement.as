package vampire.quest.client.npctalk {

public class NoopStatement
    implements Statement
{
    public static const INSTANCE :NoopStatement = new NoopStatement();

    public function begin () :void
    {
    }

    public function update (dt :Number) :void
    {
    }

    public function isDone () :Boolean
    {
        return true;
    }
}

}
