package {

import flash.external.ExternalInterface;

public class Console {

    public static function log (...rest) :void
    {
        if (ExternalInterface.available) {
            ExternalInterface.call("console.log", rest[0]);
        }
    }
}
}
