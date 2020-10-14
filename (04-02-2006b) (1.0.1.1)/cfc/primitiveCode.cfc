<cfcomponent displayname="primitiveCode" output="No">
	<cfinclude template="../includes/cfinclude_cflog.cfm">
	<cfinclude template="../includes/cfinclude_cfdump.cfm">
	
	<cfscript>
		const_PK_violation_msg = 'Violation of PRIMARY KEY constraint';
	
		function _isPKviolation(eMsg) {
			var bool = false;
			if (FindNoCase(const_PK_violation_msg, eMsg) gt 0) {
				bool = true;
			}
			return bool;
		}
	</cfscript>
	
	<cffunction name="cfdump" access="public" returntype="string">
		<cfargument name="_aVar_" type="any" required="yes">
		<cfargument name="_aLabel_" type="string" required="yes">
		<cfargument name="_aBool_" type="boolean" default="False">

		<cfsavecontent variable="_html">
			<cfoutput>
				<cfscript>
					if (IsDefined("_aBool_")) {
						cf_dump(_aVar_, _aLabel_, _aBool_);
					} else {
						cf_dump(_aVar_, _aLabel_);
					}
				</cfscript>
			</cfoutput>
		</cfsavecontent>
		
		<cfreturn _html>
	</cffunction>

	<cffunction name="cfm_nocache" access="public" returntype="string">
		<cfargument name="LastModified" type="string" required="yes">

		<CFSETTING ENABLECFOUTPUTONLY="YES">
		<CFHEADER NAME="Pragma" VALUE="no-cache">
		<CFHEADER NAME="Cache-Control" VALUE="no-cache, must-revalidate">
		<CFHEADER NAME="Last-Modified" VALUE="#LastModified#">
		<CFHEADER NAME="Expires" VALUE="Mon, 26 Jul 1997 05:00:00 EST">
		<CFSETTING ENABLECFOUTPUTONLY="NO">
		
		<cfreturn "True">
	</cffunction>

	<cffunction name="cf_location" access="public" returntype="any">
		<cfargument name="_url_" type="string" required="yes">
	
		<cflocation url="#_url_#" addtoken="No">
	
	</cffunction>

	<cffunction name="cf_execute" access="public" returntype="any">
		<cfargument name="_name_" type="string" required="yes">
		<cfargument name="_args_" type="string" required="yes">
		<cfargument name="_timeout_" type="numeric" required="yes">
	
		<cfset Request.errorMsg = "">	
		<cfset Request.execError = false>	
		<cftry>
			<cfexecute name="#_name_#" arguments="#_args_#" variable="Request.cfexecuteOutput" timeout="#_timeout_#" />

			<cfcatch type="Any">
				<cfset Request.execError = true>	

				<cfsavecontent variable="Request.errorMsg">
					<cfoutput>
						<cfif (IsDefined("cfcatch.message"))>[#cfcatch.message#]<br></cfif>
						<cfif (IsDefined("cfcatch.detail"))>[#cfcatch.detail#]<br></cfif>
					</cfoutput>
				</cfsavecontent>
			</cfcatch>
		</cftry>
	
	</cffunction>

	<cffunction name="cf_file_write" access="public" returntype="any">
		<cfargument name="_fName_" type="string" required="yes">
		<cfargument name="_out_" type="string" required="yes">

		<cfset Request.errorMsg = "">	
		<cfset Request.fileError = false>	
		<cftry>
			<cffile action="WRITE" file="#_fName_#" output="#_out_#" attributes="Normal" addnewline="No" fixnewline="No">

			<cfcatch type="Any">
				<cfset Request.fileError = true>	

				<cfsavecontent variable="Request.errorMsg">
					<cfoutput>
						<cfif (IsDefined("cfcatch.message"))>[#cfcatch.message#]<br></cfif>
						<cfif (IsDefined("cfcatch.detail"))>[#cfcatch.detail#]<br></cfif>
					</cfoutput>
				</cfsavecontent>
			</cfcatch>
		</cftry>
	
	</cffunction>

	<cffunction name="cf_file_read" access="public" returntype="any">
		<cfargument name="_fName_" type="string" required="yes">
		<cfargument name="_vName_" type="string" required="yes">

		<cfset Request.errorMsg = "">	
		<cfset Request.fileError = false>	
		<cftry>
			<cffile action="READ" file="#_fName_#" variable="#_vName_#">

			<cfcatch type="Any">
				<cfset Request.fileError = true>	

				<cfsavecontent variable="Request.errorMsg">
					<cfoutput>
						<cfif (IsDefined("cfcatch.message"))>[#cfcatch.message#]<br></cfif>
						<cfif (IsDefined("cfcatch.detail"))>[#cfcatch.detail#]<br></cfif>
					</cfoutput>
				</cfsavecontent>
			</cfcatch>
		</cftry>
	
	</cffunction>

	<cffunction name="cf_file_delete" access="public" returntype="any">
		<cfargument name="_fName_" type="string" required="yes">

		<cfset Request.errorMsg = "">	
		<cfset Request.fileError = false>	
		<cftry>
			<cffile action="DELETE" file="#_fName_#">

			<cfcatch type="Any">
				<cfset Request.fileError = true>	

				<cfsavecontent variable="Request.errorMsg">
					<cfoutput>
						<cfif (IsDefined("cfcatch.message"))>[#cfcatch.message#]<br></cfif>
						<cfif (IsDefined("cfcatch.detail"))>[#cfcatch.detail#]<br></cfif>
					</cfoutput>
				</cfsavecontent>
			</cfcatch>
		</cftry>
	
	</cffunction>

	<cffunction name="safely_execSQL" access="public">
		<cfargument name="_qName_" type="string" required="yes">
		<cfargument name="_DSN_" type="string" required="yes">
		<cfargument name="_sql_" type="string" required="yes">
		<cfargument name="_cachedWithin_" type="string" default="">
		
		<cfset Request.errorMsg = "">
		<cfset Request.moreErrorMsg = "">
		<cfset Request.explainError = "">
		<cfset Request.explainErrorHTML = "">
		<cfset Request.dbError = "False">
		<cfset Request.isPKviolation = "False">
		<cftry>
			<cfif (Len(Trim(arguments._qName_)) gt 0)>
				<cfif (Len(_DSN_) gt 0)>
					<cfif (Len(_cachedWithin_) gt 0) AND (IsNumeric(_cachedWithin_))>
						<cfquery name="#_qName_#" datasource="#_DSN_#" cachedwithin="#_cachedWithin_#">
							#PreserveSingleQuotes(_sql_)#
						</cfquery>
					<cfelse>
						<cfquery name="#_qName_#" datasource="#_DSN_#">
							#PreserveSingleQuotes(_sql_)#
						</cfquery>
					</cfif>
				<cfelse>
					<cfquery name="#_qName_#" dbtype="query">
						#PreserveSingleQuotes(_sql_)#
					</cfquery>
				</cfif>
			<cfelse>
				<cfset Request.errorMsg = "Missing Query Name which is supposed to be the first parameter.">
				<cfthrow message="#Request.errorMsg#" type="missingQueryName" errorcode="-100">
			</cfif>
	
			<cfcatch type="Any">
				<cfset Request.dbError = "True">
	
				<cfsavecontent variable="Request.errorMsg">
					<cfoutput>
						<cfif (IsDefined("cfcatch.message"))>[#cfcatch.message#]<br></cfif>
						<cfif (IsDefined("cfcatch.detail"))>[#cfcatch.detail#]<br></cfif>
						<cfif (IsDefined("cfcatch.SQLState"))>[<b>cfcatch.SQLState</b>=#cfcatch.SQLState#]</cfif>
					</cfoutput>
				</cfsavecontent>
	
				<cfsavecontent variable="Request.moreErrorMsg">
					<cfoutput>
						<UL>
							<cfif (IsDefined("cfcatch.Sql"))><LI>#cfcatch.Sql#</LI></cfif>
							<cfif (IsDefined("cfcatch.type"))><LI>#cfcatch.type#</LI></cfif>
							<cfif (IsDefined("cfcatch.message"))><LI>#cfcatch.message#</LI></cfif>
							<cfif (IsDefined("cfcatch.detail"))><LI>#cfcatch.detail#</LI></cfif>
							<cfif (IsDefined("cfcatch.SQLState"))><LI>#cfcatch.SQLState#</LI></cfif>
						</UL>
					</cfoutput>
				</cfsavecontent>
	
				<cfsavecontent variable="Request.explainErrorText">
					<cfoutput>
						[#explainError(cfcatch, false)#]
					</cfoutput>
				</cfsavecontent>
	
				<cfsavecontent variable="Request.explainErrorHTML">
					<cfoutput>
						[#explainError(cfcatch, true)#]
					</cfoutput>
				</cfsavecontent>
	
				<cfscript>
					if (Len(_DSN_) gt 0) {
						Request.isPKviolation = _isPKviolation(Request.errorMsg);
					}
				</cfscript>
	
				<cfset Request.dbErrorMsg = Request.errorMsg>
				<cfsavecontent variable="Request.fullErrorMsg">
					<cfoutput>
						#Request.moreErrorMsg#
					</cfoutput>
				</cfsavecontent>
				<cfsavecontent variable="Request.verboseErrorMsg">
					<cfif (IsDefined("Request.bool_show_verbose_SQL_errors"))>
						<cfif (Request.bool_show_verbose_SQL_errors)>
							<cfoutput>
								#Request.explainErrorHTML#
							</cfoutput>
						</cfif>
					</cfif>
				</cfsavecontent>
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="_safely_execSQL" access="public">
		<cfargument name="_qName_" type="string" required="yes">
		<cfargument name="_DSN_" type="string" required="yes">
		<cfargument name="_sql_" type="string" required="yes">
		<cfargument name="_cachedWithin_" type="string" default="">
		
		<cfscript>
			var q = -1;
		</cfscript>
	
		<cfset Request.errorMsg = "">
		<cfset Request.moreErrorMsg = "">
		<cfset Request.explainError = "">
		<cfset Request.explainErrorHTML = "">
		<cfset Request.dbError = "False">
		<cfset Request.isPKviolation = "False">
		<cftry>
			<cfif (Len(Trim(arguments._qName_)) gt 0)>
				<cfif (Len(_DSN_) gt 0)>
					<cfif (Len(_cachedWithin_) gt 0) AND (IsNumeric(_cachedWithin_))>
						<cfquery name="#_qName_#" datasource="#_DSN_#" cachedwithin="#_cachedWithin_#">
							#PreserveSingleQuotes(_sql_)#
						</cfquery>
					<cfelse>
						<cfquery name="#_qName_#" datasource="#_DSN_#">
							#PreserveSingleQuotes(_sql_)#
						</cfquery>
					</cfif>
				<cfelse>
					<cfquery name="#_qName_#" dbtype="query">
						#PreserveSingleQuotes(_sql_)#
					</cfquery>
				</cfif>
			<cfelse>
				<cfset Request.errorMsg = "Missing Query Name which is supposed to be the first parameter.">
				<cfthrow message="#Request.errorMsg#" type="missingQueryName" errorcode="-100">
			</cfif>
	
			<cfcatch type="Database">
				<cfset Request.dbError = "True">
	
				<cfsavecontent variable="Request.errorMsg">
					<cfoutput>
						<cfif (IsDefined("cfcatch.message"))>[#cfcatch.message#]<br></cfif>
						<cfif (IsDefined("cfcatch.detail"))>[#cfcatch.detail#]<br></cfif>
						<cfif (IsDefined("cfcatch.SQLState"))>[<b>cfcatch.SQLState</b>=#cfcatch.SQLState#]</cfif>
					</cfoutput>
				</cfsavecontent>
	
				<cfsavecontent variable="Request.moreErrorMsg">
					<cfoutput>
						<UL>
							<cfif (IsDefined("cfcatch.Sql"))><LI>#cfcatch.Sql#</LI></cfif>
							<cfif (IsDefined("cfcatch.type"))><LI>#cfcatch.type#</LI></cfif>
							<cfif (IsDefined("cfcatch.message"))><LI>#cfcatch.message#</LI></cfif>
							<cfif (IsDefined("cfcatch.detail"))><LI>#cfcatch.detail#</LI></cfif>
							<cfif (IsDefined("cfcatch.SQLState"))><LI>#cfcatch.SQLState#</LI></cfif>
						</UL>
					</cfoutput>
				</cfsavecontent>
	
				<cfsavecontent variable="Request.explainErrorText">
					<cfoutput>
						[#explainError(cfcatch, false)#]
					</cfoutput>
				</cfsavecontent>
	
				<cfsavecontent variable="Request.explainErrorHTML">
					<cfoutput>
						[#explainError(cfcatch, true)#]
					</cfoutput>
				</cfsavecontent>
	
				<cfscript>
					if (Len(_DSN_) gt 0) {
						Request.isPKviolation = _isPKviolation(Request.errorMsg);
					}
				</cfscript>
	
				<cfset Request.dbErrorMsg = Request.errorMsg>
				<cfsavecontent variable="Request.fullErrorMsg">
					<cfdump var="#cfcatch#" label="cfcatch">
				</cfsavecontent>
				<cfsavecontent variable="Request.verboseErrorMsg">
					<cfif (IsDefined("Request.bool_show_verbose_SQL_errors"))>
						<cfif (Request.bool_show_verbose_SQL_errors)>
							<cfdump var="#cfcatch#" label="cfcatch :: Request.isPKviolation = [#Request.isPKviolation#]" expand="No">
						</cfif>
					</cfif>
				</cfsavecontent>
	
				<cfscript>
					if ( (IsDefined("Request.bool_show_verbose_SQL_errors")) AND (IsDefined("Request.verboseErrorMsg")) ) {
						if (Request.bool_show_verbose_SQL_errors) {
							if (NOT Request.isPKviolation) 
								writeOutput(Request.verboseErrorMsg);
						}
					}
				</cfscript>
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="safely_cfmail" access="public" returntype="any">
		<cfargument name="_toAddrs_" type="string" required="yes">
		<cfargument name="_fromAddrs_" type="string" required="yes">
		<cfargument name="_theSubj_" type="string" required="yes">
		<cfargument name="_theBody_" type="string" required="yes">
	
		<cfset Request.anError = "False">
		<cfset Request.errorMsg = "">
		<cftry>
			<cfmail to="#_toAddrs_#" from="#_fromAddrs_#" subject="#_theSubj_#" type="HTML">#_theBody_#</cfmail>
	
			<cfcatch type="Any">
				<cfset Request.anError = "True">
	
				<cfsavecontent variable="Request.errorMsg">
					<cfoutput>
						#cfcatch.message#<br>
						#cfcatch.detail#
					</cfoutput>
				</cfsavecontent>
			</cfcatch>
		</cftry>
	
	</cffunction>

	<cffunction name="cf_wddx_WDDX2CFML" access="public" returntype="any">
		<cfargument name="_input_item_" type="string" required="yes">

		<cfwddx action="WDDX2CFML" input="#_input_item_#" output="Request._CMD_">
	</cffunction>

	<cffunction name="cf_directory" access="public" returntype="boolean">
		<cfargument name="_qName_" type="string" required="yes">
		<cfargument name="_path_" type="string" required="yes">
		<cfargument name="_filter_" type="string" required="yes">
		<cfargument name="_recurse_" type="boolean" default="False">
	
		<cfset Request.directoryError = "False">
		<cfset Request.directoryErrorMsg = "">
		<cfset Request.directoryFullErrorMsg = "">
		<cftry>
			<cfif (_recurse_)>
				<cfdirectory action="LIST" directory="#_path_#" name="#_qName_#" filter="#_filter_#" recurse="Yes">
			<cfelse>
				<cfdirectory action="LIST" directory="#_path_#" name="#_qName_#" filter="#_filter_#">
			</cfif>

			<cfcatch type="Any">
				<cfset Request.directoryError = "True">

				<cfsavecontent variable="Request.directoryErrorMsg">
					<cfoutput>
						#cfcatch.message#<br>
						#cfcatch.detail#
					</cfoutput>
				</cfsavecontent>
				<cfsavecontent variable="Request.directoryFullErrorMsg">
					<cfdump var="#cfcatch#" label="cfcatch" expand="Yes">
				</cfsavecontent>
			</cfcatch>
		</cftry>
	
		<cfreturn Request.directoryError>
	</cffunction>
	
	<cffunction name="rs2Query" output="false" hint="returns a query from a Java ResultSet object">
		<cfargument name="resultset" type="any" required="true">
		
		<cfset var rs = resultset>
		<cfset var x = false>
		<cfset var col = false>
		<cfset var colnames = "">
		<cfset var tableData = false>
		
		<cfif isobject(resultset) AND findnocase("resultset",resultset.getClass().getName())>
			<cfset tabledata = resultset.getMetaData()>
			<cfloop index="x" from="1" to="#tableData.getColumnCount()#">
				<cfset colnames = listappend(colnames,tableData.getColumnName(JavaCast("int",x)))>
			</cfloop>
			<cfset rs = querynew(colnames)>
			
			<cfloop condition="resultset.next()">
				<cfif resultset.getRow()>
					<cfset queryaddrow(rs)>
					<cfset x = rs.recordcount>
					<cfloop index="col" list="#colnames#">
						<cfset rs[col][x] = resultset.getString(JavaCast("string",col))>
					</cfloop>
				</cfif>
			</cfloop>
		</cfif>
		
		<cfreturn rs>
	</cffunction>

	<cffunction name="jdbcType" output="false" returntype="string" hint="returns the name or number for a given Java JDBC data type">
		<cfargument name="typeid" type="string" required="true">
		
		<cfset var sqltype = createobject("java","java.sql.Types")>
		<cfset var types = structnew()>
		
		<cfloop item="x" collection="#sqltype#">
			<cfset types[x] = sqltype[x]>
			<cfset types[sqltype[x]] = x>
		</cfloop>
		
		<cfreturn types[typeid]>
	</cffunction>

	<cffunction name="oJDBCMetaData" access="public" returntype="struct">
		<cfargument name="_dsn_" type="string" required="true">
		<cfargument name="_username_" type="string" required="true">
		<cfargument name="_password_" type="string" required="true">

		<cfscript>
			var aStruct = StructNew();
			var factory = -1;
		</cfscript>

		<cflock name="coldfusion.server.ServiceFactory" type="exclusive" timeout="10">
			<cfscript>
				factory = CreateObject("java", "coldfusion.server.ServiceFactory");
				aStruct.ds_service = factory.datasourceservice;
				aStruct.conn = aStruct.ds_service.getDataSource(_dsn_).getConnection(_username_,_password_);
				aStruct.mdata = aStruct.conn.getMetaData();
			</cfscript>			
		</cflock>
		
		<cfreturn aStruct>
	</cffunction>

	<cffunction name="qJDBCCatalog" access="public" returntype="struct">
		<cfargument name="_oMetaData_" type="struct" required="yes">
		
		<cfscript>
			var aStruct = StructNew();

			aStruct.rsCatalog = _oMetaData_.mdata.getCatalogs();
			aStruct.qCatalog = rs2Query(aStruct.rsCatalog);
		</cfscript>

		<cfreturn aStruct>
	</cffunction>

	<cffunction name="qJDBCSchema" access="public" returntype="struct">
		<cfargument name="_oMetaData_" type="struct" required="yes">
		
		<cfscript>
			var aStruct = StructNew();

			aStruct.rsSchemas = _oMetaData_.mdata.getSchemas();
			aStruct.qSchemas = rs2Query(aStruct.rsSchemas);
		</cfscript>

		<cfreturn aStruct>
	</cffunction>

	<cffunction name="qJDBCTables" access="public" returntype="struct">
		<cfargument name="_oMetaData_" type="struct" required="yes">
		<cfargument name="_schemaName_" type="string" required="true">
		
		<cfscript>
			var aStruct = StructNew();

			aStruct.rsTables = _oMetaData_.mdata.getTables(JavaCast("null",""), _schemaName_, JavaCast("null",""), JavaCast("null",""));
			aStruct.qTables = rs2Query(aStruct.rsTables);
		</cfscript>

		<cfreturn aStruct>
	</cffunction>

	<cffunction name="qJDBCTableTypes" access="public" returntype="struct">
		<cfargument name="_oMetaData_" type="struct" required="yes">
		
		<cfscript>
			var aStruct = StructNew();

			aStruct.rsTableTypes =  _oMetaData_.mdata.getTableTypes();
			aStruct.qTableTypes = rs2Query(aStruct.rsTableTypes);
		</cfscript>

		<cfreturn aStruct>
	</cffunction>

	<cffunction name="qJDBCColumns" access="public" returntype="struct">
		<cfargument name="_oMetaData_" type="struct" required="yes">
		<cfargument name="_DbName_" type="string" required="true">
		<cfargument name="_tableName_" type="string" required="true">
		
		<cfscript>
			var aStruct = StructNew();
			var i = -1;

			aStruct.rsColumns = _oMetaData_.mdata.getColumns(_DbName_,"%",_tableName_,"%");
			aStruct.qColumns = rs2Query(aStruct.rsColumns);

			for (i = 1; i lte aStruct.qColumns.recordCount; i = i + 1) {
				aStruct.qColumns.data_type[i] = jdbcType(aStruct.qColumns.data_type[i]);
			}
		</cfscript>

		<cfreturn aStruct>
	</cffunction>

	<cffunction name="execViaSessionLock" access="public">
		<cfargument name="_aCFFunc_" type="any" required="yes">
		
		<cfif (IsCustomFunction(_aCFFunc_))>
			<cfset Request.cflockErrorMsg = "">
			<cflock timeout="10" throwontimeout="No" type="EXCLUSIVE" scope="SESSION">
				<cftry>
					<cfscript>
						_aCFFunc_();
					</cfscript>
	
					<cfcatch type="Any">
						<cfsavecontent variable="Request.cflockErrorMsg">
							<cfoutput>
								_someCFcode_ = [#_someCFcode_#]<br>
								#cfcatch.message#<br>
								#cfcatch.detail#
							</cfoutput>
						</cfsavecontent>
					</cfcatch>
				</cftry>
			</cflock>
		<cfelse>
			<cfset Request.cflockErrorMsg = "ERROR: Invalid value for argument known as '_aCFFunc_' in function known as execViaSessionLock().">
		</cfif>
	</cffunction>

	<cffunction name="scopesDebugPanelContentLayout" access="public" returntype="string">
		<cfsavecontent variable="content_scopes_debug_panel">
			<cfoutput>
				<table width="100%" cellpadding="-1" cellspacing="-1">
					<tr>
						<td valign="top" align="left">
							<table width="100%" cellpadding="-1" cellspacing="-1">
								<tr>
									<td align="left" valign="top">
										<div id="div_application_debug_panel"></div>
									</td>
									<td align="left" valign="top">
										<div id="div_session_debug_panel"></div>
									</td>
									<td align="left" valign="top">
										<div id="div_cgiScope_debug_panel"></div>
									</td>
									<td align="left" valign="top">
										<div id="div_requestScope_debug_panel"></div>
									</td>
								</tr>
							</table>
						</td>
					</tr>
				</table>
			</cfoutput>
		</cfsavecontent>

		<cfreturn content_scopes_debug_panel>
	</cffunction>

</cfcomponent>
