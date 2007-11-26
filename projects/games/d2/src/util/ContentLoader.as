package util {

import flash.display.LoaderInfo;

import com.threerings.util.Assert;
import com.whirled.util.ContentPack;
import com.whirled.util.ContentPackLoader;

    
/**
 * Wrapper around a content pack loader, which holds on to loaded content packs,
 * and calls the appropriate callbacks when ready.
 */
public class ContentLoader 
{
    /**
     * Loads content packs.
     *
     * @param definitions An array of pack definitions from WhirledGameControl
     * @param callback    Function to be called after loading all packs. It should accept an array
     *                    of ContentPack objects, and return void.
     */ 
    public function ContentLoader (definitions :Array, callback :Function)
    {
        _callback = callback;
        _loader = new ContentPackLoader(definitions, handleGotOne, handleDone, true);        
    }

    /** Returns currently loaded content packs. */
    public function get packs () :Array
    {
        return _packs;
    }

    protected function handleGotOne (pack :ContentPack) :void {
        if (pack == null) {
            Assert.fail("Failed to load a content pack!");
        } else {
            _packs.push(pack);
        }
    }

    protected function handleDone (infos :Array) :void {
        // ignore the loader infos, just pass on the content packs
        _callback(_packs);
    }
        
    protected var _callback :Function;
    protected var _loader :ContentPackLoader;
    protected var _packs :Array = new Array(); // of ContentPack
}
}
