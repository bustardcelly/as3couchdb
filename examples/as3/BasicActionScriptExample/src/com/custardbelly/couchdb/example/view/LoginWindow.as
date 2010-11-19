package com.custardbelly.couchdb.example.view
{
	import com.bit101.components.Label;
	import com.bit101.components.PushButton;
	import com.bit101.components.Text;
	import com.bit101.components.Window;
	import com.custardbelly.as3couchdb.core.CouchUser;
	import com.custardbelly.muwl.event.LoginEvent;
	import com.custardbelly.muwl.model.MUWLUser;
	
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	
	[Event(name="login", type="com.custardbelly.muwl.event.LoginEvent")]
	public class LoginWindow extends Window
	{
		protected var _usernameField:Text;
		protected var _passwordField:Text;
		
		public static const LOGIN:String = "login";
		
		public function LoginWindow( parent:DisplayObjectContainer=null, xpos:Number=0, ypos:Number=0, title:String="login" )
		{
			super( parent, xpos, ypos, title );
			draggable = false;
			createChildren();
			
			setSize( 200, 150 );
			x = ( parent.stage.stageWidth - width ) / 2;
			y = ( parent.stage.stageHeight - height ) / 2;
		}
		
		protected function createChildren():void
		{
			new Label( content, 10, 10, "username" );
			_usernameField = new Text( content, 10, 26, "" );
			_usernameField.width = 180;
			_usernameField.height = 20;
			
			new Label( content, 10, 55, "password" );
			_passwordField = new Text( content, 10, 71, "" );
			_passwordField.width = 180;
			_passwordField.height = 20;
			
			var btn:PushButton = new PushButton( content, 50, 100, "login", handleLoginClick );
		}
		
		protected function handleLoginClick( evt:Event ):void
		{
			dispatchEvent( new LoginEvent( new MUWLUser( _usernameField.text, _passwordField.text ) ) );
		}
		
		public function get username():String
		{
			return _usernameField.text;
		}
		public function set username( value:String ):void
		{
			_usernameField.text = value;
		}
		
		public function get password():String
		{
			return _passwordField.text;
		}
		public function set password( value:String ):void
		{
			_passwordField.text = value;
		}
	}
}