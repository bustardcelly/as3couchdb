/**
 * <p>Original Author: toddanderson</p>
 * <p>Class File: IServiceMediator.as</p>
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
	import com.custardbelly.as3couchdb.core.CouchModel;
	import com.custardbelly.as3couchdb.service.ICouchRequest;

	/**
	 * IServiceMediator is a base mediator class representing a middle tier in communication between a CouchModel 
	 * instance and the CouchDB service. 
	 * @author toddanderson
	 */
	public interface IServiceMediator
	{
		/**
		 * Initializes mediator to establish service on which to communicate actions related to target model. 
		 * @param target CouchModel
		 * @param baseUrl String
		 * @param databaseName String
		 */
		function initialize( target:CouchModel, baseUrl:String, databaseName:String, request:ICouchRequest = null ):void;
		/**
		 * Disposes the meditaing session associated with this instance.
		 */
		function dispose():void;
	}
}