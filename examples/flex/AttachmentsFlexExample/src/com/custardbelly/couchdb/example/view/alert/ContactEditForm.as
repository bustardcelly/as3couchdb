package com.custardbelly.couchdb.example.view.alert
{
	import com.custardbelly.as3couchdb.core.CouchAttachment;
	import com.custardbelly.as3couchdb.enum.CouchContentType;
	import com.custardbelly.couchdb.example.event.ContactEvent;
	import com.custardbelly.couchdb.example.model.ContactDocument;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	
	import mx.graphics.codec.JPEGEncoder;
	import mx.graphics.codec.PNGEncoder;
	
	import spark.components.Button;
	import spark.components.Panel;
	import spark.components.TextInput;
	import spark.components.supportClasses.SkinnableComponent;
	import spark.primitives.BitmapImage;
	
	[Event(name="save", type="com.custardbelly.couchdb.example.event.ContactEvent")]
	[Event(name="cancel", type="com.custardbelly.couchdb.example.event.ContactEvent")]
	
	[DefaultProperty("contact")]
	
	/**
	 * ContactEditForm is a view controller for a user form to submit an update or creation of a ContactDocument. 
	 * @author toddanderson
	 */
	public class ContactEditForm extends SkinnableComponent
	{
		[SkinPart(required="true")]
		public var userImage:BitmapImage;
		
		[SkinPart(required="true")]
		public var fileField:TextInput;
		
		[SkinPart(required="true")]
		public var attachButton:Button;
		
		[SkinPart(required="true")]
		public var firstNameField:TextInput;
		
		[SkinPart(required="true")]
		public var lastNameField:TextInput;
		
		[SkinPart(required="true")]
		public var emailField:TextInput;
		
		[SkinPart(required="true")]
		public var saveButton:Button;
		
		[SkinPart(required="false")]
		public var cancelButton:Button;
		
		protected var _contact:ContactDocument;
		
		[Embed(source='images/no_icon.png')]
		protected var defaultUserImage:Class;
		protected var _defaultUserImage:Bitmap;
		
		/**
		 * Constructor.
		 */
		public function ContactEditForm()
		{
			super();
			_defaultUserImage = new defaultUserImage() as Bitmap;
		}
		
		/**
		 * @inherit
		 */
		override protected function commitProperties():void
		{
			super.commitProperties();
			if( firstNameField )
				firstNameField.text = _contact.firstName;
			if( lastNameField )
				lastNameField.text = _contact.lastName;
			if( emailField )
				emailField.text = _contact.email;
			if( userImage )
				updateUserImage();
		}
		
		/**
		 * @inherit
		 */
		override protected function partAdded( partName:String, instance:Object ):void
		{
			super.partAdded( partName, instance );
			if( instance == saveButton )
			{
				saveButton.addEventListener( MouseEvent.CLICK, handleSaveClick, false, 0, true );
			}
			else if( instance == cancelButton )
			{
				cancelButton.addEventListener( MouseEvent.CLICK, handleCancelClick, false, 0, true );
			}
			else if( instance == attachButton )
			{
				attachButton.addEventListener( MouseEvent.CLICK, handleAttachClick, false, 0, true );
			}
		}
		
		/**
		 * @inherit
		 */
		override protected function partRemoved( partName:String, instance:Object ):void
		{
			super.partRemoved( partName, instance );
			
			if( instance == saveButton )
			{
				saveButton.removeEventListener( MouseEvent.CLICK, handleSaveClick, false );
			}
			else if( instance == cancelButton )
			{
				cancelButton.removeEventListener( MouseEvent.CLICK, handleCancelClick, false );
			}
				
			else if( instance == attachButton )
			{
				attachButton.removeEventListener( MouseEvent.CLICK, handleAttachClick, false );
			}
		}
		
		/**
		 * @private
		 * 
		 * Locates and returns attachment associated with icon if available form the contcat document. 
		 * @return CouchAttachment
		 */
		protected function findIconAttachment():CouchAttachment
		{	
			var attachment:CouchAttachment;
			for each( attachment in _contact.attachments )
			{
				if( attachment.contentType == CouchContentType.JPEG ||
					attachment.contentType == CouchContentType.PNG )
				{
					return attachment;
				}
			}
			return null;
		}
		
		/**
		 * @private 
		 * 
		 * Updates the user defined image in the icon display.
		 */
		protected function updateUserImage():void
		{
			if( _contact.attachments != null )
			{
				var attachment:CouchAttachment = findIconAttachment();
				if( attachment )
				{
					var loader:Loader = new Loader();
					loader.contentLoaderInfo.addEventListener(Event.COMPLETE, handleUserImageLoadComplete);
					loader.load( new URLRequest( attachment.url ) );
				}
				else
				{
					userImage.source = _defaultUserImage;
					fileField.text = "";
				}
			}
		}
		
		/**
		 * @private
		 * 
		 * Loads and replaces old icon. 
		 * @param attachment CouchAttachment
		 * @param url String
		 */
		protected function replaceOldIcon( attachment:CouchAttachment, url:String ):void
		{
			var loader:IconLoader = new IconLoader( attachment, url );
			loader.addEventListener( IconLoaderEvent.COMPLETE, handleIconLoad );
			loader.load();
		}
		
		/**
		 * Event handler for load of new icon. 
		 * @param evt IconLoaderEvent
		 */
		protected function handleIconLoad( evt:IconLoaderEvent ):void
		{
			var loader:IconLoader = evt.target as IconLoader;
			loader.removeEventListener( IconLoaderEvent.COMPLETE, handleIconLoad );
			
			var bitmap:Bitmap = evt.image;
			// Update attachments.
			var attachment:CouchAttachment = evt.attachment;
			var savedAttachment:CouchAttachment = findIconAttachment();
			if( savedAttachment == null )
			{
				if( _contact.attachments == null )
					_contact.attachments = new Vector.<CouchAttachment>();
				
				_contact.attachments.push( attachment );
			}
			// Set image in icon placeholder.
			userImage.source = bitmap;
		}
		
		protected function handleUserImageLoadComplete( evt:Event ):void
		{
			var info:LoaderInfo = ( evt.target as LoaderInfo );
			info.removeEventListener( Event.COMPLETE, handleUserImageLoadComplete );
			userImage.source = info.content as Bitmap;
		}
		
		/**
		 * @private
		 * 
		 * Event handler for click on attach icon image. 
		 * @param evt MouseEvent
		 */
		protected function handleAttachClick( evt:MouseEvent ):void
		{
			// no attach if blank.
			if( fileField.text == "" ) return;
			
			var attachment:CouchAttachment = findIconAttachment();
			// If new icon, laod new.
			if( attachment == null )
			{
				replaceOldIcon( new CouchAttachment(), fileField.text );
			}
			// If replacing icon, replace.
			else
			{
				replaceOldIcon( attachment, fileField.text );
			}
		}
		
		/**
		 * @private
		 * 
		 * Event handler for confirmation of save to ContactDocument. 
		 * @param evt MouseEvent
		 */
		protected function handleSaveClick( evt:MouseEvent ):void
		{
			_contact.firstName = firstNameField.text;
			_contact.lastName = lastNameField.text;
			_contact.email = emailField.text;
			dispatchEvent( new ContactEvent( ContactEvent.SAVE, _contact ) );
		}
		
		/**
		 * @private
		 * 
		 * Event handler for cancel of save for ContactDocument. 
		 * @param evt MouseEvent
		 */
		protected function handleCancelClick( evt:MouseEvent ):void
		{
			dispatchEvent( new ContactEvent( ContactEvent.CANCEL, _contact ) );
		}
		
		[Bindable]
		/**
		 * Accessor/Modifier for the ContactDocument in question to be saved. 
		 * @return ContactDocument
		 */
		public function get contact():ContactDocument
		{
			return _contact;
		}
		public function set contact( value:ContactDocument ):void
		{
			_contact = value;
		}
	}
}
import com.custardbelly.as3couchdb.core.CouchAttachment;

