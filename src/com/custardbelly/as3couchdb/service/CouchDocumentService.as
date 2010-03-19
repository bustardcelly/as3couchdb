/**
 * <p>Original Author: toddanderson</p>
 * <p>Class File: CouchDocumentService.as</p>
 * <p>Version: 0.2</p>
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
package com.custardbelly.as3couchdb.service
{
	import com.adobe.serialization.json.JSON;
	import com.custardbelly.as3couchdb.core.CouchDocument;
	import com.custardbelly.as3couchdb.enum.CouchContentType;
	import com.custardbelly.as3couchdb.enum.CouchRequestMethod;
	import com.custardbelly.as3couchdb.event.CouchEvent;
	import com.custardbelly.as3couchdb.responder.CreateDocumentResponder;
	import com.custardbelly.as3couchdb.responder.DeleteDocumentResponder;
	import com.custardbelly.as3couchdb.responder.ICouchServiceResponder;
	import com.custardbelly.as3couchdb.responder.UpdateDocumentResponder;
	import com.custardbelly.as3couchdb.serialize.CouchDocumentWriter;
	import com.custardbelly.as3couchdb.util.UUID;
	
	import flash.net.URLRequest;
	import flash.utils.Dictionary;

	/**
	 * CouchDocumentService is an ICouchDocumentService implementation that  communicates with a CouchDB instance to perform any actions related to a document.
	 * @author toddanderson
	 * 
	 */
	public class CouchDocumentService extends CouchService implements ICouchDocumentService
	{
		/**
		 * @private
		 * 
		 * The target database name to perform document operations on. 
		 */
		protected var _databaseName:String;
		/**
		 * @private
		 * 
		 * The document writer that knows how to interpret a target document as a JSON object passed in service operations. 
		 */
		protected var _writer:CouchDocumentWriter;
		
		/**
		 * @private
		 * 
		 * Holds a map of instances from which you can gain access based on base url of CouchDB instance. 
		 */
		protected static var instances:Dictionary = new Dictionary(true);
		
		/**
		 * Constructor. 
		 * @param baseUrl String The base url of the CouchDB instance
		 * @param databaseName String The database targeted.
		 */
		public function CouchDocumentService( baseUrl:String, databaseName:String, request:ICouchRequest = null )
		{
			super( baseUrl, request );
			_databaseName = databaseName;
			_writer = new CouchDocumentWriter();
		}
		
		/**
		 * Reads a document from the CouchDB instance. 
		 * @param documentId String The unique id of the document.
		 * @param responder ICouchServiceResponder Optional service responder.
		 * 
		 */
		public function readDocument( documentId:String, responder:ICouchServiceResponder = null ):void
		{
			var request:URLRequest = new URLRequest();
			request.contentType = CouchContentType.JSON;
			request.url = _baseUrl + "/" + _databaseName + "/" + documentId;
			
			makeRequest( request, CouchRequestMethod.GET, responder );
		}
		
		/**
		 * Creates a document in the database. 
		 * @param documentId String The unique id of the document.
		 * @param responder ICouchServiceResponder Optional service responder.
		 */
		public function createDocument( documentId:String, responder:ICouchServiceResponder = null ):void
		{
			var request:URLRequest = new URLRequest();
			request.contentType = CouchContentType.JSON;
			request.url = _baseUrl + "/" + _databaseName + "/" + documentId;
			
			makeRequest( request, CouchRequestMethod.PUT, responder );
		}
		
		/**
		 * Saves the document to the database of the CouchDB instance. 
		 * @param document CouchDocument
		 * @param responder ICouchServiceResponder Optional service responder.
		 */
		public function saveDocument( document:CouchDocument, responder:ICouchServiceResponder = null ):void
		{
			// Determine if document exists based on the availablility of an id.
			var id:String;
			var data:String; 
			var isPreviouslySaved:Boolean = ( document.id != null );
			if( isPreviouslySaved )
			{
				// If previously saved document, request to update properties of document.
				id = document.id;
				data = _writer.serializeDocumentForUpdate( document );
			}
			else
			{
				// If new document, request to create the document.
				id = UUID.generate( _baseUrl );
				data = _writer.serializeDocumentForCreation( document );
			}
			
			var request:URLRequest = new URLRequest();
			request.contentType = CouchContentType.JSON;
			request.data = data;
			request.url = _baseUrl + "/" + _databaseName + "/" + id;
			
			makeRequest( request, CouchRequestMethod.PUT, responder );
		}
		
		/**
		 * Deletes the document from the database of the CouchDB instance. 
		 * @param documentId String The unique id of the document.
		 * @param documentRevision The required revision of the document needed to perform delete operations.
		 * @param responder ICouchServiceResponder Optional service responder.
		 */
		public function deleteDocument( documentId:String, documentRevision:String, responder:ICouchServiceResponder = null ):void
		{
			var request:URLRequest = new URLRequest();
			request.contentType = CouchContentType.JSON;
			request.url = _baseUrl + "/" + _databaseName + "/" + documentId + "?rev=" + documentRevision;
			
			makeRequest( request, CouchRequestMethod.DELETE, responder );
		}
		
		/**
		 * Access an instance of a ICouchDocumentService based on the url and database held in the CouchDb instance. 
		 * @param baseUrl String
		 * @return ICouchDocumentService
		 */
		public static function getDocumentService( baseUrl:String, databaseName:String, request:ICouchRequest = null ):ICouchDocumentService
		{
			if( CouchDocumentService.instances[baseUrl + "/" + databaseName] == null )
			{
				CouchDocumentService.instances[baseUrl + "/" + databaseName] = new CouchDocumentService( baseUrl, databaseName, request );
			}
			return CouchDocumentService.instances[baseUrl + "/" + databaseName];
		}
	}
}