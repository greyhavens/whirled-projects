package lawsanddisorder.component {
    
import flash.display.Sprite;
import flash.display.DisplayObject;
import flash.text.TextField;
import flash.events.MouseEvent;
import lawsanddisorder.Context;

/**
 * Primary class that all sprites extend
 */
public class Component extends Sprite
{
    /**
     * Constructor
     */
    public function Component (ctx :Context)
    {
        _ctx = ctx;
        
        // title displays number of cards
        title = new TextField();
        title.height = 30;
        title.x = 0;
        title.y = 0;
        title.mouseEnabled = false;
        title.wordWrap = true;
        addChild(title);
        
        // display static and dynamic
        initDisplay();
        updateDisplay();
    }
    
    /**
     * Check this object and its children against a target and return true if there is
     * a match.
     */
    public function isTarget (target :DisplayObject) :Boolean
    {
        if (this == target) {
            return true;
        }
        if (this.contains(target)) {
            return true;
        }
        return false;
    }
    
    /**
     * Display static graphics
     */
    protected function initDisplay () :void
    {
        // abstract method
    }
    
    /**
     * Change display of dynamic graphics
     */
    protected function updateDisplay () :void
    {
        // abstract method
    }
    
    /**
     * Bring a child component above other siblings.     */
    public function bringToFront (child :DisplayObject) :void
    {
    	if (!contains(child)) {
    		_ctx.log("WTF component doesn't contain child in bringToFrong");
    		return;
    	}
    	var topChild :DisplayObject = getChildAt(numChildren-1);
    	swapChildren(child, topChild);
    }
    
    /** Main game logic */
    protected var _ctx :Context;
    
    /** Title for debugging 
     * TODO for testing purposes - remove later */
    protected var title :TextField;
}
}