import flash.display.Bitmap;
import flash.display.Loader;
import flash.display.LoaderInfo;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.net.URLRequest;
import flash.utils.ByteArray;

import mx.graphics.codec.JPEGEncoder;
import mx.graphics.codec.PNGEncoder;

class IconLoader extends EventDispatcher
{
	protected var _attachment:CouchAttachment;
	protected var _url:String;
	protected var _extension:String;
	
	public function IconLoader( attachment:CouchAttachment, url:String )
	{
		_attachment = attachment;
		_url = url;
		
		var fileName:String = url.substring( url.lastIndexOf( "/" ) + 1, url.length );
		var extensionExp:RegExp = /\.([^\.]+)$/;
		_extension = url.match( extensionExp )[0].toString().toLowerCase();
		_extension = _extension.substring( 1, _extension.length );
		_attachment.fileName = fileName;
		_attachment.contentType = "image/" + _extension;
		_attachment.url = url;
	}
	
	protected function handleLoadComplete( evt:Event ):void
	{
		var loaderInfo:LoaderInfo = evt.target as LoaderInfo;
		loaderInfo.removeEventListener(Event.COMPLETE, handleLoadComplete);
		
		var bitmap:Bitmap = loaderInfo.content as Bitmap;
		var data:ByteArray;
		if( _extension == "jpeg" || _extension == "jpg" )
			data = new JPEGEncoder().encode( bitmap.bitmapData );
		else if( _extension == "png" )
			data = new PNGEncoder().encode( bitmap.bitmapData );
		
		data.position = 0;
		_attachment.data = data;
		dispatchEvent( new IconLoaderEvent( IconLoaderEvent.COMPLETE, _attachment, bitmap ) );
	}
	
	public function load():void
	{
		var loader:Loader = new Loader();
		loader.contentLoaderInfo.addEventListener(Event.COMPLETE, handleLoadComplete);
		loader.load( new URLRequest( _url ) );
	}
}
class IconLoaderEvent extends Event
{
	public var attachment:CouchAttachment;
	public var image:Bitmap;
	public static const COMPLETE:String = "complete";
	public function IconLoaderEvent( type:String, attachment:CouchAttachment, image:Bitmap )
	{
		super( type );
		this.attachment = attachment;
		this.image = image;
	}
}