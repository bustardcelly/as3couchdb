/**
 * <p>Original Author: toddanderson</p>
 * <p>Class File: CouchDocumentWriter.as</p>
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
package com.custardbelly.as3couchdb.serialize
{
	import com.adobe.serialization.json.JSON;
	import com.custardbelly.as3couchdb.core.CouchAttachment;
	import com.custardbelly.as3couchdb.core.CouchDocument;
	
	import flash.utils.Dictionary;
	import flash.utils.describeType;

	/**
	 * CouchDocumentWriter handles writing attributes from a target document to an object that CouchDB can interpret. 
	 * @author toddanderson
	 */
	public class CouchDocumentWriter implements ICouchDocumentWriter
	{
		/**
		 * @private
		 * 
		 * Properties held on a CouchDocument model that do not have related properties for a document represented in CouchDB. 
		 */
		protected var transientProperties:Dictionary;
		
		/**
		 * Constructor.
		 */
		public function CouchDocumentWriter() 
		{
			transientProperties = new Dictionary( true );
			assignTransientProperties();
		}
		
		/**
		 * Fills transient properties map with attributes that should be excluded when creating clones of this object for update/create.
		 */
		protected function assignTransientProperties():void
		{
			transientProperties["id"] = true;
			transientProperties["revision"] = true;
			transientProperties["attachments"] = true;
			transientProperties["isDeleted"] = true;
			transientProperties["baseUrl"] = true;
			transientProperties["databaseName"] = true;
			transientProperties["entity"] = true;
		}
		
		/**
		 * @private
		 * 
		 * Creates a generic duplicate of an Object to be passed along within a service operation.  
		 * @param document Object The document to duplicate into a generic object.
		 * @return Object
		 */
		protected function createDuplicate( document:Object ):Object
		{
			var duplicate:Object = {};
			var info:XML = describeType( document );
			var attributes:XMLList = info..*.( name() == "variable" || name() == "accessor" );
			var node:XML;
			for each( node in attributes )
			{
				if( !transientProperties[node.@name.toString()] )
					duplicate[node.@name] = document[node.@name];
			}
			return duplicate;
		}
		
		/**
		 * Returns a map of previously held attachments on the document. In previous versions, an update to document did not remove attachments. 
		 * In latest CouchDB attachment stubs returned from a read need to be supplied in order to maintain previously held attachments. 
		 * @param list Vector List of CouchAttachment.
		 * @return Object
		 */
		protected function serializeAttachments( list:Vector.<CouchAttachment> ):Object
		{
			var attachments:Object = {};
			var i:int;
			var length:int = list.length;
			var attachment:CouchAttachment;
			var stub:Object;
			var file:String;
			for( i = 0; i < length; i++ )
			{
				attachment = list[i];
				stub = attachment.stub;
				for( file in stub )
				{
					attachments[file] = stub[file];
				}
			}
			return attachments;
		}
		
		/**
		 * Serializes document into a JSON encoded object that the CouchDB instance interprets. 
		 * @param document Object
		 * @return String
		 */
		public function serializeDocumentForUpdate( document:Object ):String
		{
			var duplicate:Object = createDuplicate( document );
			duplicate["_rev"] = document.revision;
			try
			{
				if( document.hasOwnProperty( "attachments" ) && document.attachments != null && document.attachments.length > 0 )
				{
					duplicate["_attachments"] = serializeAttachments( document.attachments as Vector.<CouchAttachment> );
				}
			}
			catch( e:Error )
			{
				// gracefully fail. No attachments.
			}
			return JSON.encode( duplicate );
		}
		
		/**
		 * Serializes document into a JSON encoded object that the CouchDB instance interprets. 
		 * @param document Object
		 * @return String
		 */
		public function serializeDocumentForCreation( document:Object ):String
		{
			var duplicate:Object = createDuplicate( document );
			return JSON.encode( duplicate );
		}
	}
}