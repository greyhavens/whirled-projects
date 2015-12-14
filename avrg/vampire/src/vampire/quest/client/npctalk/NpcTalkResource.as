package vampire.quest.client.npctalk {

import com.threerings.flashbang.resource.XmlResource;

public class NpcTalkResource extends XmlResource
{
    public function NpcTalkResource (resourceName :String, loadParams :Object)
    {
        super(resourceName, loadParams, ProgramParser.parse);
    }

    public function get program () :Program
    {
        return _generatedObject as Program;
    }
}

}
