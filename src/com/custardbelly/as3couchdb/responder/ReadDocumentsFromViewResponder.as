/**
 * <p>Original Author: toddanderson</p>
 * <p>Class File: ReadDocumentsFromViewResponder.as</p>
 * <p>Version: 0.7</p>
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
	import com.custardbelly.as3couchdb.core.CouchModelEntity;
	import com.custardbelly.as3couchdb.core.CouchServiceFault;
	import com.custardbelly.as3couchdb.core.CouchServiceResult;
	import com.custardbelly.as3couchdb.enum.CouchActionType;

	/**
	 * ReadDocumentsFromViewResponder is a responder to a request make on a view document in the database of the CouchDB instance. 
	 * @author toddanderson
	 */
	public class ReadDocumentsFromViewResponder extends ReadAllDocumentsResponder
	{
		protected var _documentClass:String;
		protected var _documentEntity:CouchModelEntity;
		
		/**
		 * Constructor. 
		 * @param responder ICouchServiceResponder
		 * @param documentClass String The fully-qualified classname of the document to resolve results to.
		 * @param documentEntity CouchDocumentEntity The optional entity to supply to the resolved document.
		 */
		public function ReadDocumentsFromViewResponder( responder:ICouchServiceResponder, documentClass:String, documentEntity:CouchModelEntity = null )
		{
			super(responder);
			_documentClass = documentClass;
			_documentEntity = documentEntity;
		}
		
		/**
		 * @inherit
		 */
		override public function handleResult( value:CouchServiceResult ):void
		{
			var result:Object = value.data;
			if( !handleResultAsError( value ) )
			{
				var documents:Array = _databaseReader.getDocumentListFromResult( result );
				
				var i:int;
				var document:CouchDocument;
				var documentList:Array = [];
				for( i = 0; i < documents.length; i++ )
				{
					// Documents are assume to be returned from map/reduce as ( key:id, value:doc ).
					document = _documentReader.createDocumentFromResult( documents[i].value, _documentClass, _documentEntity );
					documentList.push( document );
				}
				
				if( _responder ) _responder.handleResult( new CouchServiceResult( CouchActionType.READ_DOCUMENTS, documentList ) );
			}
		}
	}
}