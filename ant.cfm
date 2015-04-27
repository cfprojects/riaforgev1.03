<!---    ant.cfm

AUTHOR				: tpryan
CREATED				: 6/12/2007 6:56:33 PM
DESCRIPTION			: A version of the riaforge.cfc calling page that is suitable for use with Ant.
---->
<cfsetting showdebugoutput="FALSE">

<cftry>

	<cfparam name="url.version" type="string" default="0.9.8.5">

	<cfset configFile = expandPath('.') & "\config\sample.xml" />	
	
	<!--- Instatiate the riaforge Object --->
	<cfset riaForgeObj = CreateObject("component", "riaforge").init() />
	
	<!--- Manually create the  configuration structure--->
	<cfset config = riaForgeObj.convertFileToConfig(configFile) />
	
	<!--- Override a few values --->
	<cfset config['version'] = url.version />
	<cfset config['newdownload'] ="W:\OpenSourceProjects\Squidhead\squidheadv#url.version#.zip" />
	
	<!--- Publish using the overriden config. --->
	<cfset riaForgeObj.publish(config) /> 
	
	<!--- Try and catch here ensures that if you have any errors ant will halt build.  --->
	<cfcatch type="any">
		<cfheader statuscode="500" />
		<cfrethrow />
	</cfcatch>

</cftry>
