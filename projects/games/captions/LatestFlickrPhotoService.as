//
// $Id$

package {

import com.threerings.util.ValueEvent; 

import com.adobe.webapis.flickr.FlickrService;
import com.adobe.webapis.flickr.PagedPhotoList;
import com.adobe.webapis.flickr.Photo;
import com.adobe.webapis.flickr.PhotoSize;
import com.adobe.webapis.flickr.PhotoUrl;
import com.adobe.webapis.flickr.events.FlickrResultEvent;

/**
 * A PhotoService that returns that latest uploaded photos from flickr.
 */
public class LatestFlickrPhotoService extends PhotoService
{
    public function LatestFlickrPhotoService ()
    {
    }

    override public function init () :void
    {
        super.init();

        // Set up the flickr service
        // This is my (Ray Greenwell)'s personal Flickr key for this game!! Get your own!
        _flickr = new FlickrService("5d29b1d793cc58bc495dda72e979f4af");
        _flickr.addEventListener(FlickrResultEvent.PHOTOS_GET_RECENT, handlePhotoResult);
        _flickr.addEventListener(FlickrResultEvent.PHOTOS_GET_SIZES, handlePhotoUrlKnown);
    }

    override public function getPreviews (count :int) :void
    {
        _previewsToGet = count;
        _flickr.photos.getRecent("", _previewsToGet, 1);
    }

    override public function getPhoto () :void
    {
        // stop getting previews
        // TODO: put the kibosh on any results that are intended to be preview results...
        // otherwise, we could get two "photo" responses and possibly booch the game flow
        // Maybe: two FlickrService objects??
        _previewsToGet = 0;

        _flickr.photos.getRecent("", 1, 1);
    }

    // Flickr result handlers
    // ----------------------
    
    /**
     * A photo was returned by flickr, now get the sizing info.
     */
    protected function handlePhotoResult (evt :FlickrResultEvent) :void
    {
        if (!evt.success) {
            trace("Failure loading the next photo [" + evt.data.error.errorMessage + "]");
            if (_previewsToGet > 0) {
                // give up on getting any previews
                _previewsToGet = 0;

            } else {
                // we need to try again!
                getPhoto();
            }
            return;
        }

        var photos :Array = (evt.data.photos as PagedPhotoList).photos;
        for (var ii :int = 0; ii < photos.length; ii++) {
            var photo :Photo = photos[ii] as Photo;
            _flickr.photos.getSizes(photo.id);
        }
    }
    
    /**
     * The sizes of a photo are now known, either start the round or store
     * the sizes as a preview photo.
     */
    protected function handlePhotoUrlKnown (evt :FlickrResultEvent) :void
    {
        if (!evt.success) {
            trace("Failure getting photo sizes [" + evt.data.error.errorMessage + "]");
            if (_previewsToGet == 0) {
                // TRY AGAIN!
                getPhoto();

            } else {
                // just don't worry about this particular preview
                _previewsToGet--;
            }

            return;
        }

        var returnedSizes :Array = (evt.data.photoSizes as Array);
        var captionSize :PhotoSize = getPhotoSource(returnedSizes, CAPTION_SIZE);
        if (captionSize == null) { 
            trace("Could not find photo sources for photo: " + returnedSizes);
            if (_previewsToGet == 0) {
                // we have to try again
                getPhoto();
            }
            return;
        }

        if (_previewsToGet > 0) {
            _previewsToGet--;
            var previewSize :PhotoSize = getPhotoSource(returnedSizes, PREVIEW_SIZE);
            if (previewSize == null) {
                // this should never happen
                trace("Could not find photo sources for photo: " + returnedSizes);
                return;
            }
            dispatchPreview(_previewsToGet, previewSize.source, captionSize.source);

        } else {
            // it's the photo, dispatch it
            dispatchPhoto(captionSize.source);
        }
    }
    
    /**
     * Find the closest matching photo size to the preferred sizes specified.
     */
    protected function getPhotoSource (photoSizes :Array, preferredSizes :Array) :PhotoSize
    {
        for each (var prefSize :String in preferredSizes) {
            for each (var p :PhotoSize in photoSizes) {
                if (p.label == prefSize) {
                    return p;
                }
            }
        }

        // whoa!

        return null;
    }

    /** Preferred photo sizes for captioning. */
    protected static const CAPTION_SIZE :Array = [ "Medium", "Small", "Original", "Thumbnail" ];

    /** Preferred photo sizes for previewing. */
    protected static const PREVIEW_SIZE :Array = [ "Thumbnail", "Square", "Small" ];

    /** The flickr service (only used by the player in control). */
    protected var _flickr :FlickrService;

    /** How many photos is the player in control currently trying to retrieve? */
    protected var _previewsToGet :int = 0;
}
}
