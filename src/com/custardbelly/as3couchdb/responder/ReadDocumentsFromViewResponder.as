package com.custardbelly.as3couchdb.responder
{
	import com.custardbelly.as3couchdb.core.CouchDocument;
	import com.custardbelly.as3couchdb.core.CouchServiceFault;
	import com.custardbelly.as3couchdb.core.CouchServiceResult;
	import com.custardbelly.as3couchdb.enum.CouchActionType;

	public class ReadDocumentsFromViewResponder extends ReadAllDocumentsResponder
	{
		public function ReadDocumentsFromViewResponder(documentClass:String, responder:ICouchServiceResponder)
		{
			super(documentClass, responder);
		}
		
		override public function handleResult( value:CouchServiceResult ):void
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
					// Documents are assume to be returned from map/reduce as ( key:id, value:doc ).
					document = _documentReader.createDocumentFromResult( _documentClass, documents[i].value );
					documentList.push( document );
				}
				
				if( _responder ) _responder.handleResult( new CouchServiceResult( CouchActionType.READ_DOCUMENTS, documentList ) );
			}
		}
	}
}