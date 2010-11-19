/**
 * <p>Original Author: toddanderson</p>
 * <p>Class File: ReadUserResponder.as</p>
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
	
	/**
	 * ReadUserResponder handles updating a CouchUser model based on the result of a transaction involving that User in a CouchDB instance. 
	 * @author toddanderson
	 */
	public class ReadUserResponder extends AbstractUserResponder
	{
		protected var _action:String;
		private static const ADMIN_ROLE_KEY:String = "_admin";
		
		/**
		 * Constructor. 
		 * @param user CouchUser
		 * @param action String
		 * @param responder ICouchServiceResponder
		 */
		public function ReadUserResponder( user:CouchUser, action:String, responder:ICouchServiceResponder )
		{
			super(user, responder);
			_action = action;
		}
		
		/**
		 * @private
		 * 
		 * Returns flag of user being of role _admin. If this is the case and the _admin is not an entry into _users, than a read request may fail.
		 * If the fail on _admin read is detecting, it is concidered OK. 
		 * @param user CouchUser
		 * @return Boolean Boolean
		 */
		protected function userIsAdmin( user:CouchUser ):Boolean
		{
			return ( user.roles && ( user.roles.indexOf( ADMIN_ROLE_KEY ) != -1 ) );
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function handleAsResultError( value:CouchServiceResult ):Boolean
		{
			var result:Object = value.data;
			if( _reader.isResultAnError( result ) )
			{
				// Check if user is admin. If so, they may not have a record in _users and it is okay.
				if( userIsAdmin( _user ) )
				{
					return false;
				}
				else
				{
					handleFault( new CouchServiceFault( result["error"], 0, result["reason"] ) );	
				}
				return true;
			}
			return false;	
		}						
		
		/**
		 * @inheritDoc
		 */
		override public function handleResult( value:CouchServiceResult ):void
		{
			if( !handleAsResultError( value ) )
			{
				// update target document based on result.
				_reader.updateFromRead( _user, value.data, userIsAdmin( _user ) );
				if( _responder ) _responder.handleResult( new CouchServiceResult( _action, _user ) );
			}
		}
		
		/**
		 * @inheritDoc
		 */
		override public function handleFault( value:CouchServiceFault ):void
		{
			// Just as if we receieved a result with an error object of missing document,
			//	here we treat a 404 on read for an admin as OK. There is not necessarily going to be a _user entry for an admin,
			//	which results in 404 or object_not_found error when trying to read an _admin role.
			var isAdminDocRequestFault:Boolean = ( userIsAdmin( _user ) && value.status == 404 );
			if( _responder )
			{
				if( isAdminDocRequestFault )
				{
					_responder.handleResult( new CouchServiceResult( _action, _user ) );
				}
				else
				{
					_responder.handleFault( value );
				}
			}
		}
	}
}