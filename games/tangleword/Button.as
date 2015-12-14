package
{

import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.events.MouseEvent;

/**
 * Simple button with mouse over and mouse out states, and a click callback.
 */
public class Button extends Sprite
{
    /**
     * Creates a new button. /mouseOver/ and /mouseOut/ are display object to be shown when
     * the mouse is over or out of the button's display area, respectively. /onClick/ is a
     * zero-argument function called during a mouse click.
     */
    public function Button (mouseOver :DisplayObject, mouseOut :DisplayObject, onClick :Function)
    {
        this.buttonMode = true;
        
        _mouseOver = mouseOver;
        _mouseOut = mouseOut;
        _onClick = onClick;

        _currentDisplay = _mouseOut;
        addChild(_currentDisplay);
        
        addEventListener(MouseEvent.MOUSE_OVER, function (event :MouseEvent) :void {
                removeChild(_currentDisplay);
                _currentDisplay = _mouseOver;
                addChild(_currentDisplay);
            });
        addEventListener(MouseEvent.MOUSE_OUT, function (event :MouseEvent) :void {
                removeChild(_currentDisplay);
                _currentDisplay = _mouseOut;
                addChild(_currentDisplay);
            });

        addEventListener(MouseEvent.CLICK, function (event :MouseEvent) :void {
                _onClick();
            });
    }

    private var _mouseOver :DisplayObject;
    private var _mouseOut :DisplayObject;
    private var _currentDisplay :DisplayObject;
    private var _onClick :Function;
}
}
