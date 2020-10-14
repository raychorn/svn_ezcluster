<cfcomponent displayname="ezclusterCode" output="No" extends="commonCode">
	<cffunction name="menuBar" access="public" returntype="string">
		<cfset var _html = "">
		<cfsavecontent variable="_html">
			<td bgcolor="silver">
				<button type="button" id="btn_menuBar_myAccount" class="normalStatusBoldClass">myAccount</button>
			</td>
		</cfsavecontent>
		<cfreturn _html>
	</cffunction>
</cfcomponent>
