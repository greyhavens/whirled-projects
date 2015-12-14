// Copyright 2007. Adobe Systems Incorporated. All Rights Reserved.
package fl.controls.listClasses {

	import fl.controls.listClasses.CellRenderer;
	import fl.controls.listClasses.ICellRenderer;
	import fl.controls.listClasses.ListData;
	import fl.controls.listClasses.TileListData;
	import fl.controls.TextInput; //Only for ASDocs
	import fl.containers.UILoader;
	import fl.core.InvalidationType;
	import fl.core.UIComponent;
	import flash.display.Graphics;
	import flash.display.Shape;	
	import flash.events.IOErrorEvent;

    //--------------------------------------
    //  Styles
    //--------------------------------------
	/**
	 * The skin that is used to indicate the selected state.
	 *
     * @default ImageCell_selectedSkin
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
	 */
	[Style(name="selectedSkin", type="Class")]
	/**
	 * The padding that separates the edge of the cell from the edge of the text, 
	 * in pixels.
	 *
     * @default 3
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
	 */
	[Style(name="textPadding", type="Number", format="Length")]
	/**
	 * The padding that separates the edge of the cell from the edge of the image, 
	 * in pixels.
	 *
     * @default 1
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
	 */
	[Style(name="imagePadding", type="Number", format="Length")]
	
	/**
	 * The opacity of the overlay behind the cell label.
	 *
	 * @default 0.7
	 * 
	 */
	[Style(name="textOverlayAlpha", type="Number", format="Length")]

    //--------------------------------------
    //  Class description
    //--------------------------------------
	/**
	 * The ImageCell is the default cell renderer for the TileList
     * component. An ImageCell class accepts <code>label</code> and 
	 * <code>source</code> properties, and displays a thumbnail and 
	 * single-line label.
	 *
	 * <p><strong>Note:</strong> When content is being loaded from a different 
	 * domain or <em>sandbox</em>, the properties of the content may be inaccessible
	 * for security reasons. For more information about how domain security 
	 * affects the load process, see the Loader class.</p>
     *
     * @see flash.display.Loader Loader
     *
	 * @includeExample examples/ImageCellExample.as
	 *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
	 */
	public class ImageCell extends CellRenderer implements ICellRenderer {

		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected var textOverlay:Shape;
		
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected var loader:UILoader;
		
		
		/**
         * @private
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		private static var defaultStyles:Object = {
												imagePadding:1,
												textOverlayAlpha:0.7
												};
												
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
		public static function getStyleDefinition():Object {
			return mergeStyles(defaultStyles, CellRenderer.getStyleDefinition());
		}


		/**
         * Creates a new ImageCell instance.
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function ImageCell() {
			super();
			
			loader = new UILoader();
			
			loader.addEventListener(IOErrorEvent.IO_ERROR, handleErrorEvent, false, 0, true);
			
			loader.autoLoad = true;
			loader.scaleContent = true;
			addChild(loader);
		}

		/**
         * Gets or sets the list properties that are applied to the cell, for example,
		 * the <code>index</code> and <code>selected</code> values. These list properties
		 * are automatically updated after the cell is invalidated.
		 *
		 * <p>Although the listData property returns an instance of ListData, in the
		 * TileList cells receive an instance of <code>TileListData</code> instead, 
		 * which contains a <code>source</code> property.</p>
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		override public function get listData():ListData {
			return _listData;
		}
		
		/**
         * @private (setter)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		override public function set listData(value:ListData):void {
			_listData = value;
			label = _listData.label;
			var newSource:Object = (_listData as TileListData).source;
			if (source != newSource) { // Prevent always reloading...
				source = newSource;
			}
		}
			
		
		/**
         * Gets or sets an absolute or relative URL that identifies the 
		 * location of the SWF or image file to load, the class name 
		 * of a movie clip in the library, or a reference to a display 
		 * object.
		 * 
		 * <p>Valid image file formats include GIF, PNG, and JPEG.</p>
         *
         * @default null
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		public function get source():Object { 
			return loader.source;
		}
		/**
		 * @private (setter)
		 *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function set source(value:Object):void {
			loader.source = value;
		}
		
		
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		override protected function configUI():void {
			super.configUI();
			
			textOverlay = new Shape();
			var g:Graphics = textOverlay.graphics;
			g.beginFill(0xFFFFFF);
			g.drawRect(0,0,100,100);
			g.endFill();
		}
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		override protected function draw():void {
			super.draw();
		}

		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		override protected function drawLayout():void {
			var imagePadding:Number = getStyleValue("imagePadding") as Number;
			loader.move(imagePadding, imagePadding);
			
			var w:Number = width-(imagePadding*2);
			var h:Number = height-imagePadding*2;
			if (loader.width != w && loader.height != h) {
				loader.setSize(w,h);
			}
			loader.drawNow(); // Force validation!
			
			// Position textfield
			if (_label == "" || _label == null) {
				if (contains(textField)) { removeChild(textField); }
				if (contains(textOverlay)) { removeChild(textOverlay); }
			} else {
				var textPadding:Number = getStyleValue("textPadding") as Number;
				textField.width = Math.min(width-textPadding*2, textField.textWidth+5);
				textField.height = textField.textHeight + 5;
				textField.x = Math.max(textPadding, width/2-textField.width/2);
				textField.y = height - textField.height - textPadding; // Multiline is not supported.
				
				textOverlay.x = imagePadding;
				textOverlay.height = textField.height + textPadding*2;
				textOverlay.y = height - textOverlay.height - imagePadding;
				textOverlay.width = width - imagePadding*2;
				textOverlay.alpha = getStyleValue("textOverlayAlpha") as Number;
				
				addChild(textOverlay);
				addChild(textField);
			}
			
			background.width = width;
			background.height = height;
		}
		
		/**
		 * @private (protected)
		 */
		protected function handleErrorEvent(event:IOErrorEvent):void {
			dispatchEvent(event);
		}
		
	}
}