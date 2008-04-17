package spades.graphics {

import spades.Debug;
import flash.display.SimpleButton;
import flash.display.DisplayObjectContainer;
import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.display.Scene;

/** Static functions for accessing named objects in a container. */
public class Structure
{
    /** Get an object by name below a parent object. If not found, dumps out the complete 
     *  descendants tree of the parent and throws an error. 
     *  @param parent object presumed to contain the named child 
     *  @param name the name of the object to fetch */
    public static function require (
        parent :DisplayObject, 
        name :String) :DisplayObject
    {
        if (!(parent is DisplayObjectContainer)) {
            Debug.debug("DisplayObject " + parent.name + " is not a container ");
            throw new Error("Object " + parent.name + " not a container");
        }

        var container :DisplayObjectContainer = DisplayObjectContainer(parent);
        var obj :DisplayObject = container.getChildByName(name);

        if (obj == null) {
            Debug.debug("DisplayObject named " + name + 
                " not found in " + parent.name);
            dump(parent);
            throw new Error("Object " + name + " not found");
        }

        return obj;
    }

    /** Get a SimpleButton by name below a parent object. If not found, dumps out the complete
     *  descendants tree of the parent and throws an error.
     *  @param parent object presumed to contain the named button
     *  @param name the name of the button to fetch */
    public static function requireButton (
        parent :DisplayObject, 
        name :String) :SimpleButton
    {
        return SimpleButton(require(parent, name));
    }

    /** Print out all the descendants of a display object. */
    public static function dump (parent :DisplayObject) :void
    {
        Debug.debug("Descendants of " + parent.name);
        doDump(parent, "  ");
    }

    /** Print out all the scenes and frames of a movie clip. */
    public static function dumpMovie (movie :MovieClip) :void
    {
        Debug.debug("Dumping movie " + movie.name);
        var scenes :Array = movie.scenes;
        for (var i :int = 0; i < scenes.length; ++i) {
            var scene :Scene = scenes[i] as Scene;
            var labels :Array = scene.labels;
            Debug.debug("  Scene " + i + " is " + scene.name + " and has " + 
                scene.numFrames + " frames and " + labels.length + " labels");
            for (var j :int = 0; j < labels.length; ++j) {
                Debug.debug("    " + labels[j]);
            }
        }
    }

    protected static function doDump (
        obj :DisplayObject, 
        prefix :String="") :void
    {
        Debug.debug(prefix + obj.name + " " + obj["constructor"]);
        if (obj is DisplayObjectContainer) {
            var parent :DisplayObjectContainer = obj as DisplayObjectContainer;
            for (var i :int = 0; i < parent.numChildren; ++i) {
                var child :DisplayObject = parent.getChildAt(i);
                doDump(child, prefix + "  ");
            }
        }
    }
}

}
