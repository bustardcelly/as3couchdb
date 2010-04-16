/**
 * <p>Original Author: toddanderson</p>
 * <p>Class File: AbstractDocumentResponder.as</p>
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
package com.custardbelly.as3couchdb.responder
{
	import com.custardbelly.as3couchdb.core.CouchDocument;
	import com.custardbelly.as3couchdb.core.CouchServiceFault;
	import com.custardbelly.as3couchdb.core.CouchServiceResult;
	import com.custardbelly.as3couchdb.serialize.CouchDocumentReader;
	import com.custardbelly.as3couchdb.serialize.ICouchDocumentReader;
	
	import flash.errors.IllegalOperationError;
	import flash.utils.getQualifiedClassName;
	
	/**
	 * AbtstractDocumentResponder is a abstract responder to service requests related to a couch document. 
	 * @author toddanderson
	 */
	public class AbstractDocumentResponder implements ICouchServiceResponder
	{
		protected var _document:CouchDocument;
		protected var _responder:ICouchServiceResponder;
		/**
		 * @private
		 * 
		 * The reader that is knowledgable about the returned data and its attributes in relation to documents.
		 */
		protected var _reader:ICouchDocumentReader;
		protected var _status:int;
		
		/**
		 * Constructor. 
		 * @param document CouchDocument
		 * @param responder ICouchServiceResponder
		 */
		public function AbstractDocumentResponder( document:CouchDocument, responder:ICouchServiceResponder )
		{
			_document = document;
			_responder = responder;
			_reader = new CouchDocumentReader();
		}
		
		/**
		 * @private
		 * 
		 * Responds to successful response to determine if the result is an error.
		 * @param value CouchServicResult
		 * @return Boolean
		 */
		protected function handleResultAsError( value:CouchServiceResult ):Boolean
		{
			var result:Object = value.data;
			if( _reader.isResultAnError( result ) )
			{
				handleFault( new CouchServiceFault( result["error"], 0, result["reason"] ) );
				return true;
			}
			return false;
		}									 
		
		/**
		 * Abstract responder method for the service request. 
		 * @param value CouchServicResult
		 */
		public function handleResult(value:CouchServiceResult):void
		{
			// abstract.
			throw new IllegalOperationError( "[" + getQualifiedClassName( this ) + "::handleResult] - Method needs to be overridden in concrete class." );
		}
		
		/**
		 * Responder method for the service request fault. 
		 * @param value CouchServiceFault
		 */
		public function handleFault(value:CouchServiceFault):void
		{
			if( _responder ) _responder.handleFault( value );
		}
		
		/**
		 * Returns the current HTTP status code of the request. 
		 * @return int
		 */
		public function get status():int
		{
			return _status;
		}
		public function set status(value:int):void
		{
			_status = value;
		}
	}
}