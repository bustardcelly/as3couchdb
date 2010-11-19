/**
 * <p>Original Author: toddanderson</p>
 * <p>Class File: CouchUser.as</p>
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
package com.custardbelly.as3couchdb.core
{
	import com.custardbelly.as3couchdb.mediator.ICouchUserActionMediator;

	/**
	 * Dispatched upon successful create of a user instance in CouchDB. 
	 */
	[Event(name="create", type="com.custardbelly.as3couchdb.enum.CouchActionType")]
	/**
	 * Dispatched upon successful update of a user instance in CouchDB. 
	 */
	[Event(name="update", type="com.custardbelly.as3couchdb.enum.CouchActionType")]
	/**
	 * Dispatched upon successful login of a user in CouchDB.
	 */
	[Event(name="login", type="com.custardbelly.as3couchdb.enum.CouchActionType")]
	/**
	 * Dispatched upon successful logout of a user in CouchDB. 
	 */
	[Event(name="logout", type="com.custardbelly.as3couchdb.enum.CouchActionType")]
	/**
	 * Dispatched upon fault from create of user session. 
	 */
	[Event(name="fault", type="com.custardbelly.as3couchdb.event.CouchEvent")]
	/**
	 * CouchUser is a generic user class mainly for use with session authentication. 
	 * @author toddanderson
	 */
	public class CouchUser extends CouchModel
	{
		public var name:String;
		public var password:String;
		
		protected var _id:String;
		protected var _revision:String;
		protected var _salt:String;
		protected var _password_sha:String;
		protected var _type:String;
		protected var _roles:Array;
		
		protected var _actionMediator:ICouchUserActionMediator;
		
		/**
		 * Constuctor.
		 * @param name String Default to null to allow for serialization.
		 * @param password String Default to null to allow for serialization.
		 * @param entity CouchModelEntity Custom CouchModelEntity to replace any possible annotated properties for this model.
		 */
		public function CouchUser( name:String = null, password:String = null, entity:CouchModelEntity = null )
		{
			super( entity );
			this.name = name;
			this.password = password;
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function commitEntity( oldEntity:CouchModelEntity, newEntity:CouchModelEntity ):void
		{
			super.commitEntity( oldEntity, newEntity )
			_actionMediator = _mediator as ICouchUserActionMediator;
		}
		
		/**
		 * Resigesters/signs-up a user in the CouchDB instance. *Roles can only be assigned when currently in a session as an admin.
		 * @param roles Array An array of string values representing roles associated with the user.
		 */
		public function signUp( roles:Array /* String[] */ = null ):void
		{
			_actionMediator.doSignUp( name, password, roles );	
		}
		
		/**
		 * Invokes service to log a user in and create an authenticated session.
		 */
		public function login():void
		{
			_actionMediator.doLogIn( name, password );	
		}
		
		/**
		 * Invokes service to log a user out and close an authenticated session.
		 */
		public function logout():void
		{
			_actionMediator.doLogOut();
		}
		
		/**
		 * Invokes the action mediator to save this document instance to the CouchDB database.
		 */
		public function update():void
		{
			_actionMediator.doSave();
		}

		/**
		 * Returns the CouchDB id of the user. 
		 * @return String
		 */
		public function get id():String
		{
			return _id;
		}
		public function set id(value:String):void
		{
			_id = value;
		}

		/**
		 * Returns the revision number of this User. A User in CouchDB is considered very similar to a document. 
		 * @return String
		 */
		public function get revision():String
		{
			return _revision;
		}
		public function set revision(value:String):void
		{
			_revision = value;
		}
		
		/**
		 * Returns the salt used in encrypting password. This is created upon signup and stored in _users in the CouchDB instance. 
		 * You should not need to modfy this property. It is exposed in order to update this User document upon read, and used for update. 
		 * @return String
		 */
		public function get salt():String
		{
			return _salt;
		}
		public function set salt( value:String ):void
		{
			_salt = value;
		}
		
		/**
		 * Returns the salted password. This is created upon signup and stored in _users in the CouchDB instance. 
		 * You should not need to modfy this property. It is exposed in order to update this User document upon read, and used for update. 
		 * @return String
		 */
		public function get password_sha():String
		{
			return _password_sha;
		}
		public function set password_sha( value:String ):void
		{
			_password_sha = value;
		}

		/**
		 * Returns the type of User. 
		 * @return String
		 */
		public function get type():String
		{
			return _type;
		}
		public function set type(value:String):void
		{
			_type = value;
		}

		/**
		 * Returns a list of roles associated with the user in the CouchDB instance. 
		 * @return Array An Array of String.
		 */
		public function get roles():Array
		{
			return _roles;
		}
		public function set roles(value:Array):void
		{
			_roles = value;
		}
	}
}