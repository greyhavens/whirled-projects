//
// $Id$


package {


import com.adobe.webapis.flickr.FlickrService;
import com.adobe.webapis.flickr.PagedPhotoList;
import com.adobe.webapis.flickr.Photo;
import com.adobe.webapis.flickr.PhotoSize;
import com.adobe.webapis.flickr.PhotoUrl;
import com.adobe.webapis.flickr.events.FlickrResultEvent;

/**
 * Allows keyword searching of flickr.
 */
public class SearchFlickrPhotoService extends AbstractFlickrPhotoService
{
    public function setKeywords (str :String, tagsOnly :Boolean = false) :void
    {
        _str = str;
        _tagsOnly = tagsOnly;

        // reset saved search info
        _total = -1;
    }

    override public function init () :void
    {
        super.init();

        _flickr.addEventListener(FlickrResultEvent.PHOTOS_SEARCH, handleFlickrSearchResult);
    }


    override protected function getFlickrKey () :String
    {
        return "5d29b1d793cc58bc495dda72e979f4af";
    }


    override protected function doGetPhotos (count :int) :void
    {
        var tagsStr :String = _tagsOnly ? _str : "";
        var textStr :String = _tagsOnly ? "" : _str;

        switch (_total) {
        case 0:
            // think of what? We're fucked!
            super.doGetPhotos(count);
            return; // EXIT

        case -1:
            // get page 1, we'll figure out the total
            _flickr.photos.search("", tagsStr, "any", textStr, null, null, null, null, -1, "",
                count, 1);
            break;

        default:
            // get a bunch of 1-page results
            count = Math.min(count, _total);
            var picks :Array = [];
            var pick :int;
            for (var ii :int = 0; ii < count; ii++) {
                do {
                    pick = Math.floor(_total * Math.random());

                } while (picks.indexOf(pick) != -1);

                _flickr.photos.search("", tagsStr, "any", textStr, null, null, null, null, -1, "",
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
        _total = photoList.total;
        trace("Got a page: " + _total);

        if (_total == 0 && _needPhoto) {
            // we NEED a photo!
            doGetPhotos(1);
            return;
        }

        // otherwise, make size requests on everything we got
        var photos :Array = photoList.photos;
        var photoIds :Array = photos.map(
            function (photo :Photo, ... sh) :String {
                return photo.id;
            }
        );
        getUrlsAndDispatchToGame(photoIds);
    }

    protected var _str :String;

    protected var _tagsOnly :Boolean;

    protected var _total :int;
}
}
