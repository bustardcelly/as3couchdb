/**
 * <p>Original Author: toddanderson</p>
 * <p>Class File: AbstractUserResponder.as</p>
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
package com.custardbelly.as3couchdb.responder
{
	import com.custardbelly.as3couchdb.core.CouchServiceFault;
	import com.custardbelly.as3couchdb.core.CouchServiceResult;
	import com.custardbelly.as3couchdb.core.CouchUser;
	import com.custardbelly.as3couchdb.serialize.CouchUserReader;
	import com.custardbelly.as3couchdb.serialize.ICouchUserReader;
	
	import flash.errors.IllegalOperationError;
	import flash.utils.getQualifiedClassName;

	/**
	 * AbstractUserResponder is a service responder for actions taken by a user communicating with the service. 
	 * @author toddanderson
	 */
	public class AbstractUserResponder implements ICouchServiceResponder
	{
		protected var _user:CouchUser;
		protected var _responder:ICouchServiceResponder;
		protected var _reader:ICouchUserReader;
		protected var _status:int;
		
		/**
		 * Constructor. 
		 * @param user CouchUser The target user.
		 * @param responder ICouchServiceResponder The responder to notify on result or fault from the service.
		 */
		public function AbstractUserResponder( user:CouchUser, responder:ICouchServiceResponder )
		{
			_user = user;
			_responder = responder;
			// Create reader of response from service.
			_reader = new CouchUserReader();
		}
		
		/**
		 * @private
		 * 
		 * Validates the result as being a successful error return or not. 
		 * @param result CouchServicResult
		 * @return Boolean
		 */
		protected function handleAsResultError( value:CouchServiceResult ):Boolean
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
		 * Responder method to success in service request.
		 * @param value CouchServiceResult
		 */
		public function handleResult( value:CouchServiceResult ):void
		{
			// abstract.
			throw new IllegalOperationError( "[" + getQualifiedClassName( this ) + "::handleResult] - Method needs to be overridden in concrete class." );
		}
		
		/**
		 * Responder method to fault in service request. 
		 * @param value CouchServiceFault
		 */
		public function handleFault( value:CouchServiceFault ):void
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