package vampire.quest.client {

import com.threerings.util.StringUtil;

public class QuestDialogDesc
{
    public var filename :String;
    public var clazz :Class;

    public function QuestDialogDesc (filename :String, clazz :Class)
    {
        this.filename = filename;
        this.clazz = clazz;
    }

    public function get resourceName () :String
    {
        return filename.substr(0, filename.length - String(".xml").length);
    }
}

}
