<!---    riaforge.cfc

AUTHOR				: tpryan
CREATED				: 6/12/2007 7:14:27 PM
DESCRIPTION			: Allows for a few RIAforge tasks.
---->
<cfcomponent hint="Allows for a few RIAForge tasks. (Well just publishing for now)" output="false">

	<!---*****************************************************--->
	<!--- init --->
	<!--- Initialzes the CFC. --->
	<!---*****************************************************--->
	<cffunction access="public" name="init" output="false" returntype="any" hint="Initalizes the CFC." >
			
		<cfset variables.loginUrl = "http://www.riaforge.org/index.cfm?event=action.logon" />
		<cfset variables.updateForm = "http://www.riaforge.org/index.cfm?event=action.projectupdate" />
		
		<cfreturn This />
	</cffunction>

	<!---*****************************************************--->
	<!--- publish --->
	<!--- Publishes a set up updates to a RIA forge Site. --->
	<!---*****************************************************--->	
	<cffunction access="public" name="publish" output="false" returntype="void" hint="Publishes a set up updates to a RIA forge Site." >
		<cfargument name="config" type="any" required="yes" hint="A structure containing the configuration of the site you are updating or a pointer to the path of a config file." />
	
		<cfif isStruct(arguments.config)>
			<cfset variables.config = arguments.config />
		<cfelseif FileExists(arguments.config)>
			<cfset variables.config = convertFileToConfig(arguments.config) />
		<cfelse>
			<cfthrow message="Config Invalid" detail="The value of CONFIG must be either a config file, or the path to a config file.">
		</cfif>
		
		<cfset login() />
		<cfset update() />
			
	</cffunction>
	
	<!---*****************************************************--->
	<!--- login --->
	<!--- Logs into Riaforge. --->
	<!---*****************************************************--->
	<cffunction access="private" name="login" output="false" returntype="void" hint="Logs into Riaforge." >
	
		<cfset var loginResponse = StructNew() />
		<cfset var cookieStruct = StructNew() />
		<cfset var cookieName = "" />
		<cfset var cookieValue = "" />
		<cfset var i = 0 />
	
		<cfhttp url = "#loginUrl#" method = "post" result="loginResponse">
			<cfhttpparam name = "username" value = "#variables.config['username']#" type="formfield" />
			<cfhttpparam name = "password" value = "#variables.config['password']#" type="formfield" />
		</cfhttp>

		<!--- Grab the JsessionID --->
		<cfloop index="i" from="1" to="#arrayLen(StructKeyArray(loginResponse['ResponseHeader']['Set-Cookie']))#">
			<cfset cookieName = GetToken(loginResponse['ResponseHeader']['Set-Cookie'][i], 1, "=") />
			<cfset cookieValue = Right(loginResponse['ResponseHeader']['Set-Cookie'][i], len(loginResponse['ResponseHeader']['Set-Cookie'][i]) - (len(cookieName) +1)) />
			<cfset cookieStruct[cookieName] = cookieValue />
		</cfloop>

		<cfset variables['jsessionID'] = GetToken(cookieStruct['jsessionID'], 1, ";") />
	</cffunction>
	
	<!---*****************************************************--->
	<!--- update --->
	<!--- Updates the site based on the config.  --->
	<!---*****************************************************--->
	<cffunction access="private" name="update" output="false" returntype="void" hint="Updates the site based on the config." >
		
		<cfset var updateFormResponse = StructNew() />
		
		<cfhttp url = "#updateForm#" method = "post" result="updateFormResponse" multipart="TRUE">
			<cfhttpparam name = "jsessionID" value = "#variables['jsessionID']#" type="cookie" />
			<cfhttpparam name = "id" value = "#variables.config['ID']#" type="formfield" />
			<cfhttpparam name = "ret" value = "project" type="formfield" />
			<cfhttpparam name = "name" value = "#variables.config['name']#" type="formfield" />
			<cfhttpparam name = "shortdescription" value = "#variables.config['shortdescription']#" type="formfield" />
			<cfhttpparam name = "description" value = "#variables.config['description']#" type="formfield" />
			<cfhttpparam name = "requirements" value = "#variables.config['requirements']#" type="formfield" />
			<cfhttpparam name = "projectcategoryidfk" value = "#variables.config['projectcategoryidfk']#" type="formfield" />
			<cfhttpparam name = "version" value = "#variables.config['version']#" type="formfield" />
			<cfhttpparam name = "externalurl" value = "#variables.config['externalurl']#" type="formfield" />
			<cfhttpparam name = "externaldownload" value = "#variables.config['externaldownload']#" type="formfield" />
			<cfhttpparam name = "licenseidfk" value = "#variables.config['licenseidfk']#" type="formfield" />
			<cfhttpparam name = "removecurrentfileflag" value = "#variables.config['removecurrentfileflag']#" type="formfield" />
			<cfhttpparam name = "newdownload" file = "#variables.config['newdownload']#" type="file" mimetype="application/zip" />
			<cfhttpparam name = "forums" value = "#variables.config['forums']#" type="formfield" />
			<cfhttpparam name = "externalforums" value = "#variables.config['externalforums']#" type="formfield" />
			<cfhttpparam name = "blog" value = "#variables.config['blog']#" type="formfield" />
			<cfhttpparam name = "externalblog" value = "#variables.config['externalblog']#" type="formfield" />
			<cfhttpparam name = "externalblogrss" value = "#variables.config['externalblogrss']#" type="formfield" />
			<cfhttpparam name = "bugtracker" value = "#variables.config['bugtracker']#" type="formfield" />
			<cfhttpparam name = "externalbugtracker" value = "#variables.config['externalbugtracker']#" type="formfield" />
			<cfhttpparam name = "wiki" value = "#variables.config['wiki']#" type="formfield" />
			<cfhttpparam name = "externalwiki" value = "#variables.config['externalwiki']#" type="formfield" />
			<cfhttpparam name = "svn" value = "#variables.config['svn']#" type="formfield" />
			<cfhttpparam name = "demourl" value = "#variables.config['demourl']#" type="formfield" />
			<cfhttpparam name = "submit" value = "Update your Project" type="formfield" />
		</cfhttp>
	
	
	</cffunction>
	
	<!---*****************************************************--->
	<!--- convertFileToConfig --->
	<!--- Converts config files to the config struct. --->
	<!---*****************************************************--->
	<cffunction access="public" name="convertFileToConfig" output="false" returntype="struct" hint="Converts config files to the config struct." >
		<cfargument name="file" type="string" required="yes" default="" hint="The file path of the config file to parse." />
	
		<cfset var RawXML = "" />
		<cfset var XMLContents = "" />
		<cfset var configArray = ArrayNew(1) />
		<cfset var config = StructNew() />
		<cfset var i = 0 />
	
		<cffile action="read" file="#arguments.file#" variable="RawXML" />
		<cfset XMLContents = XMLParse(RawXML) />
		<cfset configArray= StructKeyArray(XMLContents.config) />
		
		<cfloop index="i" from="1" to="#ArrayLen(configArray)#">
			<cfset config[configArray[i]] = Trim(XMLContents.config[configArray[i]]['xmlText']) />
		</cfloop>
	
		<cfreturn config />
	</cffunction>

</cfcomponent>