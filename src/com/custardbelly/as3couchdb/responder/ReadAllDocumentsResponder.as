/**
 * <p>Original Author: toddanderson</p>
 * <p>Class File: ReadAllDocumentsResponder.as</p>
 * <p>Version: 0.4.1</p>
 *
 * <p>Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:</p>
 *
 * <p>The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.</p>
 *
 * <p>THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.</p>
 *
 * <p>Licensed under The MIT License</p>
 * <p>Redistributions of files must retain the above copyright notice.</p>
 */
package com.custardbelly.as3couchdb.responder
{
	import com.custardbelly.as3couchdb.core.CouchDocument;
	import com.custardbelly.as3couchdb.core.CouchServiceFault;
	import com.custardbelly.as3couchdb.core.CouchServiceResult;
	import com.custardbelly.as3couchdb.enum.CouchActionType;
	import com.custardbelly.as3couchdb.serialize.CouchDatabaseReader;
	import com.custardbelly.as3couchdb.serialize.CouchDocumentReader;
	
	/**
	 * ReadAllDocumentsResponder is a service responder to read in the payload of all documents related to a database in the CouchDB instance. 
	 * @author toddanderson
	 */
	public class ReadAllDocumentsResponder implements ICouchServiceResponder
	{
		protected var _documentClass:String;
		protected var _responder:ICouchServiceResponder;
		protected var _status:int;
		
		protected var _databaseReader:CouchDatabaseReader;
		protected var _documentReader:CouchDocumentReader;
		
		/**
		 * Constructor. 
		 * @param documentClass String The fully-qualified class name of the document instance to resolve results to.
		 * @param responder ICouchServiceResponder
		 */
		public function ReadAllDocumentsResponder( documentClass:String, responder:ICouchServiceResponder )
		{
			_documentClass = documentClass;
			_responder = responder;
			
			_databaseReader = new CouchDatabaseReader();
			_documentReader = new CouchDocumentReader();
		}
		
		/**
		 * @private
		 * 
		 * Determines if successful result returned is related to an error. 
		 * @param value CouchServiceResult
		 * @return Boolean
		 */
		protected function handleResultAsError( value:CouchServiceResult ):Boolean
		{
			var result:Object = value.data;
			// If error, notify.
			if( _databaseReader.isResultAnError( result ) )
			{
				handleFault( new CouchServiceFault( result["error"], 0, result["reason"] ) );
				return true;
			}
			return false;
		}
		
		/**
		 * Responder method to handle the successful response form the request. 
		 * @param value CouchServiceResult
		 */
		public function handleResult( value:CouchServiceResult ):void
		{
			var result:Object = value.data;
			// If error, notify.
			if( !handleResultAsError( value ) )
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
		
		/**
		 * Responder method to handle a fault in the service request. 
		 * @param value CouchServiceFault
		 */
		public function handleFault( value:CouchServiceFault ):void
		{
			if( _responder ) _responder.handleFault( value );
		}
		
		/**
		 * Accessor/Modifier of the current HTTP status code of the request. 
		 * @return 
		 * 
		 */
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