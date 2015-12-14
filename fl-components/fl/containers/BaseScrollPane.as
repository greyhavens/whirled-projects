// Copyright 2007. Adobe Systems Incorporated. All Rights Reserved.
package fl.containers {

	import fl.core.UIComponent;
	import fl.controls.BaseButton;
	import fl.controls.ScrollBar;
	import fl.events.ScrollEvent;
	import fl.controls.ScrollPolicy;
	import fl.controls.ScrollBarDirection;
	import fl.core.InvalidationType;
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.Graphics;
	import flash.geom.Rectangle;
	
	//--------------------------------------
    //  Events
    //--------------------------------------
	
	/**
	 * Dispatched when the user scrolls content by using the scroll bars on the
	 * component or the wheel on a mouse device.
     *
     * @eventType fl.events.ScrollEvent.SCROLL
     *
     * @includeExample examples/ScrollPane.scroll.1.as -noswf
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
	 */
	[Event(name="scroll", type="fl.events.ScrollEvent")]
	
	
    //--------------------------------------
    //  Styles
    //--------------------------------------
    /**
     * @copy fl.controls.ScrollBar#style:downArrowDisabledSkin
     *
     * @default ScrollArrowDown_disabledSkin
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
     */
    [Style(name="downArrowDisabledSkin", type="Class")]
    
    
    /**
     * @copy fl.controls.ScrollBar#style:downArrowDownSkin
     *
     * @default ScrollArrowDown_downSkin
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
     */
    [Style(name="downArrowDownSkin", type="Class")]
    
    
    /**
     * @copy fl.controls.ScrollBar#style:downArrowOverSkin
     *
     * @default ScrollArrowDown_overSkin
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
     */
    [Style(name="downArrowOverSkin", type="Class")]

    /**
     * @copy fl.controls.ScrollBar#style:downArrowUpSkin
     *
     * @default ScrollArrowDown_upSkin
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
     */
    [Style(name="downArrowUpSkin", type="Class")]

    /**
     * @copy fl.controls.ScrollBar#style:thumbDisabledSkin
     *
     * @default ScrollThumb_upSkin
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
     */
    [Style(name="thumbDisabledSkin", type="Class")]

    /**
     * @copy fl.controls.ScrollBar#style:thumbDownSkin
     *
     * @default ScrollThumb_downSkin
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
     */
    [Style(name="thumbDownSkin", type="Class")]

    /**
     * @copy fl.controls.ScrollBar#style:thumbOverSkin
     *
     * @default ScrollThumb_overSkin
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
     */
    [Style(name="thumbOverSkin", type="Class")]

    /**
     * @copy fl.controls.ScrollBar#style:thumbUpSkin
	 *
     * @default ScrollThumb_upSkin
     * 
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
     */
    [Style(name="thumbUpSkin", type="Class")]

    /**
     * @copy fl.controls.ScrollBar#style:trackDisabledSkin
     *
     * @default ScrollTrack_Skin
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
     */
    [Style(name="trackDisabledSkin", type="Class")]

    /**
     * @copy fl.controls.ScrollBar#style:trackDownSkin
     *
     * @default ScrollTrack_Skin
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
     */
    [Style(name="trackDownSkin", type="Class")]
    /**
     * @copy fl.controls.ScrollBar#style:trackOverSkin
     *
     * @default ScrollTrack_Skin
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
     */
    [Style(name="trackOverSkin", type="Class")]
    /**
     * @copy fl.controls.ScrollBar#style:trackUpSkin
     *
     * @default ScrollTrack_Skin
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
     */
    [Style(name="trackUpSkin", type="Class")]
    /**
     * @copy fl.controls.ScrollBar#style:upArrowDisabledSkin
     *
     * @default ScrollArrowUp_disabledSkin
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
     */
    [Style(name="upArrowDisabledSkin", type="Class")]
    /**
     * @copy fl.controls.ScrollBar#style:upArrowDownSkin
     *
     * @default ScrollArrowUp_downSkin
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
     */
    [Style(name="upArrowDownSkin", type="Class")]
    /**
     * @copy fl.controls.ScrollBar#style:upArrowOverSkin
     *
     * @default ScrollArrowUp_overSkin
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
     */
    [Style(name="upArrowOverSkin", type="Class")]
    /**
     * @copy fl.controls.ScrollBar#style:upArrowUpSkin
     *
     * @default ScrollArrowUp_upSkin
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
     */
    [Style(name="upArrowUpSkin", type="Class")]
    /**
     * @copy fl.controls.ScrollBar#style:thumbIcon
     *
     * @default ScrollBar_thumbIcon
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
     */
    [Style(name="thumbIcon", type="Class")]
   	
	/**
     * @copy fl.controls.BaseButton#style:repeatDelay
	 * 
     * @default 500
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
     */
    [Style(name="repeatDelay", type="Number", format="Time")]
	 
	 /**
     * @copy fl.controls.BaseButton#style:repeatInterval
	 * 
     * @default 35
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
     */
    [Style(name="repeatInterval", type="Number", format="Time")]
	
	/**
     * The skin to be used as the background of the scroll pane.
     *
     * @default ScrollPane_upSkin
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
     */
    [Style(name="skin", type="Class")]
	
    /**
     * Padding between the content (the component and scroll bar), and the outside edge of the background, in pixels.
     *
     * @default 0
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
	 * @internal [kenos] What does "control and scrollbar" mean here -- what is the relationship between these
	 *                   elements and the content? I'd like to make this more understandable
	 *                   but don't know how it should be written based on the current description.
     */
    [Style(name="contentPadding", type="Number", format="Length")]
	
	/**
     * When the <code>enabled</code> property is set to <code>false</code>, 
     * interaction with the component is prevented and a white overlay is 
     * displayed over the component, dimming the component contents.  The 
     * <code>disabledAlpha</code> style specifies the level of transparency
	 * that is applied to this overlay. Valid values range from 0, for an 
     * overlay that is completely transparent, to 1 for an overlay that is opaque. 
     *
     * @default 0.5
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
     */
    [Style(name="disabledAlpha", type="Number", format="Length")]


    //--------------------------------------
    //  Class description
    //--------------------------------------
	/**
	 * The BaseScrollPane class handles basic scroll pane functionality including events, styling, 
	 * drawing the mask and background, the layout of scroll bars, and the handling of scroll positions.
	 * 
	 * <p>By default, the BaseScrollPane class is extended by the ScrollPane and SelectableList classes,
	 * for all list-based components.  This means that any component that uses horizontal or vertical 
	 * scrolling does not need to implement any scrolling, masking or layout logic, except for behavior
	 * that is specific to the component.</p>
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
	 */
	public class BaseScrollPane extends UIComponent {
		
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected var _verticalScrollBar:ScrollBar;
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected var _horizontalScrollBar:ScrollBar;
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected var contentScrollRect:Rectangle;
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected var disabledOverlay:Shape;
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected var background:DisplayObject;
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected var contentWidth:Number=0;
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected var contentHeight:Number=0;
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected var _horizontalScrollPolicy:String;
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected var _verticalScrollPolicy:String;
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected var contentPadding:Number=0;
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected var availableWidth:Number;
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected var availableHeight:Number;
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected var vOffset:Number = 0;
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected var vScrollBar:Boolean;
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected var hScrollBar:Boolean;
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected var _maxHorizontalScrollPosition:Number = 0;		
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected var _horizontalPageScrollSize:Number = 0;	
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected var _verticalPageScrollSize:Number = 0;
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected var defaultLineScrollSize:Number = 4;
		
		/**
         * @private (protected)
         *
         * If <code>false</code>, uses <code>contentWidth</code> to determine hscroll, otherwise uses fixed <code>_maxHorizontalScroll</code> value.
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected var useFixedHorizontalScrolling:Boolean = false; // if false, uses contentWidth to determine hscroll, otherwise uses fixed _maxHorizontalScroll value
		
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected var _useBitmpScrolling:Boolean = false;
		
		/**
         * @private
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		private static var defaultStyles:Object = {	 
											repeatDelay:500,repeatInterval:35,
											skin:"ScrollPane_upSkin",
											contentPadding:0,
											disabledAlpha:0.5
											};
		/**
		 * @copy fl.core.UIComponent#getStyleDefinition()
         *
		 * @includeExample ../core/examples/UIComponent.getStyleDefinition.1.as -noswf
		 *
         * @see fl.core.UIComponent#getStyle() UIComponent.getStyle()
         * @see fl.core.UIComponent#setStyle() UIComponent.setStyle()
         * @see fl.managers.StyleManager StyleManager
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public static function getStyleDefinition():Object { 
			return mergeStyles(defaultStyles, ScrollBar.getStyleDefinition());
		}

		
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected static const SCROLL_BAR_STYLES:Object = {
											upArrowDisabledSkin: "upArrowDisabledSkin",
											upArrowDownSkin:"upArrowDownSkin",
											upArrowOverSkin:"upArrowOverSkin",
											upArrowUpSkin:"upArrowUpSkin",
											downArrowDisabledSkin:"downArrowDisabledSkin",
											downArrowDownSkin:"downArrowDownSkin",
											downArrowOverSkin:"downArrowOverSkin",
											downArrowUpSkin:"downArrowUpSkin",
											thumbDisabledSkin:"thumbDisabledSkin",
											thumbDownSkin:"thumbDownSkin",
											thumbOverSkin:"thumbOverSkin",
											thumbUpSkin:"thumbUpSkin",
											thumbIcon:"thumbIcon",
											trackDisabledSkin:"trackDisabledSkin",
											trackDownSkin:"trackDownSkin",
											trackOverSkin:"trackOverSkin",
											trackUpSkin:"trackUpSkin",
											repeatDelay:"repeatDelay",
											repeatInterval:"repeatInterval"
											};


		/**
         * Creates a new BaseScrollPane component instance.
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function BaseScrollPane() {
			super();
        }
        
		[Inspectable(defaultValue=true, verbose=1)]
		/**
         * @private
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		override public function set enabled(value:Boolean):void {
			if (enabled == value) { 
				return;
			}
			_verticalScrollBar.enabled = value;
			_horizontalScrollBar.enabled = value;
			super.enabled = value;
		}


		[Inspectable(defaultValue="auto",enumeration="on,off,auto")]
		/**
         * Gets or sets a value that indicates the state of the horizontal scroll
		 * bar. A value of <code>ScrollPolicy.ON</code> indicates that the horizontal 
		 * scroll bar is always on; a value of <code>ScrollPolicy.OFF</code> indicates
		 * that the horizontal scroll bar is always off; and a value of <code>ScrollPolicy.AUTO</code>
		 * indicates that its state automatically changes. This property is used with 
         * other scrolling properties to set the <code>setScrollProperties()</code> method
		 * of the scroll bar.
		 *
		 * @default ScrollPolicy.AUTO
         *
         * @see #verticalScrollPolicy
         * @see fl.controls.ScrollPolicy ScrollPolicy
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function get horizontalScrollPolicy():String {
			return _horizontalScrollPolicy;
		}

		/**
         * @private (setter)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function set horizontalScrollPolicy(value:String):void {
			_horizontalScrollPolicy = value;
			invalidate(InvalidationType.SIZE);
		}

		[Inspectable(defaultValue="auto",enumeration="on,off,auto")]
		/**
         * Gets or sets a value that indicates the state of the vertical scroll
		 * bar. A value of <code>ScrollPolicy.ON</code> indicates that the vertical
		 * scroll bar is always on; a value of <code>ScrollPolicy.OFF</code> indicates
		 * that the vertical scroll bar is always off; and a value of <code>ScrollPolicy.AUTO</code>
		 * indicates that its state automatically changes. This property is used with 
         * other scrolling properties to set the <code>setScrollProperties()</code> method
		 * of the scroll bar.
		 *
		 * @default ScrollPolicy.AUTO
         *
         * @see #horizontalScrollPolicy
         * @see fl.controls.ScrollPolicy ScrollPolicy
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function get verticalScrollPolicy():String {
			return _verticalScrollPolicy;
		}		
		/**
         * @private
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function set verticalScrollPolicy(value:String):void {
			_verticalScrollPolicy = value;
			invalidate(InvalidationType.SIZE);
		}
		
		[Inspectable(defaultValue=4)]
		/**
		 * Gets or sets a value that describes the amount of content to be scrolled,
		 * horizontally, when a scroll arrow is clicked. This value is measured in pixels.
         *
         * @default 4
         *
         * @see #horizontalPageScrollSize
         * @see #verticalLineScrollSize
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function get horizontalLineScrollSize():Number {
			return _horizontalScrollBar.lineScrollSize;
		}
		
		/**
         * @private (setter)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function set horizontalLineScrollSize(value:Number):void {
			_horizontalScrollBar.lineScrollSize = value;
		}
		

		[Inspectable(defaultValue=4)]
		/**
		 * Gets or sets a value that describes how many pixels to scroll vertically when a scroll arrow is clicked. 
         *
         * @default 4
         *
         * @see #horizontalLineScrollSize
         * @see #verticalPageScrollSize
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function get verticalLineScrollSize():Number {
			return _verticalScrollBar.lineScrollSize;
		}
		/**
         * @private (setter)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function set verticalLineScrollSize(value:Number):void {
			_verticalScrollBar.lineScrollSize = value;
		}
		
		/**
		 * Gets or sets a value that describes the horizontal position of the 
		 * horizontal scroll bar in the scroll pane, in pixels.
         *
         * @default 0
         *
         * @includeExample examples/BaseScrollPane.horizontalScrollPosition.1.as -noswf
         *
         * @see #maxHorizontalScrollPosition
         * @see #verticalScrollPosition
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function get horizontalScrollPosition():Number {
			return _horizontalScrollBar.scrollPosition;
		}

		/**
         * @private (setter)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function set horizontalScrollPosition(value:Number):void {
			// We must force a redraw to ensure that the size is up to date.
			drawNow();
			
			_horizontalScrollBar.scrollPosition = value;
			setHorizontalScrollPosition(_horizontalScrollBar.scrollPosition,false);
		}
		

		/**
		 * Gets or sets a value that describes the vertical position of the 
		 * vertical scroll bar in the scroll pane, in pixels.
         *
         * @default 0
         *
         * @includeExample examples/BaseScrollPane.horizontalScrollPosition.1.as -noswf
         *
         * @see #horizontalScrollPosition
         * @see #maxVerticalScrollPosition
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function get verticalScrollPosition():Number {
			return _verticalScrollBar.scrollPosition;
		}

		/**
         * @private (setter)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function set verticalScrollPosition(value:Number):void {
			// We must force a redraw to ensure that the size is up to date.
			drawNow();
			
			_verticalScrollBar.scrollPosition = value;
			setVerticalScrollPosition(_verticalScrollBar.scrollPosition,false);
		}
		

		/**
		 * Gets the maximum horizontal scroll position for the current content, in pixels.
         *
         * @see #horizontalScrollPosition
         * @see #maxVerticalScrollPosition
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function get maxHorizontalScrollPosition():Number {
			drawNow();
			return Math.max(0,contentWidth-availableWidth);
		}

		/**
		 * Gets the maximum vertical scroll position for the current content, in pixels.
         *
         * @see #maxHorizontalScrollPosition
         * @see #verticalScrollPosition
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function get maxVerticalScrollPosition():Number {
			drawNow();
			return Math.max(0,contentHeight-availableHeight);
		}
		
		/**
		 * When set to <code>true</code>, the <code>cacheAsBitmap</code> property for the scrolling content is set 
		 * to <code>true</code>; when set to <code>false</code> this value is turned off.
         *
		 * <p><strong>Note:</strong> Setting this property to <code>true</code> increases scrolling performance.</p>
         *
         * @default false
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function get useBitmapScrolling():Boolean {
			return _useBitmpScrolling;
		}
		
		/**
         * @private (setter)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function set useBitmapScrolling(value:Boolean):void {
			_useBitmpScrolling = value;
			invalidate(InvalidationType.STATE);
		}
		
		[Inspectable(defaultValue=0)]
		/**
		 * Gets or sets the count of pixels by which to move the scroll thumb 
		 * on the horizontal scroll bar when the scroll bar track is pressed. When 
		 * this value is 0, this property retrieves the available width of the component.
         *
         * @default 0
         *
         * @see #horizontalLineScrollSize
         * @see #verticalPageScrollSize
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		public function get horizontalPageScrollSize():Number {
			if (isNaN(availableWidth)) { drawNow(); }
			return (_horizontalPageScrollSize == 0 && !isNaN(availableWidth)) ? availableWidth : _horizontalPageScrollSize;
		}
		/**
         * @private (setter)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function set horizontalPageScrollSize(value:Number):void {
			_horizontalPageScrollSize = value;
			invalidate(InvalidationType.SIZE);	
		}
		
		
		[Inspectable(defaultValue=0)]
		/**
         * Gets or sets the count of pixels by which to move the scroll thumb 
		 * on the vertical scroll bar when the scroll bar track is pressed. When 
		 * this value is 0, this property retrieves the available height of the component.
         *
         * @default 0
         *
         * @see #horizontalPageScrollSize
         * @see #verticalLineScrollSize
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 * @internal [kenos] Is available height specified in pixels?
         */
		public function get verticalPageScrollSize():Number {
			if (isNaN(availableHeight)) { drawNow(); }
			return (_verticalPageScrollSize == 0 && !isNaN(availableHeight)) ? availableHeight : _verticalPageScrollSize;
		}
		/**
         * @private (setter)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function set verticalPageScrollSize(value:Number):void {
			_verticalPageScrollSize = value;
			invalidate(InvalidationType.SIZE);	
		}
		
		/**
		 * Gets a reference to the horizontal scroll bar.
         *
         * @see #verticalScrollBar
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function get horizontalScrollBar():ScrollBar {
			return _horizontalScrollBar;
		}
		/**
		 * Gets a reference to the vertical scroll bar.
         *
         * @see #horizontalScrollBar
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function get verticalScrollBar():ScrollBar {
			return _verticalScrollBar;
		}		
		
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		override protected function configUI():void {
			super.configUI();

			//contentScrollRect is not actually used by BaseScrollPane, only by subclasses.
			contentScrollRect = new Rectangle(0,0,85,85);

			// set up vertical scroll bar:
			_verticalScrollBar = new ScrollBar();
			_verticalScrollBar.addEventListener(ScrollEvent.SCROLL,handleScroll,false,0,true);
			_verticalScrollBar.visible = false;
			_verticalScrollBar.lineScrollSize = defaultLineScrollSize;
			addChild(_verticalScrollBar);
			copyStylesToChild(_verticalScrollBar,SCROLL_BAR_STYLES);

			// set up horizontal scroll bar:
			_horizontalScrollBar = new ScrollBar();
			_horizontalScrollBar.direction = ScrollBarDirection.HORIZONTAL;
			_horizontalScrollBar.addEventListener(ScrollEvent.SCROLL,handleScroll,false,0,true);
			_horizontalScrollBar.visible = false;
			_horizontalScrollBar.lineScrollSize = defaultLineScrollSize;
			addChild(_horizontalScrollBar);
			copyStylesToChild(_horizontalScrollBar,SCROLL_BAR_STYLES);
			
			// Create the disabled overlay
			disabledOverlay = new Shape();
			var g:Graphics = disabledOverlay.graphics;
			g.beginFill(0xFFFFFF);
			g.drawRect(0,0,width,height);
			g.endFill();
			
			addEventListener(MouseEvent.MOUSE_WHEEL,handleWheel,false,0,true);
		}

		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected function setContentSize(width:Number,height:Number):void {
			if ((contentWidth == width || useFixedHorizontalScrolling) && contentHeight == height) { return; }
			
			contentWidth = width;
			contentHeight = height;
			invalidate(InvalidationType.SIZE);
		}

        /**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected function handleScroll(event:ScrollEvent):void {
			if (event.target == _verticalScrollBar) {
				setVerticalScrollPosition(event.position);
			} else {
				setHorizontalScrollPosition(event.position);
			}
		}

        /**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected function handleWheel(event:MouseEvent):void {
			if (!enabled || !_verticalScrollBar.visible || contentHeight <= availableHeight) {
				return;
			}
			_verticalScrollBar.scrollPosition -= event.delta * verticalLineScrollSize;
			setVerticalScrollPosition(_verticalScrollBar.scrollPosition);
			
			dispatchEvent(new ScrollEvent(ScrollBarDirection.VERTICAL, event.delta, horizontalScrollPosition));
		}

		// These are meant to be overriden by subclasses:
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected function setHorizontalScrollPosition(scroll:Number,fireEvent:Boolean=false):void {}
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected function setVerticalScrollPosition(scroll:Number,fireEvent:Boolean=false):void {}

		
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		override protected function draw():void {
			if (isInvalid(InvalidationType.STYLES)) {
				setStyles();
				drawBackground();
				// drawLayout is expensive, so only do it if padding has changed:
				if (contentPadding != getStyleValue("contentPadding")) {
					invalidate(InvalidationType.SIZE,false);
				}
			}
			if (isInvalid(InvalidationType.SIZE, InvalidationType.STATE)) {
				drawLayout();
			}
			// Call drawNow() on nested components to get around problems with nested render events:
			updateChildren();
			super.draw();
		}

		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected function setStyles():void {
			copyStylesToChild(_verticalScrollBar,SCROLL_BAR_STYLES);
			copyStylesToChild(_horizontalScrollBar,SCROLL_BAR_STYLES);
		}

        /**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected function drawBackground():void {
			var bg:DisplayObject = background;
			
			background = getDisplayObjectInstance(getStyleValue("skin"));
			background.width = width;
			background.height = height;
			addChildAt(background,0);
			
			if (bg != null && bg != background) { removeChild(bg); }
		}

        /**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected function drawLayout():void {
			calculateAvailableSize();
			calculateContentWidth();
			
			background.width = width;
			background.height = height;

			if (vScrollBar) {
				_verticalScrollBar.visible = true;
				_verticalScrollBar.x = width - ScrollBar.WIDTH - contentPadding;
				_verticalScrollBar.y = contentPadding;
				_verticalScrollBar.height = availableHeight;
			} else {
				_verticalScrollBar.visible = false;
			}
			
			_verticalScrollBar.setScrollProperties(availableHeight, 0, contentHeight - availableHeight, verticalPageScrollSize);
			setVerticalScrollPosition(_verticalScrollBar.scrollPosition, false);

			if (hScrollBar) {
				_horizontalScrollBar.visible = true;
				_horizontalScrollBar.x = contentPadding;
				_horizontalScrollBar.y = height - ScrollBar.WIDTH - contentPadding;
				_horizontalScrollBar.width = availableWidth;
			} else {
				_horizontalScrollBar.visible = false;
			}
			
			_horizontalScrollBar.setScrollProperties(availableWidth, 0, (useFixedHorizontalScrolling) ? _maxHorizontalScrollPosition : contentWidth - availableWidth, horizontalPageScrollSize);
			setHorizontalScrollPosition(_horizontalScrollBar.scrollPosition, false);
			
			drawDisabledOverlay();
		}
		
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected function drawDisabledOverlay():void {
			if (enabled) {
				if (contains(disabledOverlay)) { removeChild(disabledOverlay); }
			} else {
				disabledOverlay.x = disabledOverlay.y = contentPadding;
				disabledOverlay.width = availableWidth;
				disabledOverlay.height = availableHeight;
				disabledOverlay.alpha = getStyleValue("disabledAlpha") as Number;
				addChild(disabledOverlay);
			}
		}

        /**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		protected function calculateAvailableSize():void {
			var scrollBarWidth:Number = ScrollBar.WIDTH;
			var padding:Number = contentPadding = Number(getStyleValue("contentPadding"));
			
			// figure out which scrollbars we need
			var availHeight:Number = height-2*padding - vOffset;
			vScrollBar = (_verticalScrollPolicy == ScrollPolicy.ON) || (_verticalScrollPolicy == ScrollPolicy.AUTO && contentHeight > availHeight);
			var availWidth:Number = width - (vScrollBar ? scrollBarWidth : 0) - 2 * padding;
			var maxHScroll:Number = (useFixedHorizontalScrolling) ? _maxHorizontalScrollPosition : contentWidth - availWidth;
			hScrollBar = (_horizontalScrollPolicy == ScrollPolicy.ON) || (_horizontalScrollPolicy == ScrollPolicy.AUTO && maxHScroll > 0);
			if (hScrollBar) { availHeight -= scrollBarWidth; }
			// catch the edge case of the horizontal scroll bar necessitating a vertical one:
			if (hScrollBar && !vScrollBar && _verticalScrollPolicy == ScrollPolicy.AUTO && contentHeight > availHeight) {
				vScrollBar = true;
				availWidth -= scrollBarWidth;
			}
			availableHeight = availHeight + vOffset;
			availableWidth = availWidth;
		}
		
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected function calculateContentWidth():void {
			// Meant to be overriden by subclasses
		}
		
        /**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected function updateChildren():void {
			_verticalScrollBar.enabled = _horizontalScrollBar.enabled = enabled;
			_verticalScrollBar.drawNow();
			_horizontalScrollBar.drawNow();
		}
	}
}