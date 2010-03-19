/**
 * <p>Original Author: toddanderson</p>
 * <p>Class File: UpdateDocumentResponder.as</p>
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
package com.custardbelly.as3couchdb.responder
{
	import com.custardbelly.as3couchdb.core.CouchDocument;
	import com.custardbelly.as3couchdb.core.CouchServiceFault;
	import com.custardbelly.as3couchdb.core.CouchServiceResult;
	import com.custardbelly.as3couchdb.serialize.CouchDocumentReader;
	import com.custardbelly.as3couchdb.serialize.ICouchDocumentReader;
	
	/**
	 * UpdateDocumentResponder is an ICouchServiceResponder that handles result and fault responses from a service with regards to the target document instance in CouchDB. 
	 * @author toddanderson
	 */
	public class UpdateDocumentResponder implements ICouchServiceResponder
	{
		protected var _status:int;
		protected var _document:CouchDocument;
		protected var _action:String;
		protected var _responder:ICouchServiceResponder;	
		/**
		 * @private
		 * 
		 * The reader that is knowledgable about the returned data and its attributes in relation to documents.
		 */
		protected var _reader:ICouchDocumentReader;
		
		/**
		 * Constructor. 
		 * @param document CouchDocument The target document.
		 * @param action String The target action performed by the service.
		 * @param responder ICouchServiceResponder The resultant responder after having handle service response accordingly. 
		 * 
		 */
		public function UpdateDocumentResponder( document:CouchDocument, action:String, responder:ICouchServiceResponder )
		{
			_responder = responder;
			_action = action;
			_document = document;
			// create reader that knows how to interpret returned service results.
			_reader = new CouchDocumentReader();
		}
		
		/**
		 * Result handler for response from service. Parses result to determine if the data relates to an error or success.
		 * @param value CouchServiceResult
		 */
		public function handleResult( value:CouchServiceResult ):void
		{
			var result:Object = value.data;
			if( _reader.isResultAnError( result ) )
			{
				handleFault( new CouchServiceFault( result["error"], result["reason"] ) );
			}
			else
			{
				// update target document based on result.
				_reader.updateDocumentFromResult( _document, result );
				if( _responder ) _responder.handleResult( new CouchServiceResult( _action, _document ) );
			}
		}
		
		/**
		 * Fault handle for response from service. 
		 * @param value CouchServiceFault
		 */
		public function handleFault( value:CouchServiceFault ):void
		{
			if( _responder ) _responder.handleFault( value );
		}
		
		/**
		 * Returns the current HTTP status of the service operation. 
		 * @return int
		 */
		public function get status():int
		{
			return _status;
		}
		public function set status( value:int ):void
		{
			_status = value;
		}
	}
}