===== Built In Functions =====
Web
	Autocompletes web addresses.
	Single word completes to: http://wwww.first.com
	Double word completes to: http://www.first.second
	Tripple word completes to: http://first.second.third
	
Calc
	Executes Rainmeter style calculations.
	Outputs to the skin window. Right-click on the results to copy to the clipboard.
	
===== Defining Search Engines ===
Search engines are defined in the [Search] section of Run.cfg
All spaces are substituted for %20 on execution in order to ensure compatibility.

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
	
User input functions are defined the same as simple macros, placing $UserInput$ where the user input needs to be placed.
Spaces are preserved in macro functions.

	Example:
		copy=!SetClip """$UserInput$"""
	
	Use:
		Copy Some Text