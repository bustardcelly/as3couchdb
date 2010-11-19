package com.custardbelly.couchdb.example.model
{
	import com.custardbelly.as3couchdb.core.CouchModelEntity;
	import com.custardbelly.as3couchdb.core.CouchUser;
	
	[DocumentService(url="http://127.0.0.1:5984", name="contacts")]
	[ServiceMediator(name="com.custardbelly.as3couchdb.mediator.CouchUserActionMediator")]
	[RequestType(name="com.custardbelly.as3couchdb.service.HTTPCouchRequest")]
	
	public class ContactUser extends CouchUser
	{
		public function ContactUser(name:String, password:String, entity:CouchModelEntity=null)
		{
			super(name, password, entity);
		}
	}
}