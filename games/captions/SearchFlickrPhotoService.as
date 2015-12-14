//
// $Id$


package {


import com.adobe.webapis.flickr.FlickrService;
import com.adobe.webapis.flickr.PagedPhotoList;
import com.adobe.webapis.flickr.Photo;
import com.adobe.webapis.flickr.PhotoSize;
import com.adobe.webapis.flickr.PhotoUrl;
import com.adobe.webapis.flickr.events.FlickrResultEvent;

import com.threerings.util.StringUtil;

/**
 * Allows keyword searching of flickr, falling back to getting the latest photos if
 * the specified keywords return no results.
 */
public class SearchFlickrPhotoService extends LatestFlickrPhotoService
{
    /**
     * Set the keywords to use when searching flick.
     *
     * @param words an Array of Strings.
     * @param tags if true, an ANY search is done on the tags.
     *             if false the words are used as keywords (that can match title/desc/tags) but
     *             all must be present in photos!
     */
    public function setKeywords (words :Array, tags :Boolean = true) :void
    {
        if (tags) {
            _tagStr = words.join(",");
            _textStr = "";

        } else {
            _tagStr = "";
            _textStr = words.join(" ");
        }

        // reset saved search info
        _total = -1;
        _pics.length = 0;
    }

    override public function init () :void
    {
        super.init();

        _flickr.addEventListener(FlickrResultEvent.PHOTOS_SEARCH, handleFlickrSearchResult);
    }

    override protected function doGetPhotos (count :int) :void
    {
        // if we have no search string or our search string is too restrictive,
        // fall back to returning the latest photos
        if (_total == 0 || (StringUtil.isBlank(_textStr) && StringUtil.isBlank(_tagStr))) {
            // TODO: if _textStr is too restrictive, inform the users?
            super.doGetPhotos(count);
            return;
        }

        switch (_total) {
        case -1:
            // get page 1, we'll figure out the total
//            trace("Getting #1 of <unknown>");
            _flickr.photos.search("", _tagStr, "any", _textStr, null, null, null, null, -1, "",
                count, 1);
            break;

        default:
            // get a bunch of 1-page results
            count = Math.min(count, _total);
            var picks :Array = [];
            var pick :int;
            for (var ii :int = 0; ii < count; ii++) {
                do {
                    pick = 1 + Math.floor(_total * Math.random());

                } while (picks.indexOf(pick) != -1);
                picks.push(pick);

//                trace("Getting #" + pick + " of " + _total);
                _flickr.photos.search("", _tagStr, "any", _textStr, null, null, null, null, -1, "",
                    1, pick);
            }
            break;
        }
    }

    protected function handleFlickrSearchResult (evt :FlickrResultEvent) :void
    {
        if (!evt.success) {
            flickrFailure(evt.data.error.errorMessage);
            return;
        }

        var photoList :PagedPhotoList = (evt.data.photos as PagedPhotoList);
        _total = Math.min(photoList.total, FLICKR_MAX_IMAGES_LIMIT);

        if (_total == 0 && _needPhoto) {
            // we NEED a photo, so re-request, which will fall back to super.doGetPhotos().
            doGetPhotos(1);
            return;
        }

//        trace("Got " + photoList.page + " (" + photoList.perPage + ") of " + _total +
//            "  (" + photoList.photos[0].id + ")");

        // otherwise, make size requests on everything we got
        getUrlsAndDispatchToGame(photoList.photos);
    }

    /** The tags string to use for searching. */
    protected var _tagStr :String = "";

    /** The text string to use for searching. */
    protected var _textStr :String = "";

    /** The total number of photos that flickr has for the current tag/text strings. */
    protected var _total :int = -1;

    /** Flickr will only do search results for up to 4000 images, and then they start
     * repeating even though they report a larger total. */
    protected static const FLICKR_MAX_IMAGES_LIMIT :int = 4000;
}
}
