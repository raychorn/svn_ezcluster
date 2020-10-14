<cfcomponent>

	<cfinclude template="includes/cfinclude_explainError.cfm">
	<cfinclude template="includes/cfinclude_cflog.cfm">
	<cfinclude template="includes/cfinclude_cfdump.cfm">

	<cfscript>
		if (NOT IsDefined("This.name")) {
			aa = ListToArray(CGI.SCRIPT_NAME, '/');
			subName = aa[1];
			if (Len(subName) gt 0) {
				subName = '_' & subName;
			}

			myAppName = right(reReplace(CGI.SERVER_NAME & subName, "[^a-zA-Z]","_","all"), 64);
			myAppName = ArrayToList(ListToArray(myAppName, '_'), '_');
			This.name = UCASE(myAppName);
		}
		This.clientManagement = "Yes";
		This.sessionManagement = "Yes";
		This.sessionTimeout = "#CreateTimeSpan(0,1,0,0)#";
		This.applicationTimeout = "#CreateTimeSpan(1,0,0,0)#";
		This.clientStorage = "clientvars";
		This.loginStorage = "session";
		This.setClientCookies = "Yes";
		This.setDomainCookies = "No";
		This.scriptProtect = "All";
		
		this.DSN = -1;
	</cfscript>
	
	<cffunction name="onError">
	   <cfargument name="Exception" required=true/>
	   <cfargument type="String" name="EventName" required=true/>

	   <cfscript>
			var bool_debugMode = (Find("192.168.", CGI.REMOTE_ADDR) gt 0) OR (Find("127.0.0.1", CGI.REMOTE_ADDR) gt 0);
	   		if (bool_debugMode) writeOutput(cf_dump(Exception, 'Exception', false));
	   </cfscript>

	</cffunction>

	<cffunction name="onSessionStart">
	   <cfscript>
	      Session.started = now();
	      Session.shoppingCart = StructNew();
	      Session.shoppingCart.items =0;
	   </cfscript>
	      <cflock scope="Application" timeout="5" type="Exclusive">
	         <cfset Application.sessions = Application.sessions + 1>
	   </cflock>
		<cflog file="#Application.applicationName#" type="Information" text="Session #Session.sessionid# started. Active sessions: #Application.sessions#">
	</cffunction>

	<cffunction name="onSessionEnd">
		<cfargument name = "SessionScope" required=true/>
		<cfargument name = "AppScope" required=true/>
	
		<cfset var sessionLength = TimeFormat(Now() - SessionScope.started, "H:mm:ss")>
		<cflock name="AppLock" timeout="5" type="Exclusive">
			<cfif (NOT IsDefined("Arguments.AppScope.sessions"))>
				<cfset ApplicationScope.sessions = 0>
			</cfif>
			<cfset Arguments.AppScope.sessions = Arguments.AppScope.sessions - 1>
		</cflock>

		<cflog file="#Arguments.AppScope.applicationName#" type="Information" text="Session #Arguments.SessionScope.sessionid# ended. Length: #sessionLength# Active sessions: #Arguments.AppScope.sessions#">
	</cffunction>

	<cffunction name="onApplicationStart" access="public">
		<cfif 0>
			<cftry>
				<!--- Test whether the DB is accessible by selecting some data. --->
				<cfquery name="testDB" dataSource="#Request.INTRANET_DS#">
					SELECT TOP 1 * FROM AvnUsers
				</cfquery>
				<!--- If we get a database error, report an error to the user, log the
				      error information, and do not start the application. --->
				<cfcatch type="database">
					<cfoutput>
						This application encountered an error<br>
						Unable to use the ColdFusion Data Source named "#Request.INTRANET_DS#"<br>
						Please contact support.
					</cfoutput>
					<cflog file="#This.Name#" type="error" text="#Request.INTRANET_DS# DSN is not available. message: #cfcatch.message# Detail: #cfcatch.detail# Native Error: #cfcatch.NativeErrorCode#" >
					<cfreturn False>
				</cfcatch>
			</cftry>
		</cfif>

		<cflog file="#This.Name#" type="Information" text="Application Started">
		<!--- You do not have to lock code in the onApplicationStart method that sets
		      Application scope variables. --->
		<cfscript>
			Application.sessions = 0;
		</cfscript>
		<cfreturn True>
	</cffunction>

	<cffunction name="onApplicationEnd" access="public">
		<cfargument name="ApplicationScope" required=true/>
		<cflog file="#This.Name#" type="Information" text="Application #Arguments.ApplicationScope.applicationname# Ended" >
	</cffunction>

	<cffunction name="onRequestStart" access="public">
		<cfargument name = "_targetPage" required=true/>

		<cfscript>
			Request.DSN = this.DSN;
			
			Request.const_Cr = Chr(13);
			Request.const_Lf = Chr(10);
			Request.const_Tab = Chr(9);
			Request.const_CrLf = Request.const_Cr & Request.const_Lf;
			Request.const_paper_color_light_yellow = '##FFFFBF';
			Request.const_color_light_blue = '##80FFFF';
			
			Request.AUTH_USER = 'admin';

			Request.bool_debugMode = (Find("192.168.", CGI.REMOTE_ADDR) gt 0) OR (Find("127.0.0.1", CGI.REMOTE_ADDR) gt 0);

			err_ezclusterCode = false;
			err_ezclusterCodeMsg = '';
			try {
			   Request.commonCode = CreateObject("component", "cfc.ezclusterCode");
			} catch(Any e) {
				Request.commonCode = -1;
				err_ezclusterCode = true;
				err_ezclusterCodeMsg = '(1) The ezclusterCode component has NOT been created.';
				writeOutput('<font color="red"><b>#err_ezclusterCodeMsg#</b></font><br>');
		   		if (Request.bool_debugMode) writeOutput(cf_dump(e, 'Exception (e)', false));
			}

			err_jsCodeAnalyzer = false;
			err_jsCodeAnalyzerMsg = '';
			try {
			   Request.jsCodeAnalyzer = CreateObject("component", "cfc.jsCodeAnalyzer").init();
			} catch(Any e) {
				Request.commonCode = -1;
				err_jsCodeAnalyzer = true;
				err_jsCodeAnalyzerMsg = '(1) The jsCodeAnalyzer component has NOT been created.';
				writeOutput('<font color="red"><b>#err_jsCodeAnalyzerMsg#</b></font><br>');
		   		if (Request.bool_debugMode) writeOutput(cf_dump(e, 'Exception (e)', false));
			}

			// BEGIN: Notice when the URL Rewrite Engine is working and then force Apache to ignore rewriting by doing a redirect...
		//	sKeys = StructKeyList(URL, ",");
		//	Request.commonCode.cf_log(Application.applicationname, 'Information', '[' & CGI.SCRIPT_NAME & '?_parms=' & CGI.QUERY_STRING & ']' & 'sKeys = [#sKeys#]');
		//	if ( (StructCount(URL) eq 2) AND ( (sKeys eq "P,D") OR (sKeys eq "D,P") ) ) {
		//		if (IsStruct(Request.commonCode)) Request.commonCode.cf_location(CGI.SCRIPT_NAME & '?_parms=' & CGI.QUERY_STRING);
		//	}
			// END! Notice when the URL Rewrite Engine is working and then force Apache to ignore rewriting by doing a redirect...
		//	writeOutput('DEBUG: ' & 'StructCount(URL) = [#StructCount(URL)#] (#StructKeyList(URL, ",")#)' & ', CGI.QUERY_STRING = [#CGI.QUERY_STRING#]');
		</cfscript>

		<cfreturn (err_ezclusterCode eq false) AND (err_jsCodeAnalyzer eq false)>
	</cffunction>

	<cffunction name="onRequestEnd" access="public">
		<cfargument name = "_targetPage" required=true/>
	</cffunction>
</cfcomponent>
