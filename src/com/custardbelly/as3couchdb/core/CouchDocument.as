/**
 * <p>Original Author: toddanderson</p>
 * <p>Class File: CouchDocument.as</p>
 * <p>Version: 0.1</p>
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
	import com.custardbelly.as3couchdb.mediator.CouchDocumentActionMediator;
	import com.custardbelly.as3couchdb.mediator.ICouchDocumentActionMediator;
	import com.custardbelly.as3couchdb.service.CouchDocumentService;
	
	/**
	 * Dispatched upon successful read in and application of attributes for a document instance in CouchDB. 
	 */
	[Event(name="read", type="com.custardbelly.as3couchdb.event.CouchEvent")]
	/**
	 * Dispatched upon successful creation and update of a document in CouchDB. 
	 */
	[Event(name="save", type="com.custardbelly.as3couchdb.event.CouchEvent")]
	/**
	 * Dispatched upon successful deletion of document in CouchDB. 
	 */
	[Event(name="delete", type="com.custardbelly.as3couchdb.event.CouchEvent")]
	
	/**
	 * <p>CouchDocument is a base model representing an instance of a document within a databse of CouchDB. To effectively use a CouchDocument and its methods,
	 * this class should be extended and metadata information annotated describing the base url and database name of the CouchDocument instance and the 
	 * name of the database which this model represents.</p>
	 * 
	 * <example>
	 * [DocumentService(url="http://127.0.0.1:5984", name="contacts")]
	 * public class ContactDocument extends CouchDocument
	 * {
	 * 	...
	 * }
	 * </example>
	 *  
	 * @author toddanderson
	 */	
	public class CouchDocument extends CouchModel
	{
		protected var _id:String;
		protected var _revision:String;
		protected var _attachments:Object; 	// Generic map of key/value.
		
		protected var _actionMediator:ICouchDocumentActionMediator;
		
		/**
		 * Constructor. Resolves entity and creates ICouchDocumentActionMediator to handle service actions.
		 */
		public function CouchDocument()
		{
			super();
			_actionMediator = new CouchDocumentActionMediator( this, CouchDocumentService.getDocumentService( baseUrl, databaseName ) ); 
		}
		
		/**
		 * Invokes the action mediator to read in a document and populate attributes on this instance. 
		 * @param id String
		 */
		public function read( id:String ):void
		{
			_actionMediator.handleRead( id );
		}
		
		/**
		 * Invokes the action mediator to save this document instance to the CouchDB database.
		 */
		public function save():void
		{
			_actionMediator.handleSave();
		}
		
		/**
		 * Invokes the action mediator to delete this document from the CouchDB database.
		 */
		public function remove():void
		{
			_actionMediator.handleDelete();
		}
		
		/**
		 * Returns the unique identifier for this document. 
		 * @return String
		 */
		public function get id():String
		{
			return _id;
		}
		public function set id( value:String ):void
		{
			_id = value;
		}
		
		/**
		 * Returns the unique revision key for this document. 
		 * @return String
		 */
		public function get revision():String
		{
			return _revision;
		}
		public function set revision( value:String ):void
		{
			_revision = value;
		}
		
		/**
		 * Returns a generic object describing attachments associated with this document. 
		 * @return Object
		 */
		public function get attachments():Object
		{
			return _attachments;
		}
		public function set attachments( value:Object ):void
		{
			_attachments = value;
		}
		
		//		function getRevisions():Array;
		//		function getRevisionsInfo():Array;
		//		function getConflicts():Array;
	}
}