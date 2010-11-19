/**
 * <p>Original Author: toddanderson</p>
 * <p>Class File: ExInCouchRequest.as</p>
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
package com.custardbelly.as3couchdb.service
{
	import com.adobe.serialization.json.JSON;
	import com.custardbelly.as3couchdb.core.CouchServiceFault;
	import com.custardbelly.as3couchdb.core.CouchServiceResult;
	import com.custardbelly.as3couchdb.enum.CouchRequestMethod;
	import com.custardbelly.as3couchdb.event.CouchEvent;
	import com.custardbelly.as3couchdb.responder.ICouchServiceResponder;
	
	import flash.external.ExternalInterface;
	import flash.net.URLRequest;
	
	/**
	 * ExInCouchRequest is an ICouchRequest implementation that uses ExternalInterface calls to communicate with a CouchDB instance. 
	 * @author toddanderson
	 */
	public class ExInCouchRequest extends AbstractCouchRequest
	{	
		/**
		 * Constructor.
		 */
		public function ExInCouchRequest() 
		{
			if( ExternalInterface.available )
			{
				ExternalInterface.addCallback( "PUTResponse", handlePutResponse );
				ExternalInterface.addCallback( "POSTResponse", handlePostResponse );
				ExternalInterface.addCallback( "GETResponse", handleGetResponse );
				ExternalInterface.addCallback( "DELETEResponse", handleDeleteResponse );
				ExternalInterface.addCallback( "FaultResponse", handleFault );
			}
			else
			{
				trace( "ExternalInterface is not available. COUCHDB service requests will not be permittable." );
			}
		}
		
		/**
		 * @private
		 * 
		 * Notifies ICouchServiceResponder instance of result. 
		 * @param result Object The resulting object recieve form EI.
		 */
		protected function notifyOfResult( result:Object ):void
		{
			respondToResult( CouchEvent.RESULT, JSON.encode( result ) );
		}
		
		/**
		 * @private
		 * 
		 * Method callback from EI for PUT response. 
		 * @param result Object
		 */
		protected function handlePutResponse( result:Object ):void
		{
			notifyOfResult( result );
		}
		
		/**
		 * @private
		 * 
		 * Method callback from EI for POST response. 
		 * @param result Object
		 */
		protected function handlePostResponse( result:Object ):void
		{
			notifyOfResult( result );
		}
		
		/**
		 * @private
		 * 
		 * Method callback from EI for GET response. 
		 * @param result Object
		 */
		protected function handleGetResponse( result:Object ):void
		{
			notifyOfResult( result );
		}
		
		/**
		 * @private
		 * 
		 * Method callback from EI for DELETE response. 
		 * @param result Object
		 */
		protected function handleDeleteResponse( result:Object ):void
		{
			notifyOfResult( result );	
		}
		
		/**
		 * @private
		 * 
		 * Method callback for fault from EI for service request. 
		 * @param result Object
		 */
		protected function handleFault( result:Object ):void
		{
			// TODO: Decipher fault for correct message.
			respondToFault( CouchEvent.FAULT, 0, "error" );
		}
		
		/**
		 * @inherit
		 */
		override public function execute( request:URLRequest, requestType:String, responder:ICouchServiceResponder ):void
		{
			super.execute( request, requestType, responder );
			
			switch( requestType )
			{
				case CouchRequestMethod.PUT:
					ExternalInterface.call( "PUTRequest", request.url, request.data );
					break;
				case CouchRequestMethod.POST:
					ExternalInterface.call( "POSTRequest", request.url, request.data );
					break;
				case CouchRequestMethod.GET:
					ExternalInterface.call( "GETRequest", request.url );
					break;
				case CouchRequestMethod.DELETE:
					ExternalInterface.call( "DELETERequest", request.url );
					break;
			}
		}
	}
}