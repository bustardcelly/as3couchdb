package com.custardbelly.couchdb.example.event
{
	import com.custardbelly.couchdb.example.model.ContactDocument;
	
	import flash.events.Event;
	
	/**
	 * ContactEvent is an event object related to any proposed requests of service operation from a UI component. 
	 * @author toddanderson
	 */
	public class ContactEvent extends Event
	{
		public var contact:ContactDocument;
		public static const EDIT:String = "edit";
		public static const SAVE:String = "save";
		public static const DELETE:String = "delete";
		public static const CANCEL:String = "cancel";
		
		/**
		 * Constructor 
		 * @param type String The type of action being requested.
		 * @param contact ContactDocument The document used for service requests.
		 */
		public function ContactEvent( type:String, contact:ContactDocument )
		{
			super( type, true );
			this.contact = contact;
		}
		
		/**
		 * @inherit
		 */
		override public function clone():Event
		{
			return new ContactEvent( type, contact );
		}
	}
}