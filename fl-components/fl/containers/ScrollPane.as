// Copyright 2007. Adobe Systems Incorporated. All Rights Reserved.
package fl.containers {

	import fl.containers.BaseScrollPane;
	import fl.controls.ScrollBar;
	import fl.controls.ScrollPolicy;
	import fl.core.InvalidationType;
	import fl.core.UIComponent;
	import fl.events.ScrollEvent;
	import fl.managers.IFocusManagerComponent;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.ProgressEvent;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.ui.Keyboard;

	//--------------------------------------
	//  Events
	//--------------------------------------
    /**
     * @copy BaseScrollPane#event:scroll
     *
     * @includeExample examples/ScrollPane.scroll.1.as -noswf
     *
     * @eventType fl.events.ScrollEvent.SCROLL
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
     */
	[Event(name="scroll", type="fl.events.ScrollEvent")]

    /**
     * Dispatched while content is loading.
     *
     * @eventType flash.events.ProgressEvent.PROGRESS
     *
     * @includeExample examples/ScrollPane.percentLoaded.1.as -noswf
     *
     * @see #event:complete
     * @see #bytesLoaded
     * @see #bytesTotal
     * @see #percentLoaded
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
     */
	[Event(name="progress", type="flash.events.ProgressEvent")]

    /**
     * Dispatched when content has finished loading.
     *
     * @includeExample examples/ScrollPane.complete.1.as -noswf
     *
     * @eventType flash.events.Event.COMPLETE
     * 
     * @see #event:progress
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
     */
	[Event(name="complete", type="flash.events.Event")]


	//--------------------------------------
	//  Styles
	//--------------------------------------

    /**
     * The skin that shows when the scroll pane is disabled.
     *
     * @default ScrollPane_disabledSkin
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
     */
	[Style(name="disabledSkin", type="Class")]

    /**
     * The default skin shown on the scroll pane.
     *
     * @default ScrollPane_upSkin
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
     */
	[Style(name="upSkin", type="Class")]

    /**
     * The amount of padding to put around the content in the scroll pane, in pixels.
     *
     * @default 0
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
     */
	[Style(name="contentPadding", type="Number", format="Length")]


    //--------------------------------------
    //  Class description
    //--------------------------------------

    /**
     * The ScrollPane component displays display objects and JPEG, GIF, and PNG files,
     * as well as SWF files, in a scrollable area. You can use a scroll pane to 
     * limit the screen area that is occupied by these media types.
     * The scroll pane can display content that is loaded from a local
     * disk or from the Internet. You can set this content while
     * authoring and, at run time, by using ActionScript. After the scroll
     * pane has focus, if its content has valid tab stops, those
     * markers receive focus. After the last tab stop in the content,
     * focus moves to the next component. The vertical and horizontal
     * scroll bars in the scroll pane do not receive focus.
	 *
	 * <p><strong>Note:</strong> When content is being loaded from a different 
	 * domain or <em>sandbox</em>, the properties of the content may be inaccessible 
	 * for security reasons. For more information about how domain security 
	 * affects the load process, see the Loader class.</p>
	 *
	 * @see flash.display.Loader Loader
	 *
     * @includeExample examples/ScrollPaneExample.as -noswf
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
     */
	public class ScrollPane extends BaseScrollPane implements IFocusManagerComponent {
        /**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		protected var _source:Object = "";
        /**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		protected var _scrollDrag:Boolean = false;
        /**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		protected var contentClip:Sprite;
        /**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		protected var loader:Loader;
        /**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		protected var xOffset:Number;
        /**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		protected var yOffset:Number;
        /**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		protected var scrollDragHPos:Number;
        /**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		protected var scrollDragVPos:Number;
        /**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		protected var currentContent:Object;


        /**
         * @private
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		private static var defaultStyles:Object = {
										upSkin:"ScrollPane_upSkin",
										disabledSkin:"ScrollPane_disabledSkin",
										focusRectSkin:null,
										focusRectPadding:null,
										contentPadding:0
										}

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
			return mergeStyles(defaultStyles, BaseScrollPane.getStyleDefinition());
		}

        /**
         * Creates a new ScrollPane component instance.
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		public function ScrollPane() {
			super();
		}

        [Inspectable(type="Boolean", defaultValue="false")]
        /**
         * Gets or sets a value that indicates whether scrolling occurs when a
         * user drags on content within the scroll pane. A value of <code>true</code>
         * indicates that scrolling occurs when a user drags on the content; a value
         * of <code>false</code> indicates that it does not.
         *
         * @default false
         *
         * @includeExample examples/ScrollPane.scrollDrag.1.as -noswf
         *
         * @see #event:scroll
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		public function get scrollDrag():Boolean {
			return _scrollDrag;
		}

        /**
         * @private (setter)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		public function set scrollDrag(value:Boolean):void {
			_scrollDrag = value;
			invalidate(InvalidationType.STATE);
		}

        /**
         * Gets a number between 0 and 100 indicating what percentage of the content is loaded.
         * If you are loading assets from your library, and not externally loaded content, 
         * the <code>percentLoaded</code> property is set to 0.
         *
         * @default 0
         *
         * @includeExample examples/ScrollPane.percentLoaded.1.as -noswf
         *
         * @see #bytesLoaded
         * @see #bytesTotal
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		public function get percentLoaded():Number {
			if (loader != null) {
				return Math.round((bytesLoaded / bytesTotal) * 100);
			} else {
				return 0;
			}
		}

        /**
         * Gets the count of bytes of content that have been loaded.
         * When this property equals the value of <code>bytesTotal</code>,
         * all the bytes are loaded.  
         *
         * @default 0
         *
         * @see #bytesTotal
         * @see #percentLoaded
         *
         * @includeExample examples/ScrollPane.bytesLoaded.1.as -noswf
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		public function get bytesLoaded():Number {
			return (loader == null || loader.contentLoaderInfo == null) ? 0 : loader.contentLoaderInfo.bytesLoaded;
		}

        /**
         * Gets the count of bytes of content to be loaded.
         *
         * @default 0
         *
         * @includeExample examples/ScrollPane.percentLoaded.1.as -noswf
         *
         * @see #bytesLoaded
         * @see #percentLoaded
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		public function get bytesTotal():Number {
			return (loader == null || loader.contentLoaderInfo == null) ? 0 : loader.contentLoaderInfo.bytesTotal;
		}

        /**
         * Reloads the contents of the scroll pane. 
         *
         * <p> This method does not redraw the scroll bar. To reset the 
         * scroll bar, use the <code>update()</code> method.</p>
         *
         * @includeExample examples/ScrollPane.refreshPane.1.as -noswf
         *
         * @see #update()
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		public function refreshPane():void {
			if (_source is URLRequest) {
				_source = _source.url;
			}
			source = _source;
		}

        /**
         * Refreshes the scroll bar properties based on the width
         * and height of the content.  This is useful if the content
         * of the ScrollPane changes during run time.
         *
         * @includeExample examples/ScrollPane.update.1.as -noswf
         *
         * @see #refreshPane()
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		public function update():void {
			var child:DisplayObject = contentClip.getChildAt(0);
			setContentSize(child.width, child.height);
		}

        /**
         * Gets a reference to the content loaded into the scroll pane.
         *
         * @default null
         *
         * @includeExample examples/ScrollPane.content.1.as -noswf
         * @includeExample examples/ScrollPane.content.2.as -noswf
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		public function get content():DisplayObject {
			var c:Object = currentContent;

			if (c is URLRequest)  {
				c = loader.content;
			}

			return c as DisplayObject;
		}

        [Inspectable(type="String", defaultValue="")]
        /**
         * Gets or sets an absolute or relative URL that identifies the 
		 * location of the SWF or image file to load, the class name 
		 * of a movie clip in the library, a reference to a display object,
		 * or a instance name of a movie clip on the same level as the component.
		 * 
		 * <p>Valid image file formats include GIF, PNG, and JPEG. To load an 
		 * asset by using a URLRequest object, use the <code>load()</code> 
		 * method.</p>
         *
         * @default null
         *
         * @includeExample examples/ScrollPane.source.1.as -noswf
         * @includeExample examples/ScrollPane.source.2.as -noswf
         *
         * @see #load()
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		public function get source():Object {
			return _source;
		}

        /**
         * @private (setter)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		public function set source(value:Object):void {
			clearContent();
			if (isLivePreview) { return; }
			_source = value;
			if (_source == "" || _source == null) {
				return;
			}
			
			currentContent = getDisplayObjectInstance(value);
			if (currentContent != null) {
				var child = contentClip.addChild(currentContent as DisplayObject);
				dispatchEvent(new Event(Event.INIT));
				update();
			} else {
				load(new URLRequest(_source.toString()));
			}
		}

		/**
		 * The request parameter of this method accepts only a URLRequest object 
		 * whose <code>source</code> property contains a string, a class, or a 
		 * URLRequest object.
		 * 
		 * By default, the LoaderContext object uses the current domain as the 
		 * application domain. To specify a different application domain value, 
		 * to check a policy file, or to change the security domain, initialize 
		 * a new LoaderContext object and pass it to this method.
		 *
		 * @param request The URLRequest object to use to load an image into the scroll pane.
		 * @param context The LoaderContext object that sets the context of the load operation.
		 *
         * @see #source
         * @see fl.containers.UILoader#load() UILoader.load()
         * @see flash.net.URLRequest
         * @see flash.system.ApplicationDomain
         * @see flash.system.LoaderContext
         *
         * @includeExample examples/ScrollPane.load.1.as -noswf
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		public function load(request:URLRequest, context:LoaderContext=null):void {
			if (context == null) {
				context = new LoaderContext(false, ApplicationDomain.currentDomain);
			}
			clearContent();
			initLoader();
			currentContent = _source = request;
			loader.load(request, context);
		}

        /**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		override protected function setVerticalScrollPosition(scrollPos:Number, fireEvent:Boolean=false):void {	
			var contentScrollRect = contentClip.scrollRect;
			contentScrollRect.y = scrollPos;
			contentClip.scrollRect = contentScrollRect;
		}

        /**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		override protected function setHorizontalScrollPosition(scrollPos:Number, fireEvent:Boolean=false):void {
			var contentScrollRect = contentClip.scrollRect;
			contentScrollRect.x = scrollPos;
			contentClip.scrollRect = contentScrollRect;
		}

        /**
         * @private (protected)
         */
		override protected function drawLayout():void {
			super.drawLayout();
			contentScrollRect = contentClip.scrollRect;
			contentScrollRect.width = availableWidth;
			contentScrollRect.height = availableHeight;
			
			contentClip.cacheAsBitmap = useBitmapScrolling;
			contentClip.scrollRect = contentScrollRect;
			contentClip.x = contentClip.y = contentPadding;
		}

        /**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		protected function onContentLoad(event:Event):void {
			update();
			
			//Need to reset the sizes, for scrolling purposes.
			//Just reset the scrollbars, don't redraw the entire pane.
			var availableHeight = calculateAvailableHeight();
			calculateAvailableSize();
			horizontalScrollBar.setScrollProperties(availableWidth, 0, (useFixedHorizontalScrolling) ? _maxHorizontalScrollPosition : contentWidth - availableWidth, availableWidth);
			verticalScrollBar.setScrollProperties(availableHeight, 0, contentHeight - availableHeight, availableHeight);
			
			passEvent(event);
		}

        /**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		protected function passEvent(event:Event):void {
			dispatchEvent(event);
		}

        /**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		protected function initLoader():void {
			loader = new Loader();

			loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS,passEvent,false,0,true);
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE,onContentLoad,false,0,true);
			loader.contentLoaderInfo.addEventListener(Event.INIT,passEvent,false,0,true);

			contentClip.addChild(loader);
		}

        /**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		override protected function handleScroll(event:ScrollEvent):void {
			passEvent(event);
			super.handleScroll(event);
		}

		
        /**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		protected function doDrag(event:MouseEvent):void {
			var yPos = scrollDragVPos-(mouseY-yOffset);
			_verticalScrollBar.setScrollPosition(yPos);
			setVerticalScrollPosition(_verticalScrollBar.scrollPosition,true);
			
			var xPos = scrollDragHPos-(mouseX-xOffset);
			_horizontalScrollBar.setScrollPosition(xPos);
			setHorizontalScrollPosition(_horizontalScrollBar.scrollPosition,true);
		}

        /**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		protected function doStartDrag(event:MouseEvent):void {
			if (!enabled) { return; }
			xOffset = mouseX;
			yOffset = mouseY;
			scrollDragHPos = horizontalScrollPosition;
			scrollDragVPos = verticalScrollPosition;
			stage.addEventListener(MouseEvent.MOUSE_MOVE, doDrag, false, 0, true);
		}

        /**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		protected function endDrag(event:MouseEvent):void {
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, doDrag);
		}

        /**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		protected function setScrollDrag():void {
			if (_scrollDrag) {
				contentClip.addEventListener(MouseEvent.MOUSE_DOWN, doStartDrag, false, 0, true);
				stage.addEventListener(MouseEvent.MOUSE_UP, endDrag, false, 0, true);
			} else {
				contentClip.removeEventListener(MouseEvent.MOUSE_DOWN, doStartDrag);
				stage.removeEventListener(MouseEvent.MOUSE_UP, endDrag);
				removeEventListener(MouseEvent.MOUSE_MOVE, doDrag);
			}
			contentClip.buttonMode = _scrollDrag;
		}

        /**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		override protected function draw():void {			
			if (isInvalid(InvalidationType.STYLES)) {
				drawBackground();
			}
			
			if (isInvalid(InvalidationType.STATE)) {
				setScrollDrag();	
			}
			super.draw();
		}

        /**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		override protected function drawBackground():void {
			var bg:DisplayObject = background;
			
			background = getDisplayObjectInstance(getStyleValue(enabled ? "upSkin" : "disabledSkin"));
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
		protected function clearContent():void {
			if (contentClip.numChildren == 0) { return; }
			contentClip.removeChildAt(0);
			currentContent = null;
			if (loader != null) {
				try {
					loader.close();
				} catch (e:*) {}

				try {
					loader.unload();
				} catch (e:*) {}

				loader = null;
			}
		}

        /**
         * @private
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		override protected function keyDownHandler(event:KeyboardEvent):void {
			var pageSize:int = calculateAvailableHeight();
			switch (event.keyCode) {
				case Keyboard.DOWN:
					verticalScrollPosition++;
					break;
				case Keyboard.UP:
					verticalScrollPosition--;
					break;
				case Keyboard.RIGHT:
					horizontalScrollPosition++;
					break;
				case Keyboard.LEFT:
					horizontalScrollPosition--;
					break;
				case Keyboard.END:
					verticalScrollPosition = maxVerticalScrollPosition;
					break;
				case Keyboard.HOME:
					verticalScrollPosition = 0;
					break;
				case Keyboard.PAGE_UP:
					verticalScrollPosition -= pageSize;
					break;
				case Keyboard.PAGE_DOWN:
					verticalScrollPosition += pageSize;
					break;
			}
		}

        /**
         * @private
         */
		protected function calculateAvailableHeight():Number {
			var pad:Number = Number(getStyleValue("contentPadding"));
			return height-pad*2-((_horizontalScrollPolicy == ScrollPolicy.ON || (_horizontalScrollPolicy == ScrollPolicy.AUTO && _maxHorizontalScrollPosition > 0)) ? 15 : 0);
		}

        /**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		override protected function configUI():void {
			super.configUI();
			contentClip = new Sprite();
			addChild(contentClip);
			contentClip.scrollRect = contentScrollRect; 
			_horizontalScrollPolicy = ScrollPolicy.AUTO;
			_verticalScrollPolicy = ScrollPolicy.AUTO;
		}
	}
}
