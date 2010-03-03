/**
 * <p>Original Author: toddanderson</p>
 * <p>Class File: CouchDocumentReader.as</p>
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
package com.custardbelly.as3couchdb.serialize
{
	import com.adobe.serialization.json.JSON;
	import com.custardbelly.as3couchdb.core.CouchDocument;
	
	import flash.utils.Dictionary;
	import flash.utils.getQualifiedClassName;

	/**
	 * CouchDocumentReader interprets result returned from service and applies any related attributes to target document. 
	 * @author toddanderson
	 */
	public class CouchDocumentReader implements ICouchDocumentReader
	{
		/**
		 * Map of reserved properties on a document residing in a CouchDB instance. 
		 */
		protected var reservedProperties:Dictionary;
		
		/**
		 * Constructor.
		 */
		public function CouchDocumentReader() 
		{
			reservedProperties = new Dictionary( true );
			reservedProperties["_id"] = true;
			reservedProperties["_rev"] = true;
			reservedProperties["_attachments"] = true;
		}
		
		/**
		 * Returns flag of result related to an error. 
		 * @param result Object
		 * @return Boolean
		 */
		public function isResultAnError( result:Object ):Boolean
		{
			return result["error"] != null;
		}
		
		/**
		 * Updates the target CouchDocument and its attributes based on the result object. 
		 * @param document CouchDocument
		 * @param result Object
		 */
		public function updateDocumentFromRead( document:CouchDocument, result:Object ):void
		{
			document.revision = result["_rev"];
			document.attachments = result["_attachments"];
			var attribute:String;
			for( attribute in result )
			{
				try 
				{
					// try an apply the attributes held on the result to the document.
					document[attribute] = result[attribute];
				}
				catch( e:Error )
				{
					// If attribute does not exist, do not throw RTE, but notify in console.
					trace( "Document being written to, [" + getQualifiedClassName(document) + "] does not support the following property returned: " + attribute );
				}
			}
		}
		
		/**
		 * Updates the document from a generic result from a service operation. 
		 * @param document CouchDocument
		 * @param result Object
		 */
		public function updateDocumentFromResult( document:CouchDocument, result:Object ):void
		{
			document.revision = result["rev"];
		}
		
		/**
		 * Updates target document from creation result of service operation. 
		 * @param document CouchDocument
		 * @param result Object
		 */
		public function updateDocumentFromCreation( document:CouchDocument, result:Object ):void
		{
			document.id = result["id"];
			document.revision = result["rev"];
			document.attachments = result["attachments"];
		}
	}
}