package vampire.quest.client.npctalk {

public class ExitStatement
    implements Statement
{
    public function createState () :Object
    {
        // stateless
        return null;
    }

    public function update (dt :Number, state :Object) :Number
    {
        ProgramCtx.program.exit();
        return Status.CompletedInstantly;
    }
}

}
