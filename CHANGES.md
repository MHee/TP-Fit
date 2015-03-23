# Changes

## Version 1.1
First version to support the new Antares temperature-logger based SET2 tool data.

### New features
* Moved code from [SourceForge](http://sourceforge.net/projects/tp-fit/) to [GitHub](https://github.com/MHee/TP-Fit) to simplify maintenance.
* Added tool database that allows to attach tool and model types to individual Antares tools depending on their serial number.
* Changed meta-data window so that tool and model type is now shown in a deactivated dropdown menu.
* Added dialog to let user decide and save if new Antares tool is ADCP-3 or SET2 tool.
* Updated documentation.

### Bug fixes
* Fixed warnings of recent Matlab versions that "cubic" in interp1 will change in the future and that it should be replaced by "pchip".
* Made main TP-Fit menu bar window resizable to fix problems on high-res screens.
* Fixed main menu window, so that meta-data button only turns green after the meta-data was actually reviewed.


## Version 1.0
First official release used by IODP.
This version is accessible at [GitHub](https://github.com/MHee/TP-Fit/releases/tag/v1.0).
       
## Version 0.2
* Added version info / help
* Improved results plots
	1.   Reduced use of color (red/green)
	2.   Clearer presentation    
* Improved reports
	1.   Measured data & model data included in text reports
	2.   EPS files generated more reliably
* Added initial k/rc selection
	1.   Initial values of k and rc can be set in Meta-data
* Explore works without contours
	1.   Explore works without having contours computed
	2.   Exploring without contours can be invoked by clicking on the textbox with the modeling results in the “Results” figure.
* Added possibility to load GeTTMo synthetic data
* Added version information
	1.   Version is included in processed session files
	2.   Check whether versions are identical is performed when session files is performed and user is warned if mismatch occurs

## Version 0.1
* Initial Release
 
