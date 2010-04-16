/**
 * <p>Original Author: toddanderson</p>
 * <p>Class File: ICouchDatabaseReader.as</p>
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
package com.custardbelly.as3couchdb.serialize
{
	import com.custardbelly.as3couchdb.core.CouchDatabase;

	/**
	 * ICouchDatabaseReader interprets service result and applied attributes to database objects. 
	 * @author toddanderson
	 */
	public interface ICouchDatabaseReader
	{
		/**
		 * Returns flag if successful result is interpreted as an error from the service. 
		 * @param result Object
		 * @return Boolean
		 */
		function isResultAnError( result:Object ):Boolean
		/**
		 * Applies attributes to specified CouchDatabase based on interpreted result. 
		 * @param database CouchDatabase
		 * @param result Object
		 */
		function updateFromResult( database:CouchDatabase, result:Object ):void;
		/**
		 * Returns a list of document objects based on the result. 
		 * @param result Object
		 */
		function getDocumentListFromResult( result:Object ):Array;
	}
}