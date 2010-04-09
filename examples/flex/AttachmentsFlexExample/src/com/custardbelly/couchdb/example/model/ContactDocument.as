package com.custardbelly.couchdb.example.model
{
	import com.custardbelly.as3couchdb.core.CouchDocument;
	
	[DocumentService(url="http://127.0.0.1:5984", name="contacts")]
	[ServiceMediator(name="com.custardbelly.as3couchdb.mediator.CouchDocumentActionMediator")]
	[RequestType(name="com.custardbelly.as3couchdb.service.HTTPCouchRequest")]
	
	/**
	 * ContactDocument is an extension of CouchDocument to properly annotate the metadata associated with the document model. 
	 * @author toddanderson
	 */
	public class ContactDocument extends CouchDocument
	{
		/* Assign specific properties that relate to documents within the target database of CouchDB
		*  Properties that are created by CouchDB, such as _id and _rev, do not need to be listed in 
		*	this subclass. They are handled by as3couchdb library and can be found on CouchDocument.
		*/
		public var firstName:String;
		public var lastName:String;
		public var email:String;
		
		/**
		 * Constructor.
		 */
		public function ContactDocument()
		{
			super();
		}
	}
}