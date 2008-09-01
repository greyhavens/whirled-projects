package ghostbusters.client.fight {
    
public class MicrogameResult
{
    public static const FAILURE :uint = 0;
    public static const SUCCESS :uint = 1;
    public static const CRITICAL_SUCCESS :uint = 2;
    
    public var success :uint;
    public var damageOutput :int;
    public var healthOutput :int;
}

}