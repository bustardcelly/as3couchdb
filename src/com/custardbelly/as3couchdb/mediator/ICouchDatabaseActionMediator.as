/**
 * <p>Original Author: toddanderson</p>
 * <p>Class File: ICouchDatabaseMediator.as</p>
 * <p>Version: 0.6</p>
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
package com.custardbelly.as3couchdb.mediator
{
	import com.custardbelly.as3couchdb.core.CouchModelEntity;

	/**
	 * ICouchDatabaseActionMediator is a mediator for invoking service operations relate to a target database. 
	 * @author toddanderson
	 */
	public interface ICouchDatabaseActionMediator extends IServiceMediator
	{
		/**
		 * Invokes service to create a database. If database exists, reads in database information.
		 */
		function doCreateIfNotExist():void;
		/**
		 * Invokes service to read in database. 
		 * @param action String The resulting action from the operation.
 		 */
		function doRead( action:String = null ):void;
		/**
		 * Invokes service to delete database.
		 */
		function doDelete():void;
		/**
		 * Invokes service to request information related to a database.
		 */
		function doInfo():void;
		/**
		 * Invokes service to request changes related to a database.
		 */
		function doGetChanges():void;
		/**
		 * Invokes service to compact database and optionally perform cleanup. 
		 * @param cleanup Boolean
		 */
		function doCompact( cleanup:Boolean ):void;
		/**
		 * Invokes action mediator to return all documents related to database.
		 * Documents are returned as generic objects as _all_docs returns a list of all documents from a database, including _design docs.
		 * To return resolved documents to a model, see #getDocumentsFromView.
		 */
		function doGetAllDocuments():void;
		/**
		 * Invokes service to request documents based on design view map/reduce with optional key value filter. 
		 * @param designDocumentName String
		 * @param viewName String
		 * @param keyValue String
		 * @param documentClass String The fully qualified Class name. This is used to resolve results to a specific model type.
		 * @param documentEntity CouchModelEntity The optional CouchModelEntity instance to clone and supply to new instances of documentClass
		 */
		function doGetDocumentsFromView( designDocumentName:String, viewName:String, keyValue:String,  documentClass:String, documentEntity:CouchModelEntity = null ):void;
	}
}