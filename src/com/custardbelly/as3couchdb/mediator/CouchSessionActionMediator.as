/**
 * <p>Original Author: toddanderson</p>
 * <p>Class File: CouchSessionActionMediator.as</p>
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
package com.custardbelly.as3couchdb.mediator
{
	import com.custardbelly.as3couchdb.command.IRequestCommand;
	import com.custardbelly.as3couchdb.core.CouchModel;
	import com.custardbelly.as3couchdb.core.CouchServiceFault;
	import com.custardbelly.as3couchdb.core.CouchServiceResult;
	import com.custardbelly.as3couchdb.core.CouchSession;
	import com.custardbelly.as3couchdb.core.CouchUser;
	import com.custardbelly.as3couchdb.enum.CouchActionType;
	import com.custardbelly.as3couchdb.event.CouchEvent;
	import com.custardbelly.as3couchdb.net.CouchSessionResponse;
	import com.custardbelly.as3couchdb.responder.BasicCouchResponder;
	import com.custardbelly.as3couchdb.responder.CreateSessionResponder;
	import com.custardbelly.as3couchdb.responder.ICouchServiceResponder;
	import com.custardbelly.as3couchdb.service.CouchService;
	import com.custardbelly.as3couchdb.service.ICouchRequest;
	import com.custardbelly.as3couchdb.service.ICouchService;
	
	public class CouchSessionActionMediator implements ICouchSessionActionMediator
	{
		protected var _session:CouchSession;
		protected var _service:ICouchService;
		protected var _pendingCommandRequest:IRequestCommand;
		
		/**
		 * Constructor.
		 */
		public function CouchSessionActionMediator()
		{
			// empty.
		}
		
		/**
		 * Initializes the mediator to establish the service in which to communicate actions related to the target model. 
		 * @param target CouchModel
		 * @param baseUrl String
		 * @param databaseName String
		 * @param request ICouchRequest The ICouchRequest implmementation to forward requests through.
		 */
		public function initialize( target:CouchModel, baseUrl:String, databaseName:String, request:ICouchRequest=null ):void
		{
			_session = target as CouchSession;
			_service = CouchService.getSessionService( baseUrl, request );
		}
		
		/**
		 * @private
		 * 
		 * Updates the stored session for requests on CouchDB instance. 
		 * @param cookie String
		 */
		protected function updateSession( cookie:String ):void
		{
			// Set cookie upon session.
			_session.cookie = cookie;
			// Supplie current session to service.
			CouchService.session = _session;
		}
		
		/**
		 * @private
		 * 
		 * Responder method to do a successful result from a service operation. 
		 * @param result CouchServiceResult
		 */
		protected function handleServiceResult( result:CouchServiceResult ):void
		{	
			var response:CouchSessionResponse = result.data as CouchSessionResponse;
			var cookie:String = response.cookie;
			// Update session.
			updateSession( cookie );
			// Dispatch event through target document.
			_session.dispatchEvent( new CouchEvent( CouchActionType.SESSION_CREATE, _session ) );
		}
		
		/**
		 * @private
		 * 
		 * Responder method to do a fault from a service operation. 
		 * @param fault CouchServiceFault
		 */
		protected function handleServiceFault( fault:CouchServiceFault ):void
		{
			// Dispatch event through target document.
			_session.dispatchEvent( new CouchEvent( CouchEvent.FAULT, fault ) );
		}
		
		/**
		 * @private
		 * 
		 * Responder method for success in renewal of cookie. 
		 * @param result CouchServiceResult
		 */
		protected function handleRenewResult( result:CouchServiceResult ):void
		{
			var response:CouchSessionResponse = result.data as CouchSessionResponse;
			var cookie:String = response.cookie;
			// Update session.
			updateSession( cookie );
		}
		
		/**
		 * Invokes service to renew session and complete pending request. 
		 * @param user CouchUser
		 * @param pendingCommand IRequestCommand The pending command to execute after successful renewal.
		 * @return IRequestCommand
		 */
		public function createRenewRequest( user:CouchUser ):IRequestCommand
		{
			// Request new session cookie.
			return _service.createSession( user, new CreateSessionResponder( handleRenewResult, handleServiceFault ) );
		}
		
		/**
		 * Invokes service to create a new session based on user credentials. 
		 * @param user CouchUser
		 */
		public function doCreate( user:CouchUser ):void
		{
			_service.createSession( user, new CreateSessionResponder( handleServiceResult, handleServiceFault ) ).execute();
		}
	}
}