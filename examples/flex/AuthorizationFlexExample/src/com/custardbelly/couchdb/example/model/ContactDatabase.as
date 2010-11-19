package com.custardbelly.couchdb.example.model
{
	import com.custardbelly.as3couchdb.core.CouchDatabase;
	import com.custardbelly.as3couchdb.core.CouchModelEntity;

	[DocumentService(url="http://127.0.0.1:5984", name="contacts")]
	[ServiceMediator(name="com.custardbelly.as3couchdb.mediator.CouchDatabaseActionMediator")]
	[RequestType(name="com.custardbelly.as3couchdb.service.HTTPCouchRequest")]
	
	/**
	 * ContactDatabase is an extension of CouchDatabase to properly annotate the metadata associated with the database model. 
	 * @author toddanderson
	 */
	public class ContactDatabase extends CouchDatabase
	{
		/**
		 * Constructor.
		 */
		public function ContactDatabase( entity:CouchModelEntity = null )
		{
			super( entity );
		}
	}
}