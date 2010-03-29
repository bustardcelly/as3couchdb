/**
 * <p>Original Author: toddanderson</p>
 * <p>Class File: CouchDatabaseService.as</p>
 * <p>Version: 0.3</p>
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
// TODO: Support for upload of design documents.
// TODO: Support for upload of attachements.
package com.custardbelly.as3couchdb.service
{
	import com.custardbelly.as3couchdb.enum.CouchContentType;
	import com.custardbelly.as3couchdb.enum.CouchRequestMethod;
	import com.custardbelly.as3couchdb.responder.ICouchServiceResponder;
	import com.custardbelly.as3couchdb.serialize.CouchDatabaseWriter;
	import com.custardbelly.as3couchdb.serialize.ICouchDatabaseWriter;
	
	import flash.net.URLRequest;
	import flash.utils.Dictionary;
	
	/**
	 * CouchDatabaseService is an ICouchDatabaseService implementation that communicates with a CouchDB instance to perform any actions related to a database. 
	 * @author toddanderson
	 */
	public class CouchDatabaseService extends CouchService implements ICouchDatabaseService
	{
		protected var _writer:ICouchDatabaseWriter;
		/**
		 * @private
		 * 
		 * Holds a map of instances from which you can gain access based on base url of CouchDB instance. 
		 */
		protected static var instances:Dictionary = new Dictionary(true);
		
		/**
		 * Constructor. 
		 * @param baseUrl String The base url of the CouchDB instance.
		 */
		public function CouchDatabaseService( baseUrl:String, request:ICouchRequest = null )
		{
			super( baseUrl, request );
			_writer = new CouchDatabaseWriter();
		}
		
		/**
		 * @private
		 * 
		 * Validates and returns a string in lowercase (valid database format for CouchDB). 
		 * @param name String
		 * @return String
		 */
		protected function validateDatabaseName( name:String ):String
		{
			return escape( name ).toLowerCase();
		}
		
		/**
		 * Creates a new database using the supplied database name. 
		 * @param databaseName String The name of the database to create.
		 * @param responder ICouchServiceResponder Optional service responder.
		 */
		public function createDatabase( databaseName:String, responder:ICouchServiceResponder = null ):void
		{
			var request:URLRequest = new URLRequest();
			request.contentType = CouchContentType.JSON;
			request.url = _baseUrl + "/" + validateDatabaseName( databaseName );
			
			makeRequest( request, CouchRequestMethod.PUT, responder );
		}
		
		/**
		 * Reads in a database from the CouchDB instance. 
		 * @param databaseName String The name of the database to read in.
		 * @param responder ICouchServiceResponder Option service responder.
		 */
		public function readDatabase( databaseName:String, responder:ICouchServiceResponder = null ):void
		{
			var request:URLRequest = new URLRequest();
			request.contentType = CouchContentType.JSON;
			request.url = _baseUrl + "/" + databaseName;
			
			makeRequest( request, CouchRequestMethod.GET, responder );
		}
		
		/**
		 * Deletes a database form the CouchDB instance. 
		 * @param databaseName String The name of the database to delete.
		 * @param responder ICouchServiceResponder Option service responder.
		 */
		public function deleteDatabase( databaseName:String, responder:ICouchServiceResponder = null ):void
		{
			var request:URLRequest = new URLRequest();
			request.contentType = CouchContentType.JSON;
			request.url = _baseUrl + "/" + databaseName;
			
			// 200, 404
			makeRequest( request, CouchRequestMethod.DELETE, responder );
		}
		
		/**
		 * Pushes a databse from one CouchDB instance to another. 
		 * @param databaseName String The database to push.
		 * @param target String The target CouchDB url to push the database to.
		 * @param responder ICouchServiceResponder Option service responder.
		 */
		public function pushDatabase( databaseName:String, target:String, responder:ICouchServiceResponder = null ):void
		{
			var data:Object = {source: _baseUrl + "/" + databaseName, target: target + "/" + databaseName};
			
			var request:URLRequest = new URLRequest();
			request.contentType = CouchContentType.JSON;
			request.data = _writer.serialize( data );
			request.url = _baseUrl + "/_replicate";
			
			makeRequest( request, CouchRequestMethod.POST, responder );
		}
		
		/**
		 * Pulls the database from a target CouchDB instance to another. 
		 * @param target String The target database to pull from.
		 * @param databaseName String The database name to pull.
		 * @param responder ICouchServiceResponder Option service responder.
		 */
		public function pullDatabase( target:String, databaseName:String, responder:ICouchServiceResponder = null ):void
		{
			var data:Object = {source: target + "/" + databaseName, target: _baseUrl + "/" + databaseName};
			var request:URLRequest = new URLRequest();
			request.contentType = CouchContentType.JSON;
			request.data = _writer.serialize( data );
			request.url = _baseUrl + "/_replicate";
			
			makeRequest( request, CouchRequestMethod.POST, responder );
		}
		
		/**
		 * Request information related to a database. 
		 * @param databaseName String The target database.
		 * @param responder ICouchServiceResponder Option service responder.
		 */
		public function getDatabaseInfo( databaseName:String, responder:ICouchServiceResponder = null ):void
		{
			var request:URLRequest = new URLRequest();
			request.contentType = CouchContentType.JSON;
			request.url = _baseUrl + "/" + databaseName;
			
			makeRequest( request, CouchRequestMethod.GET, responder );
		}
		
		/**
		 * Request changes related to a database. 
		 * @param databaseName String The target database.
		 * @param responder ICouchServiceResponder Option service responder.
		 */
		public function getDatabaseChanges( databaseName:String, responder:ICouchServiceResponder = null ):void
		{
			var request:URLRequest = new URLRequest();
			request.contentType = CouchContentType.JSON;
			request.url = _baseUrl + "/" + databaseName + "/_changes";
			
			makeRequest( request, CouchRequestMethod.GET, responder );
		}
		
		/**
		 * Compacts database and performs optional cleanup. 
		 * @param databaseName String The target database.
		 * @param cleanup Boolean Optional cleanup.
		 * @param responder ICouchServiceResponder Option service responder.
		 */
		public function compactDatabase( databaseName:String, cleanup:Boolean = false, responder:ICouchServiceResponder = null ):void
		{
			var request:URLRequest = new URLRequest();
			request.contentType = CouchContentType.JSON;
			request.url = _baseUrl + "/" + databaseName + "/_compact";
			request.url += ( cleanup ) ? "/" + "_view_cleanup" : "";
			
			makeRequest( request, CouchRequestMethod.POST, responder );
		}
		
		/**
		 * Returns all documents associated with a database in a CouchDB instance. 
		 * @param databaseName String The target database.
		 * @param responder ICouchServiceResponder Option service responder.
		 */
		public function getAllDocuments( databaseName:String, includeDocs:Boolean = false, responder:ICouchServiceResponder = null ):void
		{
			var request:URLRequest = new URLRequest();
			request.contentType = CouchContentType.JSON;
			request.url = _baseUrl + "/" + databaseName + "/_all_docs";
			if( includeDocs ) request.url += "?include_docs=true";
			
			makeRequest( request, CouchRequestMethod.GET, responder );
		}
		
		/**
		 * Returns all the document associated with a database by sequence in a CouchDB instance. 
		 * @param databaseName String The target database.
		 * @param responder ICouchServiceResponder Option service responder.
		 */
		public function getAllDocumentsBySequence( databaseName:String, includeDocs:Boolean = false, responder:ICouchServiceResponder = null ):void
		{
			var request:URLRequest = new URLRequest();
			request.contentType = CouchContentType.JSON;
			request.url = _baseUrl + "/" + databaseName + "/_all_docs_by_seq";
			if( includeDocs ) request.url += "?include_docs=true";
			
			makeRequest( request, CouchRequestMethod.GET, responder );
		}
		
		/**
		 * Requests a list of unique ids from the CouchDB instance. 
		 * @param amount int The number of unique ids to request.
		 * @param responder ICouchServiceResponder Option service responder.
		 */
		public function getUUIDs( amount:int = 1, responder:ICouchServiceResponder = null ):void
		{
			var request:URLRequest = new URLRequest();
			request.contentType = CouchContentType.JSON;
			request.url = _baseUrl + "/_uuids?count=" + amount;
			
			makeRequest( request, CouchRequestMethod.GET, responder ); 
		}
		
		/**
		 * Lists the databases available on the CouchDB instance. 
		 * @param responder ICouchServiceResponder Option service responder.
		 */
		public function list( responder:ICouchServiceResponder = null ):void
		{
			var request:URLRequest = new URLRequest();
			request.contentType = CouchContentType.JSON;
			request.url = _baseUrl + "/_all_dbs";
			
			makeRequest( request, CouchRequestMethod.GET, responder );
		}
		
		/**
		 * Makes request on design document in CouchDB instance. 
		 * @param id String
		 * @param responder ICouchServiceResponder
		 */
		public function getDocumentsFromView( databaseName:String, documentName:String, viewName:String, byKeyValue:String = null, responder:ICouchServiceResponder = null ):void
		{
			var request:URLRequest = new URLRequest();
			request.contentType = CouchContentType.JSON;
			request.url = _baseUrl + "/" + databaseName + "/_design/" + documentName + "/_view/" + viewName;
			if( byKeyValue ) request.url += "?key=\"" + byKeyValue + "\"";
			
			makeRequest( request, CouchRequestMethod.GET, responder );
		}
		
		/**
		 * Access an instance of a ICouchDatabaseService based on the url of the CouchDb instance. 
		 * @param baseUrl String
		 * @return ICouchDatabaseService
		 */
		public static function getDatabaseService( baseUrl:String, request:ICouchRequest = null ):ICouchDatabaseService
		{
			if( CouchDatabaseService.instances[baseUrl] == null )
			{
				CouchDatabaseService.instances[baseUrl] = new CouchDatabaseService( baseUrl, request );
			}
			return CouchDatabaseService.instances[baseUrl];
		}
	}
}