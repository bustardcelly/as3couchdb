package com.custardbelly.as3couchdb.responder
{
	import com.custardbelly.as3couchdb.core.CouchDocument;
	import com.custardbelly.as3couchdb.core.CouchServiceFault;
	import com.custardbelly.as3couchdb.core.CouchServiceResult;
	import com.custardbelly.as3couchdb.enum.CouchActionType;
	import com.custardbelly.as3couchdb.serialize.CouchDatabaseReader;
	import com.custardbelly.as3couchdb.serialize.CouchDocumentReader;
	
	public class ReadAllDocumentsResponder implements ICouchServiceResponder
	{
		protected var _documentClass:String;
		protected var _responder:ICouchServiceResponder;
		protected var _status:int;
		
		protected var _databaseReader:CouchDatabaseReader;
		protected var _documentReader:CouchDocumentReader;
		
		public function ReadAllDocumentsResponder( documentClass:String, responder:ICouchServiceResponder )
		{
			_documentClass = documentClass;
			_responder = responder;
			
			_databaseReader = new CouchDatabaseReader();
			_documentReader = new CouchDocumentReader();
		}
		
		public function handleResult( value:CouchServiceResult ):void
		{
			var result:Object = value.data;
			if( _databaseReader.isResultAnError( result ) )
			{
				handleFault( new CouchServiceFault( result["error"], result["reason"] ) );
			}
			else
			{
				var documents:Array = _databaseReader.getDocumentListFromResult( result );
				
				var i:int;
				var document:CouchDocument;
				var documentList:Array = [];
				for( i = 0; i < documents.length; i++ )
				{
					// Documents are returned from /_all_docs as {doc:Object, id:String, key:String, value:Object}
					// Supply the doc property to the reader.
					document = _documentReader.createDocumentFromResult( _documentClass, documents[i].doc );
					documentList.push( document );
				}
				
				if( _responder ) _responder.handleResult( new CouchServiceResult( CouchActionType.READ_DOCUMENTS, documentList ) );
			}
		}
		
		public function handleFault( value:CouchServiceFault ):void
		{
			if( _responder ) _responder.handleFault( value );
		}
		
		public function get status():int
		{
			return _status;
		}
		
		public function set status(value:int):void
		{
			_status = value;
		}
	}
}