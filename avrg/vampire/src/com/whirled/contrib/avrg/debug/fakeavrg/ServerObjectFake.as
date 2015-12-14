package com.whirled.contrib.avrg.debug.fakeavrg
{
import com.whirled.ServerObject;

import flash.display.DisplayObject;

//This doesn't work!!!  Cannot extend DisplayObject
public class ServerObjectFake extends ServerObject
{
    public function ServerObjectFake(realDisplayRoot :DisplayObject)
    {
        this.realDisplay = realDisplayRoot;
    }
    override public function get root() :DisplayObject
    {
        return realDisplay.root;
    }

    protected var realDisplay :DisplayObject;

}
}
