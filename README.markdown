# License

See the accompanying LICENSE file.

# About

as3couchdb is an ActionScript 3 clientside API for interacting with a CouchDB instance.

as3couchdb at its core is a library to perform CRUD requests on a CouchDB instance. There are two basic entities
on which these requests are made - Database and Document - though the library includes making ancillary request
on the CouchDB instance itself as well (such as listing all available databases).

as3couchdb aims to address performing CRUD requests with ease by exposing correlating methods on the models for
Database and Document directly. To resolve this goal, custom metadata is required for these models that relate
to the url of the CouchDB instance, the database name, the target mediating class between the model and the service,
and the base request instance that communicates with the service. These are explained in futher detail within the Usage section.

# Requirements

The following libraries are required to compile the as3couchdb library project:

## as3corelib

The as3couchdb library requires the as3corelib project (found at [http://code.google.com/p/as3corelib/]http://code.google.com/p/as3corelib/)).
The classes from the as3corelib project that as3couchdb utilizes is SHA1 for generating unique ids
on the client side, and JSON for serializing objects for CouchDB service communication.

## as3httpclient

The as3couchdb library requires the as3httpclient project (found at [http://code.google.com/p/as3httpclientlib](http://code.google.com/p/as3httpclientlib)).
as3couchdb utilizes the as3httpclient API to make proper PUT and DELETE requests on the CouchDB instance.
as3httpclient has a dependency on the following libraries: as3corelib and as3crypto.

## as3crypto

The as3crypto library is used by the as3httpclient (see above requirement).
as3crypt can be found at [http://code.google.com/p/as3crypto/](http://code.google.com/p/as3crypto/)

# Usage 

At the core of as3couchdb are models representing two basic entities within a CouchDB instance - 
a Database and a Document. A CouchDB instance can hold many Databases and Databases can hold many Documents.
In as3couchdb, these entity models have their own methods for performing CRUD requests on a CouchDB instance.
As such, the CouchDatabase and CouchDocument classes require custom metadata to perform these requests.
The required annotation are as follows:

## DocumentService

The DocumentService metadata declares to the url of the CouchDB and the target Database name.
In the following example, the url points to the localhost at port 5984 (the default for CouchDB)
and the database 'contacts'. Any requests made will be perfomed on the 'contacts' database at the CouchDB location.

    [DocumentService(url="http://127.0.0.1:5984", name="contacts")]

## ServiceMediator

The ServiceMediator metadata declares the mediating class between a model and the service. The CouchDatabase
and CouchDocument models calls methods on this mediator to make CRUD requests.
 
    [ServiceMediator(name="com.custardbelly.as3couchdb.mediator.CouchDatabaseActionMediator")]

## RequestType

The RequestType metadata delcares the interfacing request class with the service. The ICouchRequest implementation
is handed to the ServiceMediator in order to establish the proper handling of requests from the service.
The main purpose of the RequestType is to handle multiple runtimes and there URLRequest restrictions.
The Flash Player for AIR supports PUT and DELETE requests, but such requests are not available in the web-based
Flash Player. As such, HTTPCouchRequest is available in as3couchdb and uses the as3httpclient library to make the
requests over a socket. Other implementations are ExInCouchRequest which uses ExternalInterface.

    [RequestType(name="com.custardbelly.as3couchdb.service.HTTPCouchRequest")]

The CouchDatabase and CouchDocument models extend CouchModel which uses a CouchModelEntity to parse these annotations
and wire the models up to perform requests by calling methods on the model themselves.

The models are extensions to EventDispatcher and the ServiceMediator handles dispatching the appropriate events
related to response from the CouchDB service. You can listen for these corresponding CRUD events on the models as well
as basic result and fault events.

## Sessions ##
Additionaly there is another model to be used as a persistant session: CouchSession. The use of the session enforces
more security when making service request on the CouchDB by establishing a session based on a cookie returned on user 
credentials.

# Examples #

To start off, you would create custom models in your application that extend CouchDatabase and CouchDocument.

The following is an example of a custom CouchDatabase model:

    [DocumentService(url="http://127.0.0.1:5984", name="contacts")]
    [ServiceMediator(name="com.custardbelly.as3couchdb.mediator.CouchDatabaseActionMediator")]
    [RequestType(name="com.custardbelly.as3couchdb.service.HTTPCouchRequest")]
    public class ContactDatabase extends CouchDatabase
    {
      public function ContactDatabase()
      {
        super();
      }
    }

The following is an example of a custom CouchDocument model:
    
    [DocumentService(url="http://127.0.0.1:5984", name="contacts")]
    [ServiceMediator(name="com.custardbelly.as3couchdb.mediator.CouchDocumentActionMediator")]
    [RequestType(name="com.custardbelly.as3couchdb.service.HTTPCouchRequest")]
    	
    [Bindable]
    public class ContactDocument extends CouchDocument
    {
    	public var firstName:String;
    	public var lastName:String;
    	public var email:String;
    	
    	public function ContactDocument()
    	{
    		super();
    	}
    }

The following is an example of a CouchSession model:
  
    [DocumentService(url="http://127.0.0.1:5984", name="contacts")]
    [ServiceMediator(name="com.custardbelly.as3couchdb.mediator.CouchSessionActionMediator")]
    [RequestType(name="com.custardbelly.as3couchdb.service.HTTPSessionRequest")]
    public class ContactSession extends CouchSession
    {
    	public function ContactSession()
    	{
    		super();
    	}
    }

The following is an example of accessing all the documents within the ContactDatabase:
  
    var database:CouchDatabase = new ContactDatabase();
    database.addEventListener( CouchActionType.CREATE, handleCouchDatabaseReady );
    database.createIfNotExist();
    
    private function handleCouchDatabaseReady( evt:CouchEvent ):void
    {
    	database.addEventListener( CouchActionType.READ_ALL, handleReadAllDocuments );
    	// Pass the class type to resolve payload documents to.
    	database.getAllDocuments( "com.custardbelly.couchdb.model.ContactDocument" );
    }
    		
    private function handleReadAllDocuments( evt:CouchEvent ):void
    {
    	database.removeEventListener( CouchActionType.READ_ALL, handleReadAllDocuments );
    	
    	var contacts:ArrayCollection = new ArrayCollection();
    	var contactList:Array = ( evt.data as CouchServiceResult ).data as Array;
    	var i:int = contactList.length;
    	while( --i > -1 )
    	{
    		contacts.addItem( contactList[i] );
    	}
    }

To create a new document in CouchDatabase:

    var contact:ContactDocument = new ContactDocument();
    contact.firstName = firstNameField.text;
    contact.lastName = lastNameField.text;
    contact.email = emailField.text;
    contact.addEventListener( CouchActionType.CREATE, handleContactSave );
    contact.addEventListener( CouchEvent.FAULT, handleContactFault );
    contact.create();

The create() method is used for Create and Update. The read() method Reads the document from the
database and populates the model. The update() method saves any changes to the database instance.
The remove() method Deletes the document from the database.

Additionally, you an add security by establishing a session. The CouchSession model handles
interacting with the service through a mediator to request a cookie to use fro each subsequent request.
Once a session is started, it is assumed under the hood that any following requests are made against a 
certain user session.

To start a session, such as requesting a user to log in to begin making requests to the CouchDB instance based
on a session cookie:

    var session:CouchSession = new ContactSession();
    session.addEventListener( CouchActionType.SESSION_CREATE, handleSessionCreate );
    session.create( new CouchUser( username, password ) );

Any subsequent request on documents and databases will be based on the current session. as3couchdb handles renewing
a session after a defined time lapse (the default time lapse for CouchDB is 10 minutes. This can be modified in the CouchDB instance).
