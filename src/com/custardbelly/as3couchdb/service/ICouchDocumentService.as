/**
 * <p>Original Author: toddanderson</p>
 * <p>Class File: ICouchDocumentService.as</p>
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
	import com.custardbelly.as3couchdb.core.CouchDocument;
	import com.custardbelly.as3couchdb.responder.ICouchServiceResponder;

	/**
	 * ICouchDocumentService is an interface for communication with a CouchDB instance with regards to documents held on a database. 
	 * @author toddanderson
	 */
	public interface ICouchDocumentService extends ICouchService
	{
		/**
		 * Reads in a document from a database held on the CouchDB instance. 
		 * @param documentId String
		 * @param responder ICouchServiceResponder
		 */
		function readDocument( documentId:String, responder:ICouchServiceResponder = null ):void;
		/**
		 * Creates a new document in the database held on the CouchDB instance. 
		 * @param documentId String
		 * @param responder ICouchServiceResponder
		 */
		function createDocument( documentId:String, responder:ICouchServiceResponder = null ):void;
		/**
		 * Saves/updates a document in the database held on the CouchDB instance. 
		 * @param document CouchDocument
		 * @param responder ICouchServiceResponder
		 */
		function saveDocument( document:CouchDocument, responder:ICouchServiceResponder = null ):void;
		/**
		 * Deletes a document from the database held on the CouchDB instance. 
		 * @param documentId String
		 * @param documentRevision String
		 * @param responder ICouchServiceResponder
		 */
		function deleteDocument( documentId:String, documentRevision:String, responder:ICouchServiceResponder = null ):void;
	}
}