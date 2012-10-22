@echo off

AltovaXML /xslt2 "MappingMapToschematron.xslt" /in "../especnav_data_files/measure-and-value-set-data.xml" %*
IF ERRORLEVEL 1 EXIT/B %ERRORLEVEL%
AltovaXML /xslt2 "MappingMapTomeasureMap.xslt" /in "../especnav_data_files/measure-and-value-set-data.xml" /out "measureMap.xml" %*
IF ERRORLEVEL 1 EXIT/B %ERRORLEVEL%
