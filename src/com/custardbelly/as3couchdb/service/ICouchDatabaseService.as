/**
 * <p>Original Author: toddanderson</p>
 * <p>Class File: ICouchDatabaseService.as</p>
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
package com.custardbelly.as3couchdb.service
{
	import com.custardbelly.as3couchdb.command.IRequestCommand;
	import com.custardbelly.as3couchdb.responder.ICouchServiceResponder;
	
	import flash.net.URLRequest;

	/**
	 * ICouchDatabaseService is an interface for communication with a CouchDB instance. 
	 * @author toddanderson
	 */
	public interface ICouchDatabaseService extends ICouchService
	{
		/**
		 * Creates a new database in the CouchDB instance. 
		 * @param databaseName String
		 * @param responder ICouchServiceResponder
		 * @return IRequestCommand
		 */
		function createDatabase( databaseName:String, responder:ICouchServiceResponder = null ):IRequestCommand;
		/**
		 * Reads in a database from the CouchDB instance. 
		 * @param databaseName String
		 * @param responder ICouchServiceResponder
		 * @return IRequestCommand
		 */
		function readDatabase( databaseName:String, responder:ICouchServiceResponder = null ):IRequestCommand
		/**
		 * Deletes a databse from the CouchDB instance. 
		 * @param databaseName String
		 * @param responder ICouchServiceResponder
		 * @return IRequestCommand
		 */
		function deleteDatabase( databaseName:String, responder:ICouchServiceResponder = null ):IRequestCommand
		
		// Replication.
		/**
		 * Pushes a database from the current target CouchDB instance to another target. 
		 * @param databaseName String
		 * @param target String
		 * @param responder ICouchServiceResponder
		 * @return IRequestCommand
		 */
		function pushDatabase( databaseName:String, target:String, responder:ICouchServiceResponder = null ):IRequestCommand
		/**
		 * Pulls a database from a target CouchDB instance to the current target. 
		 * @param target String
		 * @param databaseName String
		 * @param responder ICouchServiceResponder
		 * @return IRequestCommand
		 */
		function pullDatabase( target:String, databaseName:String, responder:ICouchServiceResponder = null ):IRequestCommand
		
		/**
		 * Requests information related to a database. 
		 * @param databaseName String
		 * @param responder ICouchServiceResponder
		 * @return IRequestCommand
		 */
		function getDatabaseInfo( databaseName:String, responder:ICouchServiceResponder = null ):IRequestCommand
		/**
		 * Requests change information related to a database. 
		 * @param databaseName String
		 * @param responder ICouchServiceResponder
		 * @return IRequestCommand
		 */
		function getDatabaseChanges( databaseName:String, responder:ICouchServiceResponder = null ):IRequestCommand
		/**
		 * Compacts and performs optional cleanup of a database. 
		 * @param databaseName String
		 * @param cleanup Boolean
		 * @param responder ICouchServiceResponder
		 * @return IRequestCommand
		 */
		function compactDatabase( databaseName:String, cleanup:Boolean = false, responder:ICouchServiceResponder = null ):IRequestCommand
		/**
		 * Request all documents related to a database. 
		 * @param databaseName String
		 * @param responder ICouchServiceResponder
		 * @return IRequestCommand
		 */
		function getAllDocuments( databaseName:String, includeDocs:Boolean = false, responder:ICouchServiceResponder = null ):IRequestCommand
		/**
		 * Request all documents in modification sequence related to a database. 
		 * @param databaseName String
		 * @param responder ICouchServiceResponder
		 * @return IRequestCommand
		 */
		function getAllDocumentsBySequence( databaseName:String, includeDocs:Boolean = false, responder:ICouchServiceResponder = null ):IRequestCommand
		/**
		 * Makes request on design document in CouchDB instance. 
		 * @param id String
		 * @param responder ICouchServiceResponder
		 * @return IRequestCommand
		 */
		function getDocumentsFromView( databaseName:String, documentName:String, viewName:String, byKeyValue:String = null, responder:ICouchServiceResponder = null ):IRequestCommand
		/**
		 * Requests the list of databases in the target CouchDB instance. 
		 * @param responder ICouchServiceResponder
		 * @return IRequestCommand
		 */
		function list( responder:ICouchServiceResponder = null ):IRequestCommand
		/**
		 * Requests a list of unique ids from the target CouchDB instance. 
		 * @param amount int
		 * @param responder ICouchServiceResponder
		 * @return IRequestCommand
		 */
		function getUUIDs( amount:int = 1, responder:ICouchServiceResponder = null ):IRequestCommand
	}
}