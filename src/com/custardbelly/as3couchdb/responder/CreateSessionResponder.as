/**
 * <p>Original Author: toddanderson</p>
 * <p>Class File: CreateSessionResponder.as</p>
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
	import com.custardbelly.as3couchdb.core.CouchServiceFault;
	import com.custardbelly.as3couchdb.core.CouchServiceResult;
	import com.custardbelly.as3couchdb.net.CouchSessionResponse;
	import com.custardbelly.as3couchdb.serialize.CouchResponseReader;
	import com.custardbelly.as3couchdb.serialize.ICouchResponseReader;

	/**
	 * CreateSessionResponder is an action responder for the request to start a new session on CouchDB.
	 * @author toddanderson
	 */
	public class CreateSessionResponder extends BasicCouchResponder
	{
		/**
		 * The ICouchResponseReader that handles determining the validity of the response. 
		 */
		protected var _reader:ICouchResponseReader;
		
		/**
		 * Constructor. 
		 * @param resultFunction Function The method to invoke on success of response.
		 * @param faultFunction Function The method to invoke on fault of response.
		 */
		public function CreateSessionResponder( resultFunction:Function, faultFunction:Function )
		{
			super( resultFunction, faultFunction );
			_reader = new CouchResponseReader();
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
			var result:Object = ( value.data as CouchSessionResponse ).result;
			if( _reader.isResultAnError( result ) )
			{
				handleFault( new CouchServiceFault( result["error"], 0, result["reason"] ) );
				return true;
			}
			return false;	
		}					
		
		/**
		 * @inherit
		 */
		override public function handleResult( value:CouchServiceResult ):void
		{
			// Check if we need to handle as error.
			if( !handleAsResultError( value ) )
			{
				super.handleResult( value );	
			}
		}
	}
}