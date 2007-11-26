package {

import flash.net.LocalConnection;
import flash.system.Capabilities;
import flash.utils.describeType;

import com.whirled.DataPack;
import com.whirled.WhirledGameControl;
import com.whirled.util.ContentPack;
import com.whirled.util.ContentPackLoader;
import com.whirled.util.DataPackLoader;


public class Main
{
    protected var _whirled :WhirledGameControl;

    public function init (app :Defense) :void
    {
        _whirled = new WhirledGameControl(app, false);

        if (! _whirled.isConnected()) {
            trace("* DISCONNECTED");
            return; 
        }

        var levelPacks :Array = _whirled.getLevelPacks();
        var packs :Array = levelPacks.map(function (definition :Object, i :*, a :*) :DataPack {
                trace("WILL LOAD: " + definition.mediaURL);
                return new DataPack(definition.mediaURL);
                });
    }
}
}
