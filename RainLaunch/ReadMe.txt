===== Built In Functions =====
Web
	Autocompletes web addresses.
	Single word completes to: http://wwww.first.com
	Double word completes to: http://www.first.second
	Tripple word completes to: http://first.second.third
	
	Use:
		Web rainmeter.net
	
Calc
	Executes Rainmeter style calculations.
	Outputs to the skin window. Right-click on the results to copy to the clipboard.
	
	Use:
		Calc SQRT(9)
	
===== Defining Search Engines ===
Search engines are defined in the [Search] section of Run.cfg
The name of the Search must be a single word.
All spaces in the UserInput are substituted for %20 on execution in order to ensure compatibility.

	Example:
		Google="http://google.com/search?q=$UserInput$"

	Use:
		Google Search Term
	
===== Defining Macros =====
Macros are defined in the [Macros] section of Run.cfg

Simple macros are defined by a name and an action.

	Example:
		forum=http://rainmeter.net/forum

	Use:
		Forum
	
User input functions are defined the same as simple macros.
placing \N denotes where the user input is places. N is actually a number denoting a parameter. Up to 9 parameters can be specified.
Spaces are preserved in user input functions.

	Example:
		copy=!SetClip """\1"""
	
	Use:
		Copy Some Text