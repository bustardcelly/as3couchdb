/**
 * <p>Original Author: toddanderson</p>
 * <p>Class File: CouchUserActionMediator.as</p>
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
	import com.custardbelly.as3couchdb.responder.CreateUserResponder;
	import com.custardbelly.as3couchdb.responder.DeleteSessionResponder;
	import com.custardbelly.as3couchdb.responder.ICouchServiceResponder;
	import com.custardbelly.as3couchdb.responder.ReadUserResponder;
	import com.custardbelly.as3couchdb.responder.UpdateUserResponder;
	import com.custardbelly.as3couchdb.service.CouchService;
	import com.custardbelly.as3couchdb.service.CouchUserService;
	import com.custardbelly.as3couchdb.service.ICouchRequest;
	import com.custardbelly.as3couchdb.service.ICouchService;
	import com.custardbelly.as3couchdb.service.ICouchUserService;

	/**
	 * CouchUserActionMediator is a mediattor between the service and client to handle response on change to creation of user and login/logout of session.
	 * @author toddanderson
	 */
	public class CouchUserActionMediator implements ICouchUserActionMediator
	{
		protected var _user:CouchUser;
		protected var _sessionService:ICouchService;
		protected var _userService:ICouchUserService;
		protected var _signUpReadResponder:ICouchServiceResponder;
		protected var _loginResponder:ICouchServiceResponder;
		protected var _logoutResponder:ICouchServiceResponder;
		protected var _serviceResponder:ICouchServiceResponder;
		
		/**
		 * Constructor.
		 */
		public function CouchUserActionMediator() {}
		
		/**
		 * Initializes the mediator to establish the service in which to communicate actions related to the target model. 
		 * @param target CouchModel
		 * @param baseUrl String
		 * @param databaseName String
		 * @param request ICouchRequest The ICouchRequest implmementation to forward requests through.
		 */
		public function initialize( target:CouchModel, baseUrl:String, databaseName:String, request:ICouchRequest=null ):void
		{
			_user = target as CouchUser;
			_sessionService = CouchService.getSessionService( baseUrl, request );
			_userService = CouchUserService.getUserService( baseUrl, request );
			_signUpReadResponder = new BasicCouchResponder( handleSignUpReadResult, handleServiceFault );
			_loginResponder = new BasicCouchResponder( handleLoginResult, handleServiceFault );
			_logoutResponder = new BasicCouchResponder( handleLogoutResult, handleServiceFault );
			_serviceResponder = new BasicCouchResponder( handleServiceResult, handleServiceFault );
		}
		
		/**
		 * @inheritDoc
		 */
		public function dispose():void
		{
			_user = null;
			_userService = null;
			_signUpReadResponder = null;
			_loginResponder = null;
			_logoutResponder = null;
			_serviceResponder = null;
			// Kill session.
			var session:CouchSession = _sessionService.getSession();
			if( session ) session.clear();
			_sessionService = null;
		}
		
		/**
		 * @private
		 * 
		 * Responder method for a successful service operation. 
		 * @param result CouchServiceResult
		 */
		protected function handleServiceResult( result:CouchServiceResult ):void
		{
			// Dispatch the event through the database instance.
			if( result.action ) _user.dispatchEvent( new CouchEvent( result.action, result ) );
		}
		
		/**
		 * @private
		 * 
		 * Responder method for a fault in service operation. 
		 * @param fault CouchServiceFault
		 */
		protected function handleServiceFault( fault:CouchServiceFault ):void
		{
			// Dispatch the event through the database instance.
			_user.dispatchEvent( new CouchEvent( CouchEvent.FAULT, fault ) );
		}
		
		/**
		 * @private
		 * 
		 * Responder for read in of user after signup. Forwards on to update the user with custom fields. 
		 * @param result CouchServiceResult
		 */
		protected function handleSignUpReadResult( result:CouchServiceResult ):void
		{
			var saveResponder:ICouchServiceResponder = new UpdateUserResponder( _user, CouchActionType.UPDATE, _serviceResponder );
			_userService.updateUser( _user, saveResponder ).execute();
			handleServiceResult( result );
		}
		
		/**
		 * @private
		 * 
		 * Response handler fro successful login of user. Instantiates new session.
		 * @param result CouchServiceResult
		 */
		protected function handleLoginResult( result:CouchServiceResult ):void
		{
			var response:CouchSessionResponse = result.data as CouchSessionResponse;
			var cookie:String = response.cookie;
			// Update session.
			var session:CouchSession = _sessionService.getSession();
			session.user = _user;
			session.cookie = cookie;
			// No dispatch as a successful login with trigger a read to fill User document.
		}
		
		/**
		 * @private
		 * 
		 * Response handler for successful logout of user. Closes session. 
		 * @param result CouchServiceResult
		 */
		protected function handleLogoutResult( result:CouchServiceResult ):void
		{
			var session:CouchSession = _sessionService.getSession();
			session.clear();
			_user.dispatchEvent( new CouchEvent( result.action, result ) );
		}
		
		/**
		 * @copy ICouchUserActionMediator#doSignUp()
		 */
		public function doSignUp( name:String, password:String, roles:Array=null ):void
		{
			// The CouchDB API does not allow you to pass a User JSON object when signing up.
			// As such, since our models can have more properties we need to signup, read back to get value and save as update.
			var signUpResponder:ICouchServiceResponder = new CreateUserResponder( _user, CouchActionType.CREATE, _serviceResponder );
			var signUpCommand:IRequestCommand = _sessionService.signUp( name, password, roles, signUpResponder );
			var readResponder:ICouchServiceResponder = new ReadUserResponder( _user, null, _signUpReadResponder );
			var readRequestCommand:IRequestCommand = _userService.readUser( _user, readResponder );
			signUpCommand.nextCommand = readRequestCommand;
			signUpCommand.ceaseOnFault = true;
			signUpCommand.execute();
		}
		/**
		 * @copy ICouchUserActionMediator#doLogIn()
		 */
		public function doLogIn( name:String, password:String ):void
		{
			// Create responder for creation operation with basic responder.
			var createResponder:ICouchServiceResponder = new CreateSessionResponder( _user, null, _loginResponder );
			var readResponder:ICouchServiceResponder = new ReadUserResponder( _user, CouchActionType.LOGIN, _serviceResponder );
			var loginRequestCommand:IRequestCommand = _sessionService.logIn( name, password, createResponder );
			var readRequestCommand:IRequestCommand = _userService.readUser( _user, readResponder );
			loginRequestCommand.nextCommand = readRequestCommand;
			loginRequestCommand.ceaseOnFault = true;
			loginRequestCommand.execute();
		}
		/**
		 * @copy ICouchUserActionMediator#doLogOut()
		 */
		public function doLogOut():void
		{
			var readResponder:ICouchServiceResponder = new DeleteSessionResponder( _user, CouchActionType.LOGOUT, _logoutResponder );
			_sessionService.logOut( _user, readResponder ).execute();
		}
		
		/**
		 * @copy ICouchUserActionMediator#doSave()
		 */
		public function doSave():void
		{
			var readResponder:ICouchServiceResponder = new UpdateUserResponder( _user, CouchActionType.UPDATE, _serviceResponder );
			_userService.updateUser( _user, readResponder ).execute();
		}
	}
}