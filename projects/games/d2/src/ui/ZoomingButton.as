package ui {

import flash.events.MouseEvent;
import flash.geom.Point;

import mx.controls.Button;
import mx.effects.Move;
import mx.effects.Resize;
    
/**
 * Simple button that zooms a little when hovered over.
 */
public class ZoomingButton extends Button
{
    /**
     * Creates a new zooming button. zoomFactor a point specifying pixel values for
     * x and y scaling during a mouse over. 
     */
    public function ZoomingButton (zoom :Point)
    {
        _zoom = zoom;
    }

    override protected function createChildren () :void
    {
        super.createChildren();

        _resize = new Resize(this);
        _resize.duration = 200;
        _resize.widthBy = _zoom.x;
        _resize.heightBy = _zoom.y;
        setStyle("mouseDownEffect", _resize);
        
        _unresize = new Resize(this);
        _unresize.duration = 200;
        _unresize.widthBy = - _zoom.x;
        _unresize.heightBy = - _zoom.y;
        setStyle("mouseUpEffect", _unresize);
    }

    /*
    override protected function rollOverHandler (event :MouseEvent) :void
    {
        super.rollOverHandler(event);
        trace("START ROLL OVER");
        _resize.end();
        _resize.play();
    }

    override protected function rollOutHandler (event :MouseEvent) :void
    {
        super.rollOutHandler(event);
        trace("START ROLL OUT");
        _unresize.end();
        _unresize.play();
    }
    */
    
    protected var _zoom :Point;
    protected var _resize :Resize, _unresize :Resize;
}
        
}
