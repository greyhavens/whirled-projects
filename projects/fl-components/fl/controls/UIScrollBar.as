// Copyright 2007. Adobe Systems Incorporated. All Rights Reserved.
package fl.controls {

	import Error;
	import fl.controls.ScrollBar;
	import fl.controls.ScrollBarDirection;
	import fl.core.InvalidationType;
	import fl.core.UIComponent;
	import fl.events.ScrollEvent;
	import flash.events.Event;
	import flash.events.TextEvent;
	import flash.text.TextField;
		
    //--------------------------------------
    //  Class description
    //--------------------------------------    
	/**
	 * The UIScrollBar class includes all of the scroll bar functionality, but 
     * adds a <code>scrollTarget()</code> method so it can be attached
	 * to a TextField component instance.
	 *
	 * <p><strong>Note:</strong> When you use ActionScript to update properties of 
	 * the TextField component that affect the text layout, you must call the 
	 * <code>update()</code> method on the UIScrollBar component instance to refresh its scroll 
	 * properties. Examples of text layout properties that belong to the TextField 
	 * component include <code>width</code>, <code>height</code>, and <code>wordWrap</code>.</p>
	 *
     * @includeExample examples/UIScrollBarExample.as
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
	 */
	public class UIScrollBar extends ScrollBar {
		
		/**
         * @private (private)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected var _scrollTarget:TextField;

		/**
         * @private (private)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected var inEdit:Boolean = false;	

		/**
         * @private
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected var inScroll:Boolean = false;
		
		/**
		 * @private
		 */
		private static var defaultStyles:Object = {};
		
        /**
         * @copy fl.core.UIComponent#getStyleDefinition()
         *
         * @see fl.core.UIComponent#getStyle()
         * @see fl.core.UIComponent#setStyle()
         * @see fl.managers.StyleManager
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		public static function getStyleDefinition():Object { 
			return UIComponent.mergeStyles(defaultStyles, ScrollBar.getStyleDefinition()); 
		}
		
		/**
         * Creates a new UIScrollBar component instance.
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function UIScrollBar() {
			super();
		}
		
		/**
         * @private
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		override public function set minScrollPosition(minScrollPosition:Number):void {
			super.minScrollPosition = (minScrollPosition<0)?0:minScrollPosition;
		}
		
		/**
         * @private
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		override public function set maxScrollPosition(maxScrollPosition:Number):void {
			var maxScrollPos:Number = maxScrollPosition;
			if (_scrollTarget != null) { 
				if (direction == ScrollBarDirection.HORIZONTAL) {
					maxScrollPos = (maxScrollPos>_scrollTarget.maxScrollH)?_scrollTarget.maxScrollH:maxScrollPos;
				} else {
					maxScrollPos = (maxScrollPos>_scrollTarget.maxScrollV)?_scrollTarget.maxScrollV:maxScrollPos;
				}
			}
			super.maxScrollPosition = maxScrollPos;
		}
		
		/**
		 * Registers a TextField component instance with the ScrollBar component instance.
         *
         * @includeExample examples/UIScrollBar.scrollTarget.1.as -noswf
         *
         * @see #update()
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function get scrollTarget():TextField {
			return _scrollTarget;
		}
		/**
         * @private (setter)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function set scrollTarget(target:TextField):void {
			if (_scrollTarget != null) {
				_scrollTarget.removeEventListener(Event.CHANGE,handleTargetChange,false);
				_scrollTarget.removeEventListener(TextEvent.TEXT_INPUT,handleTargetChange,false);
				_scrollTarget.removeEventListener(Event.SCROLL,handleTargetScroll,false);
				removeEventListener(ScrollEvent.SCROLL,updateTargetScroll,false);
			}
			_scrollTarget = target;
			if (_scrollTarget != null) {
				_scrollTarget.addEventListener(Event.CHANGE,handleTargetChange,false,0,true);
				_scrollTarget.addEventListener(TextEvent.TEXT_INPUT,handleTargetChange,false,0,true);
				_scrollTarget.addEventListener(Event.SCROLL,handleTargetScroll,false,0,true);
				addEventListener(ScrollEvent.SCROLL,updateTargetScroll,false,0,true);
			}	
			invalidate(InvalidationType.DATA);
		}
		
		[Inspectable()]
		/**
		 * @private (internal)
         * @internal For specifying in inspectable, and setting dropTarget
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */		
		public function get scrollTargetName():String {
			return _scrollTarget.name;	
		}
		/**
         * @private (setter)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function set scrollTargetName(target:String):void {
			try {
				scrollTarget = parent.getChildByName(target) as TextField;
			} catch (error:Error) {
				throw new Error("ScrollTarget not found, or is not a TextField");
			}
		}
		
		[Inspectable(defaultValue="vertical", type="list", enumeration="vertical,horizontal")]
		/**
		 * @copy fl.controls.ScrollBar#direction
         *
         * @default ScrollBarDirection.VERTICAL
         *
         * @includeExample examples/UIScrollBar.direction.1.as -noswf
         * @includeExample examples/UIScrollBar.direction.2.as -noswf
         *
         * @see ScrollBarDirection
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */		
		override public function get direction():String { return super.direction; }


		/**
         * @private (setter)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		override public function set direction(dir:String):void {
			// in live preview mode always render vertical
			if (isLivePreview) return;
			super.direction = dir;
			updateScrollTargetProperties();
		}
		
		/**
		 * Forces the scroll bar to update its scroll properties immediately.  
         * This is necessary after text in the specified <code>scrollTarget</code> text field
		 * is added using ActionScript, and the scroll bar needs to be refreshed.
         *
         * @see #scrollTarget
         *
         * @includeExample examples/UIScrollBar.update.1.as -noswf
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function update():void {
			inEdit = true;
			updateScrollTargetProperties();
			inEdit = false;
		}
		
		
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		override protected function draw():void {
			if (isInvalid(InvalidationType.DATA)) {
				updateScrollTargetProperties();
			}
			super.draw();
		}
		
	    /**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected function updateScrollTargetProperties():void {
			if (_scrollTarget == null) {
				setScrollProperties(pageSize,minScrollPosition,maxScrollPosition,pageScrollSize);
				scrollPosition = 0;
			} else {
				var horizontal:Boolean = (direction == ScrollBarDirection.HORIZONTAL);
				var pageSize:Number = horizontal ? _scrollTarget.width : 10;
				setScrollProperties(pageSize, (horizontal ? 0 : 1), horizontal?_scrollTarget.maxScrollH:_scrollTarget.maxScrollV, pageScrollSize);
				scrollPosition = horizontal?_scrollTarget.scrollH:_scrollTarget.scrollV;
			}
		}
		
		/**
		 * @copy fl.controls.ScrollBar#setScrollProperties()
         *
         * @see ScrollBar#pageSize ScrollBar.pageSize
         * @see ScrollBar#minScrollPosition ScrollBar.minScrollPosition
         * @see ScrollBar#maxScrollPosition ScrollBar.maxScrollPosition
         * @see ScrollBar#pageScrollSize ScrollBar.pageScrollSize
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		override public function setScrollProperties(pageSize:Number,minScrollPosition:Number,maxScrollPosition:Number,pageScrollSize:Number=0):void {
			var maxScrollPos:Number = maxScrollPosition;
			var minScrollPos:Number  = (minScrollPosition<0)?0:minScrollPosition;
			
			if (_scrollTarget != null) {				
				if (direction == ScrollBarDirection.HORIZONTAL) {
					maxScrollPos = (maxScrollPosition>_scrollTarget.maxScrollH) ? _scrollTarget.maxScrollH : maxScrollPos;
				} else {
					maxScrollPos = (maxScrollPosition>_scrollTarget.maxScrollV) ? _scrollTarget.maxScrollV : maxScrollPos;
				}
			}
			super.setScrollProperties(pageSize,minScrollPos,maxScrollPos,pageScrollSize);
		}
		
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		override public function setScrollPosition(scrollPosition:Number, fireEvent:Boolean=true):void {
			super.setScrollPosition(scrollPosition, fireEvent);
			if (!_scrollTarget) { inScroll = false; return; }
			updateTargetScroll();
		}
		
		// event default is null, so when user calls setScrollPosition, the text is updated, and we don't pass an event
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected function updateTargetScroll(event:ScrollEvent=null):void {
			if (inEdit) { return; } // Update came from the user input. Ignore.
			if (direction == ScrollBarDirection.HORIZONTAL) {
				_scrollTarget.scrollH = scrollPosition;
			} else {
				_scrollTarget.scrollV = scrollPosition;
			}
		}
		
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected function handleTargetChange(event:Event):void {
			inEdit = true;
			setScrollPosition((direction == ScrollBarDirection.HORIZONTAL)?_scrollTarget.scrollH:_scrollTarget.scrollV, true);
			updateScrollTargetProperties();
			inEdit = false;
		}
		
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected function handleTargetScroll(event:Event):void {
			if (inDrag) { return; }
			if (!enabled) { return; }		
			inEdit = true;
			updateScrollTargetProperties(); // This needs to be done first! 
			
			scrollPosition = (direction == ScrollBarDirection.HORIZONTAL)?_scrollTarget.scrollH:_scrollTarget.scrollV;
			inEdit = false;
		}
	}
}
