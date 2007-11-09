// Copyright 2007. Adobe Systems Incorporated. All Rights Reserved.
package fl.data {
	
	/**
	 * The TileListCollectionItem class defines a single item in an inspectable
	 * property that represents a data provider. A TileListCollectionItem object
	 * is a collection list item that contains only <code>label</code> and
	 * <code>source</code> properties, and is primarily used in the TileList
	 * component.
	 *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
	 */
	dynamic public class TileListCollectionItem {
		
		[Inspectable()]
		/**
		 * The <code>label</code> property of the object.
		 *
         * The default value is <code>label(<em>n</em>)</code>, where <em>n</em> is the ordinal index.
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public var label:String;
		
		[Inspectable()]
		/**
		 * The <code>source</code> property of the object. This can be the path or a class
		 * name of the image that is displayed in the image cell of the TileList.
		 *
         * @default null
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public var source:String;
		
		/* *
		 * Indicates whether the loaded content maintains the original 
		 * aspect ratio of the source or is resized to the dimensions of
		 * the TileList image cell. A value of <code>true</code> indicates
		 * that the original aspect ratio is to be maintained; a value of <code>false</code>
		 * indicates that the content is to be resized.
         *
         * @review is this even part of the API?
		 *
         * @default true
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 * /
		public var maintainAspectRatio:Boolean = true;
		*/
		
		/**
         * Creates a new TileListCollectionItem object.
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function TileListCollectionItem() {}	
		
		/**
         * @private
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function toString():String {
			return "[TileListCollectionItem: "+label+","+source+"]";	
		}
	}	
}