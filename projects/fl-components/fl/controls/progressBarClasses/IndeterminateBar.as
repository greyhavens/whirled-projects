// Copyright 2007. Adobe Systems Incorporated. All Rights Reserved.
package fl.controls.progressBarClasses {
	
	import fl.controls.ProgressBar;
	import fl.core.UIComponent;
	import fl.core.InvalidationType;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.Event;
	
	
    //--------------------------------------
    //  Styles
    //--------------------------------------
    /**
     * @copy fl.controls.ProgressBar#style:indeterminateSkin
     *
     * @default ProgressBar_indeterminateSkin
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
     */
    [Style(name="indeterminateSkin", type="Class")]


    //--------------------------------------
    //  Class description
    //--------------------------------------
	/**
	 * The IndeterminateBar class handles the drawing of the progress bar component when the 
	 * size of the source that is being loaded is unknown. This class can be replaced with any 
	 * other UIComponent class to render the bar differently. The default implementation uses 
	 * the drawing API create a striped fill to indicate the progress of the load operation.
	 *
	 * @includeExample examples/IndeterminateBarExample.as
	 *
     * @see fl.controls.ProgressBar
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
	 */
	public class IndeterminateBar extends UIComponent {
		
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected var animationCount:uint = 0;
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected var bar:Sprite;
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected var barMask:Sprite;
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected var patternBmp:BitmapData
		
        /**
         * @private
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		private static var defaultStyles:Object = {indeterminateSkin:"ProgressBar_indeterminateSkin"};
		/**
         * @copy fl.core.UIComponent#getStyleDefinition()
         *
		 * @includeExample ../../core/examples/UIComponent.getStyleDefinition.1.as -noswf
		 *
         * @see fl.core.UIComponent#getStyle()
         * @see fl.core.UIComponent#setStyle()
         * @see fl.managers.StyleManager
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public static function getStyleDefinition():Object { return defaultStyles; }
		
		
		/**
         * Creates a new instance of the IndeterminateBar component.
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function IndeterminateBar() {
			super();
			setSize(0,0);
			startAnimation();
		}
		


		/**
         * Gets or sets a Boolean value that indicates whether the indeterminate bar is visible.
		 * A value of <code>true</code> indicates that the indeterminate bar is visible; a value
		 * of <code>false</code> indicates that it is not.
         *
         * @default true
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		override public function get visible():Boolean {
			return super.visible;
        }

		/**
         * @private (setter)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		override public function set visible(value:Boolean):void {
			if (value) {
				startAnimation();
			} else {
				stopAnimation();
			}
			super.visible = value;
		}
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected function startAnimation():void {
			addEventListener(Event.ENTER_FRAME,handleEnterFrame,false,0,true);
		}
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected function stopAnimation():void {
			removeEventListener(Event.ENTER_FRAME,handleEnterFrame);
		}
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected function handleEnterFrame(event:Event):void {
			if (patternBmp == null) { return; }
			animationCount = (animationCount+2)%patternBmp.width;
			bar.x = -animationCount;
		}
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		override protected function configUI():void {
			bar = new Sprite();
			addChild(bar);
			barMask = new Sprite();
			addChild(barMask);
			bar.mask = barMask;
		}
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		override protected function draw():void {
			if (isInvalid(InvalidationType.STYLES)) {
				drawPattern();
				invalidate(InvalidationType.SIZE,false);
			}
			if (isInvalid(InvalidationType.SIZE)) {
				drawBar();
				drawMask();
			}
			super.draw();
		}
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected function drawPattern():void {
			var skin:DisplayObject = getDisplayObjectInstance(getStyleValue("indeterminateSkin"));
			if (patternBmp) {
				patternBmp.dispose();
			}
			patternBmp = new BitmapData(skin.width<<0,skin.height<<0,true,0);
			patternBmp.draw(skin);
		}
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected function drawMask():void {
			var g:Graphics = barMask.graphics;
			g.clear();
			g.beginFill(0,0);
			g.drawRect(0,0,_width,_height);
			g.endFill();
		}
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected function drawBar():void {
			if (patternBmp == null) { return; }
			var g:Graphics = bar.graphics;
			g.clear();
			g.beginBitmapFill(patternBmp);
			g.drawRect(0,0,_width+patternBmp.width,_height);
			g.endFill();
		}
	}
}