/**
 * <p>Original Author: toddanderson</p>
 * <p>Class File: CouchDocumentWriter.as</p>
 * <p>Version: 0.4</p>
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
	import com.custardbelly.as3couchdb.core.CouchDocument;
	
	import flash.utils.Dictionary;
	import flash.utils.describeType;

	/**
	 * CouchDocumentWriter handles writing attributes from a target document to an object that CouchDB can interpret. 
	 * @author toddanderson
	 */
	public class CouchDocumentWriter
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
			transientProperties["id"] = true;
			transientProperties["revision"] = true;
			transientProperties["attachments"] = true;
			transientProperties["isDeleted"] = true;
			transientProperties["baseUrl"] = true;
			transientProperties["databaseName"] = true;
		}
		
		/**
		 * @private
		 * 
		 * Creates a generic duplicate of a CouchDocument to be passed along within a service operation.  
		 * @param document CouchDocument The document to duplicate into a generic object.
		 * @return Object
		 */
		protected function createDuplicate( document:CouchDocument ):Object
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
		 * Serializes document into a JSON encoded object that the CouchDB instance interprets. 
		 * @param document CouchDocument
		 * @return String
		 */
		public function serializeDocumentForUpdate( document:CouchDocument ):String
		{
			var duplicate:Object = createDuplicate( document );
			duplicate["_rev"] = document.revision;
			return JSON.encode( duplicate );
		}
		
		/**
		 * Serializes document into a JSON encoded object that the CouchDB instance interprets. 
		 * @param document CouchDocument
		 * @return String
		 */
		public function serializeDocumentForCreation( document:CouchDocument ):String
		{
			var duplicate:Object = createDuplicate( document );
			return JSON.encode( duplicate );
		}
	}
}