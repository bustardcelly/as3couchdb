/**
 * <p>Original Author: toddanderson</p>
 * <p>Class File: CouchRequest.as</p>
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
package com.custardbelly.as3couchdb.service
{
	import com.adobe.serialization.json.JSON;
	import com.custardbelly.as3couchdb.core.CouchServiceFault;
	import com.custardbelly.as3couchdb.core.CouchServiceResult;
	import com.custardbelly.as3couchdb.enum.CouchActionType;
	import com.custardbelly.as3couchdb.event.CouchEvent;
	import com.custardbelly.as3couchdb.responder.ICouchServiceResponder;
	
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	/**
	 * CouchRequest handles making and responding to requests to the CouchDB instance.
	 * @author toddanderson
	 */
	public class CouchRequest extends AbstractCouchRequest
	{
		protected var  _loader:URLLoader;
		
		/**
		 * Constructor.
		 */
		public function CouchRequest()
		{
			_loader = new URLLoader();
			addListeners();
		}
		
		/**
		 * @private 
		 * 
		 * Assigns event listeners to the URLLoader instance.
		 */
		protected function addListeners():void
		{
			_loader.addEventListener( Event.COMPLETE, handleResponseComplete, false, 0, true );
			_loader.addEventListener( HTTPStatusEvent.HTTP_STATUS, handleResponseStatus, false, 0, true );
			_loader.addEventListener( SecurityErrorEvent.SECURITY_ERROR, handleResponseSecurityError, false, 0, true );
			_loader.addEventListener( IOErrorEvent.IO_ERROR, handleResponseError, false, 0, true );
		}
		
		/**
		 * @private 
		 * 
		 * Removes event listeners from the URLLoader instance.
		 */
		protected function removeListeners():void
		{
			_loader.removeEventListener( Event.COMPLETE, handleResponseComplete, false );
			_loader.removeEventListener( HTTPStatusEvent.HTTP_STATUS, handleResponseStatus, false );
			_loader.removeEventListener( SecurityErrorEvent.SECURITY_ERROR, handleResponseSecurityError, false );
			_loader.removeEventListener( IOErrorEvent.IO_ERROR, handleResponseError, false );
		}
		
		/**
		 * @private
		 * 
		 * Event handler for HTTPStatus. 
		 * @param evt HTTPStatusEvent
		 */
		protected function handleResponseStatus( evt:HTTPStatusEvent ):void
		{
			respondToStatus( evt.status );
		}
		
		/**
		 * @private
		 * 
		 * Event handler for i/o error. 
		 * @param evt IOErrorEvent
		 */
		protected function handleResponseError( evt:IOErrorEvent ):void
		{
			respondToFault( evt.type.toUpperCase(), evt.text );
		}
		
		/**
		 * @private
		 * 
		 * Event hanlder for security error.
		 * @param evt SecurityErrorEvent
		 */
		protected function handleResponseSecurityError( evt:SecurityErrorEvent ):void
		{
			respondToFault( evt.type.toUpperCase(), evt.text );
		}
		
		/**
		 * @private
		 * 
		 * Event handler for completion of service operation. 
		 * @param evt Event
		 */
		protected function handleResponseComplete( evt:Event ):void
		{
			var result:Object = ( evt.target as URLLoader ).data;
			respondToResult( CouchEvent.RESULT, JSON.decode( result.toString() ) );
		}
		
		/**
		 * @inherit
		 */
		override public function execute( request:URLRequest, requestType:String, responder:ICouchServiceResponder ):void
		{
			super.execute( request, requestType, responder );
			request.method = requestType;
			_loader.load( request );
		}
		
		/**
		 * @inherit
		 */
		override public function dispose():void
		{
			super.dispose();
			removeListeners();
			_loader = null;
		}
	}
}