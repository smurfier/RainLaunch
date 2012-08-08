===== Built In Functions =====
Web
	Autocompletes web addresses.
	All spaces are substituted for %20 on execution in order to ensure compatibility.
	
	Single word completes to: http://wwww.first.com
	Double word completes to: http://www.first.second
	Tripple word completes to: http://first.second.third
	
	Use:
		Web rainmeter.net
	
Calc
	Executes Rainmeter style calculations.
	Used by placing a equal sign before a matematical statement.
	Outputs to the skin window. Right-click on the results to copy to the clipboard.
	
	Use:
		=SQRT(9)
	
===== Defining Search Engines ===
Search engines are defined in the [Search] section of Run.cfg
The name of the Search must be a single word.
All spaces in the User Input are substituted for %20 on execution in order to ensure compatibility.

	Example:
		Google="http://google.com/search?q=\1"

	Use:
		Google Search Term
	
===== Defining Macros =====
Macros are defined in the [Macros] section of Run.cfg
The name of a macro may not contain a space as Run.cfg follows the INI formatting rules.

Simple macros are defined by a name and an action.

	Example:
		forum=http://rainmeter.net/forum

	Use:
		Forum
	
User input functions are defined the same as simple macros.
Placing \N denotes where the user input is placed. N is a number denoting a parameter. Up to 9 parameters can be specified.

	Example:
		copy=!SetClip """\1"""

In order to define a list of possible inputs, place the pipe delimited list inside of curly brackets after the input number.
Lua pattern matching may also be used in input lists to validate the input. Only lower case pattern matching characters may be used.
If a colon is placed in the first parameter in the list, everything before the colon is used to substitute the spaces in the user input.

	Example:
		music=!CommandMeasure NowPlaying "\1{Play|Pause|Next|Previous|SetVolume [%+%-]?%d+|SetPosition [%+%-]?%d+}"
		test=!Log "\1{&:}"

Spaces are used between parameters with the end being concatenated for the final parameter.
Spaces are preserved in user input functions.
	
	Use:
		Copy Some Text
		Music SetVolume +10

		
===== Built-In Commands =====
In the list of commands below, parameters enclosed by [square brackets] indicate required parameters. Parameters enclosed in (normal brackets) indicate optional parameters. When parameters may contain spaces, enclose them with quotes.

!WriteToFile [File] [Text] (Match)
	Writes a line to the end of a file. Quotes are required for parameters using spaces. If the file has contents, a new line is created.
	If Match is specified, the Text is placed before the first instance of the string Match in the file. If Match is not found, the Text is placed at the end of the file.
	Match must follow all the rules of Lua pattern matching. Only lower case pattern matching characters may be used.

	
===== Known Limitiations =====

Using quotes in user input may cause unexpected results.

With the current implementation of Lua, the use of Unicode characters is unwise.