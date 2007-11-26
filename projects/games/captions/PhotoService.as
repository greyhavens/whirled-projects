//
// $Id$

package {

/**
 * Dispatched when the photo for a round is available.
 *
 * value - the Array of url information: [ photoUrl, sourcePageUrl (optional) ]
 */
[Event(name="photoAvail", type="com.threerings.util.ValueEvent")]

/**
 * Dispatched when all the preview photos are available.
 *
 * value - [ previewIndex, previewUrl , photoUrl, sourcePageUrl (optional) ]
 */
[Event(name="previewAvail", type="com.threerings.util.ValueEvent")]

import flash.events.EventDispatcher;

import com.threerings.util.ValueEvent;

/**
 * An abstract base class for generating/retrieving photos.
 */
public class PhotoService extends EventDispatcher
{
    public static const PHOTO_AVAILABLE :String = "photoAvail";

    public static const PREVIEW_AVAILABLE :String = "previewAvail";

    /**
     * Constructor.
     */
    public function PhotoService ()
    {
    }

    /**
     * Called when this instance will actually be used to retrieve photos. Your subclass
     * should avoid any strenuous setup until this method is called.
     */
    public function init () :void
    {
        // nothing here right now
    }

    /**
     * Load up new previews. As each becomes available a previewAvail event will be dispatched.
     * Any still pending lookup will be stopped.
     */
    public function getPreviews (count :int) :void
    {
        throw new Error("Abstract");
    }

    /**
     * Get a photo to use for the game from the previews, or a new one if there are 
     */
    public function getPhoto () :void
    {
        throw new Error("Abstract");
    }

    /**
     * Internal convenience method for informing the game of a photo.
     */
    protected function dispatchPhoto (photoUrl :String, infoUrl :String = null) :void
    {
        var info :Array = [ photoUrl ];
        if (infoUrl != null) {
            info.push(infoUrl);
        }
        dispatchEvent(new ValueEvent(PHOTO_AVAILABLE, info));
    }

    /**
     * Internal convenience method for informing the game of a preview.
     */
    protected function dispatchPreview (
        index :int, previewUrl :String, photoUrl :String, infoUrl :String = null) :void
    {
        var info :Array = [ index, previewUrl, photoUrl ];
        if (infoUrl != null) {
            info.push(infoUrl);
        }
        dispatchEvent(new ValueEvent(PREVIEW_AVAILABLE, info));
    }
}
}
