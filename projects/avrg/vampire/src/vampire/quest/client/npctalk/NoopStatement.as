package vampire.quest.client.npctalk {

public class NoopStatement
    implements Statement
{
    public static const INSTANCE :NoopStatement = new NoopStatement();

    public function createState () :Object
    {
        // stateless
        return null;
    }

    public function update (dt :Number, state :Object) :Number
    {
        return 0;
    }

    public function isDone (state :Object) :Boolean
    {
        return true;
    }
}

}
