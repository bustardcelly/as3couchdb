/**
 * <p>Original Author: toddanderson</p>
 * <p>Class File: CouchDatabase.as</p>
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
package com.custardbelly.as3couchdb.core
{
	import com.custardbelly.as3couchdb.mediator.CouchDatabaseActionMediator;
	import com.custardbelly.as3couchdb.mediator.ICouchDatabaseActionMediator;
	import com.custardbelly.as3couchdb.service.CouchDatabaseService;
	
	/**
	 * Dispatched upon successful create of a database instance in CouchDB. 
	 */
	[Event(name="create", type="com.custardbelly.as3couchdb.enum.CouchActionType")]
	/**
	 * Dispatched upon successful read in and application of attributes from a database instance in CouchDB. 
	 */
	[Event(name="read", type="com.custardbelly.as3couchdb.enum.CouchActionType")]
	/**
	 * Dispatched upon successful read in of all documents from CouchDB. Documents are returned as generic objects from _all_docs, or cast as model instances from view request. 
	 */
	[Event(name="readDocuments", type="com.custardbelly.as3couchdb.enum.CouchActionType")]
	/**
	 * Dispatched upon successful deletion of database in CouchDB. 
	 */
	[Event(name="delete", type="com.custardbelly.as3couchdb.enum.CouchActionType")]
	/**
	 * Dispatched upon fault from create of request. 
	 */
	[Event(name="fault", type="com.custardbelly.as3couchdb.event.CouchEvent")]
	
	/**
	 * <p>CouchDatabase is a base model representing an instance of a Couch Database. To effectively use a CouchDatabase and its methods,
	 * this class should be extended and metadata information annotated describing the base url and database name of the CouchDatabase instance and the 
	 * name of the database which this model represents.</p>
	 * 
	 * <example>
	 * [DocumentService(url="http://127.0.0.1:5984", name="contacts")]
	 * [ServiceMediator(name="com.custardbelly.as3couchdb.mediator.CouchDatabaseActionMediator")]
	 * [RequestType(name="com.custardbelly.as3couchdb.service.HTTPCouchRequest")]
	 * public class ContactsDatabase extends CouchDatabase
	 * {
	 * 	...
	 * }
	 * </example>
	 *  
	 * @author toddanderson
	 */	
	public class CouchDatabase extends CouchModel
	{
//		public var db_name:String;
//		public var doc_count:int;
//		public var doc_del_count:int;
//		public var update_seq:int;
//		public var purge_seq:int;
//		public var compact_running:Boolean;
//		public var disk_size:Number;
//		public var instance_start_time:Number;
//		public var disk_format_version:int;
//		
		protected var _info:Object;
		
		/**
		 * @private
		 * 
		 * Type reference to mediator held on super model. 
		 */
		protected var _actionMediator:ICouchDatabaseActionMediator;
		
		/**
		 * Constructor. Resolves entity and creates ICouchDatabaseActionMediator to handle service actions.
		 * @param entity CouchModelEntity Optional CouchModelEntity instance. If supplied, the properties will be resolved to that entity. If not, metadata will be parsed to construct entity.
		 */
		public function CouchDatabase( entity:CouchModelEntity = null )
		{
			super( entity );
//			db_name = databaseName;
			_info = new Object();
			_actionMediator = _mediator as ICouchDatabaseActionMediator;
		}
		
		/**
		 * Returns the info object populated by creatIfNotExist() and info() invocation. 
		 * @return 
		 * 
		 */
		public function getInfo():Object
		{
			return _info;
		}
		
		/**
		 * Invokes action mediator to create database if not exists.
		 */
		public function createIfNotExist():void
		{
			_actionMediator.doCreateIfNotExist();
		}
		
		/**
		 * Invokes action mediator to read in database information.
		 */
		public function read():void
		{
			_actionMediator.doRead();
		}
		
		/**
		 * Invokes action mediator to delete database.
		 */
		public function remove():void
		{
			_actionMediator.doDelete();
		}
		
		/**
		 * Invokes action mediator to request information about database.
		 */
		public function info():void
		{
			_actionMediator.doInfo();
		}
		
		/**
		 * Invokes action mediator to request changes to database.
		 */
		public function getChanges():void
		{
			_actionMediator.doGetChanges();	
		}
		
		/**
		 * Invokes action mediator to compact and optionally cleanup database. 
		 * @param cleanup Boolean
		 */
		public function compact( cleanup:Boolean = false ):void
		{
			_actionMediator.doCompact( cleanup );
		}
		
		/**
		 * Invokes action mediator to return all documents related to database.
		 * Documents are returned as generic objects as _all_docs returns a list of all documents from a database, including _design docs.
		 * To return resolved documents to a model, see #getDocumentsFromView.
		 */
		public function getAllDocuments():void
		{
			_actionMediator.doGetAllDocuments();
		}
		
		/**
		 * Invokes action mediator to return all documents returned from a design document view, filter by optional key value. 
		 * @param designDocumentName String The design document name within the database.
		 * @param viewName String The view name to query on which the map/reduce methods reside.
		 * @param documentClass String The fully qualified Class name. This is used to resolve results to a sepcified type of model.
		 * @param documentEntity CouchModelEntity The optional CouchModelEntity to supply to resolved documentClass instances based on result.
		 * @param keyValue String Optional filter on results by key type.
		 */
		public function getDocumentsFromView( designDocumentName:String, viewName:String, documentClass:String, documentEntity:CouchModelEntity = null, keyValue:String = null ):void
		{
			_actionMediator.doGetDocumentsFromView( designDocumentName, viewName, keyValue, documentClass, ( documentEntity ) ? documentEntity.clone() : null );
		}
	}
}