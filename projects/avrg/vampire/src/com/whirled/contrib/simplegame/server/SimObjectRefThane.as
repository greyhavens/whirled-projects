package com.whirled.contrib.simplegame.server
{
public class SimObjectRefThane
{
    public static function Null () :SimObjectRefThane
    {
        return g_null;
    }

    public function get object () :SimObjectThane
    {
        return _obj;
    }

    public function get isNull () :Boolean
    {
        return (null == _obj);
    }

    protected static var g_null :SimObjectRefThane = new SimObjectRefThane();

    // managed by ObjectDB
    internal var _obj :SimObjectThane;
    internal var _next :SimObjectRefThane;
    internal var _prev :SimObjectRefThane;
}
}