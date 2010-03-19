/**
 * <p>Original Author: toddanderson</p>
 * <p>Class File: CouchModelEntity.as</p>
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
package com.custardbelly.as3couchdb.core
{	
	import com.custardbelly.as3couchdb.mediator.IServiceMediator;
	import com.custardbelly.as3couchdb.service.ICouchRequest;
	
	import flash.errors.IllegalOperationError;
	import flash.utils.describeType;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;

	/**
	 * CouchModelEntity handles parsing annotated metadata related to the CouchDB database instance. 
	 * @author toddanderson
	 */
	public class CouchModelEntity
	{
		protected var _baseUrl:String;
		protected var _databaseName:String;
		protected var _mediator:IServiceMediator;
		
		/**
		 * Constructor. 
		 * @param baseUrl String
		 * @param databaseName String
		 */
		public function CouchModelEntity( baseUrl:String, databaseName:String, mediator:IServiceMediator )
		{
			_baseUrl = baseUrl;
			_databaseName = databaseName;
			_mediator = mediator;
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
		 * Returns the IServiceMediator implementation to use in communication between service and model. 
		 * @return IServiceMediator
		 */
		public function get mediator():IServiceMediator
		{
			return _mediator;
		}
		
		/**
		 * Throw a RTE if model is not validly annotated wit DocumentService and ServiceMediator.
		 * @param className String The model class name that is missing metadata.
		 * @param annotationType String The missing annotation type.
		 */
		private static function throwErrorForAnnotation( className:String, annotationType:String ):void
		{
			throw new IllegalOperationError( "The CouchModel instance [" + className + "] must be annotated with [" + annotationType + "] metadata tag." );
		}
		
		/**
		 * Parses metadata held on the target CouchModel instance and returns a new CouchModelEntity instance.
		 * @throws IllegalOperationError IllegalOperationError if required metadata is not found. 
		 * @param model CouchModel The target CouchModel instance to obtain required metadata information from with regards to the base url and database name of CouchDB instance.
		 * @return CouchModelEntity
		 */
		public static function parse( model:CouchModel ):CouchModelEntity
		{
			// Get class manifest
			var xml:XML = describeType( model );
			
			// Parse DocumentService
			var serviceNode:XMLList = xml.metadata.(@name == "DocumentService");
			// If not metadata available, throw RTE.
			if( serviceNode.length() == 0 ) throwErrorForAnnotation( getQualifiedClassName(model), "DocumentService" );
			// Else establish document service values.
			var url:String = serviceNode.arg.(@key=="url").@value;
			var name:String = serviceNode.arg.(@key=="name").@value;
			
			// Parse ICouchRequest implementation.
			var request:ICouchRequest;
			// Do not throw RTE is no request type added. Default is used as CouchRequest.
			var requestNode:XMLList = xml.metadata.(@name == "RequestType");
			if( requestNode.length() == 1 )
			{
				var requestClass:Class = getDefinitionByName( requestNode.arg.(@key=="name").@value ) as Class;
				request = new requestClass() as ICouchRequest;
			}
			
			// Parse ServiceMediator
			var mediatorNode:XMLList = xml.metadata.(@name == "ServiceMediator");
			// If not metadata available for mediator, throw RTE
			if( mediatorNode.length() == 0 ) throwErrorForAnnotation( getQualifiedClassName(model), "ServiceMediator" );
			// Else create a new instance of the mediator.
			var mediatorClass:Class = getDefinitionByName( mediatorNode.arg.(@key=="name").@value ) as Class;
			var mediator:IServiceMediator = new mediatorClass() as IServiceMediator;
			mediator.initialize( model, url, name, request );
			
			// Pass back a new entity.
			return new CouchModelEntity( url, name, mediator );
		}
	}
}