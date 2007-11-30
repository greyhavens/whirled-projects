//
// $Id$

package {

import flash.utils.Dictionary;

import com.adobe.webapis.flickr.FlickrService;
import com.adobe.webapis.flickr.PagedPhotoList;
import com.adobe.webapis.flickr.Photo;
import com.adobe.webapis.flickr.PhotoSize;
import com.adobe.webapis.flickr.PhotoUrl;
import com.adobe.webapis.flickr.events.FlickrResultEvent;

/**
 * A base class for building flickr-based photo services.
 */
public class AbstractFlickrPhotoService extends PhotoService
{
    override public function init () :void
    {
        super.init();

        // Set up the flickr service.
        _flickr = new FlickrService(getFlickrKey());
        _flickr.addEventListener(FlickrResultEvent.PHOTOS_GET_SIZES, handleSizeUrlsKnown);
    }

    override public function getPreviews (count :int) :void
    {
        _previews = count; // reset how many previews we want
        if (!useSaved()) { // useSaved may modify _previews
            doGetPhotos(_previews); // lookup that modified number of pics
        }
    }

    override public function getPhoto () :void
    {
        _needPhoto = true;
        _previews = 0; // and there's no need to dispatch any more previews now
        if (!useSaved()) {
            doGetPhotos(1);
        }
    }

    protected function doGetPhotos (count :int) :void
    {
        throw new Error("You need to implement doGetPhotos");
    }

    protected function getFlickrKey () :String
    {
        throw new Error("OH HAI. You need to get a Flickr Services key for your subclass.")
    }

    /**
     * Utility method for your subclass. Once you get photo ids of some photos, and
     * need to know the urls to dispatch to the game, call this. It will even dispatch
     * everything for you, so you're done when you call this.
     */
    protected function getUrlsAndDispatchToGame (photoArray :Array /* of Photo */) :void
    {
        for each (var photo :Photo in photoArray) {
            _pageUrls[photo.id] = "http://www.flickr.com/photos/" + photo.ownerId + "/" + photo.id;
            _flickr.photos.getSizes(photo.id);
        }
    }

    /**
     * The sizes of a photo are now known, either start the round or store
     * the sizes as a preview photo.
     */
    protected function handleSizeUrlsKnown (evt :FlickrResultEvent) :void
    {
        if (!evt.success) {
            flickrFailure(evt.data.error.errorMessage);
            return;
        }

        // find a good caption-sized photo
        var returnedSizes :Array = (evt.data.photoSizes as Array);
        var pageUrl :String = getPageUrl(returnedSizes);
        var captionSize :PhotoSize = getPhotoSource(returnedSizes, CAPTION_SIZE);
        if (captionSize == null) { 
            flickrFailure("Could not find photo sources for photo: " + returnedSizes);
            return;
        }

        // We've got enough to satisfy a photo request
        if (_needPhoto) {
            _needPhoto = false;
            dispatchPhoto(captionSize.source, pageUrl);
            return;
        }

        // otherwise make sure we have a preview size
        var previewSize :PhotoSize = getPhotoSource(returnedSizes, PREVIEW_SIZE);
        if (previewSize == null) { // as if this would ever happen
            flickrFailure("Could not find preview sources for photo: " + returnedSizes);
            return;
        }

        // Yay. Everything's kosher. Do something with it.
        _previews--;
        if (_previews >= 0) {
            dispatchPreview(_previews, previewSize.source, captionSize.source, pageUrl);

        } else {
            // save it
            _pics.push([ previewSize.source, captionSize.source, pageUrl ]);
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

    protected function getPageUrl (photoSizes :Array) :String
    {
        if (photoSizes.length > 0) {
            var p :PhotoSize = photoSizes[0] as PhotoSize;
            var result :Object = (/id=(\d+)/).exec(p.url);
            if (result) {
                var id :String = result[1] as String;
                var url :String = _pageUrls[id];
                delete _pageUrls[id];
                return url;
            }
        }

        // NOTE: we may leave garbage in _pageUrls, but there's nothing we can do
        return null;
    }

    /**
     * Dispatch photos/previews if we have them.
     *
     * @return true if we satisfied outstanding photo requests from saved.
     */
    protected function useSaved () :Boolean
    {
        while ((_needPhoto || _previews > 0) && _pics.length > 0) {
            var pic :Array = _pics.shift() as Array;
            if (_needPhoto) {
                _needPhoto = false;
                dispatchPhoto(pic[1], pic[2]);

            } else {
                dispatchPreview(--_previews, pic[0], pic[1], pic[2]);
            }
        }

        return (!_needPhoto && _previews <= 0);
    }

    protected function flickrFailure (message :String) :void
    {
        if (_needPhoto) {
            trace("Failure loading photo [" + message + "].");
            // we need it!
            getPhoto();

        } else {
            trace("Failure loading preview. Oh well! [" + message + "].");
            _previews--; // it doesn't matter if we go negative
        }
    }

    /** Preferred photo sizes for captioning. */
    protected static const CAPTION_SIZE :Array = [ "Medium", "Small", "Original", "Thumbnail" ];

    /** Preferred photo sizes for previewing. */
    protected static const PREVIEW_SIZE :Array = [ "Thumbnail", "Square", "Small" ];

    /** The flickr service (only used by the player in control). */
    protected var _flickr :FlickrService;

    /** How many previews are we trying to retrieve? */
    protected var _previews :int = 0;

    protected var _needPhoto :Boolean;

    protected var _pics :Array = [];

    protected var _pageUrls :Dictionary = new Dictionary();
}
}
