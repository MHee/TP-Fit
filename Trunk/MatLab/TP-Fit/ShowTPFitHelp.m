function ShowTPFitHelp
MainDir=fileparts(which('ShowTPFitHelp'));
HelpIndex=[MainDir filesep '..' filesep '..' filesep 'doc' filesep 'index.html']
web(['file:///' HelpIndex],'-noaddressbox');