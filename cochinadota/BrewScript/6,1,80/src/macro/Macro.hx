package macro;

import haxe.macro.Context;

class Macro
{
	macro
	public static function initiateMacro() 
	{
		Context.fatalError('error', (macro null).pos);
		return macro {}
	}
}