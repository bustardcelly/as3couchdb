/**
 * <p>Original Author: toddanderson</p>
 * <p>Class File: UUID.as</p>
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
package com.custardbelly.as3couchdb.util
{
	import com.hurlant.crypto.hash.IHash;
	import com.hurlant.crypto.hash.SHA1;
	import com.hurlant.crypto.hash.SHA256;
	
	import flash.utils.ByteArray;

	/**
	 * UUID is a utility class to generate a unique id to be used whe creating and saving a document to a CouchDB instance. 
	 * @author toddanderson
	 */
	public class UUID
	{
		/**
		 * @private
		 * 
		 * Creates a hash string based on supplied hash algorithm. 
		 * @param str String
		 * @param hashBase IHash
		 * @return String
		 */
		private static function stringHash( str:String, hashBase:IHash ):String
		{
			var bytes:ByteArray = new ByteArray();
			bytes.writeUTFBytes( ( new Date().time.toString() + "@" + str ).toString() + "-" + Math.random().toString() );
			bytes.position = 0;
			
			var hash:ByteArray = hashBase.hash( bytes );
			hash.position = 0;
			
			var uid:String = "";
			while( hash.position < hash.bytesAvailable )
				uid += hash.readUnsignedInt().toString(16);
			
			return uid;
		}
		
		/**
		 * Generates a SHA256 hash unique id to be used in document creation. 
		 * @param url String The base url used within the hash.
		 * @return String
		 */
		public static function generate( url:String ):String
		{
			return stringHash( url, new SHA256() );
		}
		
		/**
		 * Generates a SHA1 hash unique id to be used in document creation. 
		 * @param url String The base url used within the hash.
		 * @return String
		 */
		public static function generateSHA1( url:String ):String
		{
			return stringHash( url, new SHA1() );
		}
	}
}