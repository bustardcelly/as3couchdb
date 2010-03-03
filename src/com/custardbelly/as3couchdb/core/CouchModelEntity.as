/**
 * <p>Original Author: toddanderson</p>
 * <p>Class File: CouchModelEntity.as</p>
 * <p>Version: 0.1</p>
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
	import flash.errors.IllegalOperationError;
	import flash.utils.describeType;
	import flash.utils.getQualifiedClassName;

	/**
	 * CouchModelEntity handles parsing annotated metadata related to the CouchDB database instance. 
	 * @author toddanderson
	 */
	public class CouchModelEntity
	{
		protected var _baseUrl:String;
		protected var _databaseName:String;
		
		/**
		 * Constructor. 
		 * @param baseUrl String
		 * @param databaseName String
		 */
		public function CouchModelEntity( baseUrl:String, databaseName:String )
		{
			_baseUrl = baseUrl;
			_databaseName = databaseName;
		}
		
		/**
		 * Returns the base url of the CouchDB instance. 
		 * @return String
		 */
		public function get baseUrl():String
		{
			return _baseUrl;
		}
		
		/**
		 * Returns the database name residing in the CouchDB instance. 
		 * @return String
		 */
		public function get databaseName():String
		{
			return _databaseName;
		}
		
		/**
		 * Parses metadata held on the target CouchModel instance and returns a new CouchModelEntity instance.
		 * @throws IllegalOperationError IllegalOperationError if required metadata is not found. 
		 * @param model CouchModel The target CouchModel instance to obtain required metadata information from with regards to the base url and database name of CouchDB instance.
		 * @return CouchModelEntity
		 */
		public static function parse( model:CouchModel ):CouchModelEntity
		{
			var xml:XML = describeType( model );
			var serviceNode:XMLList = xml.metadata.(@name=="DocumentService");
			// If not metadata available, throw RTE.
			if( serviceNode.length() == 0 )
			{
				throw new IllegalOperationError( "The CouchModel instance [" + getQualifiedClassName(model) + "] must be annotated with [DocumentService] metadata tag." );	
			}
			// Else create new instance of CouchEntityModel.
			var url:String = serviceNode.arg.(@key=="url").@value;
			var name:String = serviceNode.arg.(@key=="name").@value;
			return new CouchModelEntity( url, name );
		}
	}
}