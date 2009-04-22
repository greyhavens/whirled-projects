package vampire.server
{
import com.whirled.contrib.simplegame.ObjectMessage;
import com.whirled.contrib.simplegame.net.Message;

public class ServerObjectMessage extends ObjectMessage
{
    public function ServerObjectMessage(player :PlayerData, msg :Message)
    {
        super(NAME);
        this.player = player;
        this.msg = msg;
    }

    public var player :PlayerData;
    public var msg :Message;

    public static const NAME :String = "Server Message";
}
}