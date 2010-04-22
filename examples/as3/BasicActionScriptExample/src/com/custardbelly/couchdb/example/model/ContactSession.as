package com.custardbelly.couchdb.example.model
{
	import com.custardbelly.as3couchdb.core.CouchSession;
	
	[DocumentService(url="http://127.0.0.1:5984", name="contacts")]
	[ServiceMediator(name="com.custardbelly.as3couchdb.mediator.CouchSessionActionMediator")]
	[RequestType(name="com.custardbelly.as3couchdb.service.HTTPSessionRequest")]
	
	/**
	 * ContactSession is an extension of CouchSession to properly annotate the metadata associated with a session within CouchDB. 
	 * @author toddanderson
	 */
	public class ContactSession extends CouchSession
	{
		/**
		 * Constructor.
		 */
		public function ContactSession()
		{
			super();
		}
	}
}