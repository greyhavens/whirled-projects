package com.whirled.contrib.simplegame.objects
{
import com.whirled.contrib.simplegame.ObjectDB;

public class ServerDB extends ObjectDB
{
    public function ServerDB()
    {
        super();
    }

    public function addBasicGameObject (ob :BasicGameObject) :void
    {
        _basicObjects.push(ob);
    }

    override protected function shutdown () :void
    {
        super.shutdown();
        for each (var ob :BasicGameObject in _basicObjects) {
            if (ob != null) {
                ob.shutdown();
            }
        }
        _basicObjects = [];
    }

    protected var _basicObjects :Array = [];
}
}