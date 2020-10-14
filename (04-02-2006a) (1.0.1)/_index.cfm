<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<cfoutput>
<html>
<head>
	<title>ezCluster &copy;Hierarchical Applications Limited, All Rights Reserved.</title>
	#Request.commonCode.html_nocache()#
	<LINK rel="STYLESHEET" type="text/css" href="StyleSheet.css"> 
	<link rel="shortcut icon" href="favicon.ico" type="image/x-icon" />
	<cfif (CGI.REMOTE_ADDR neq '127.0.0.1') AND (Find('192.168.', CGI.REMOTE_ADDR) eq 0)>
		<script language="JavaScript1.2" type="text/javascript">var m$=""; function cIE() { if (document.all) {(m$); return false;} }; function cNS(e) { if (document.layers||(document.getElementById&&!document.all)) {if (e.which==2||e.which==3) { (m$); return false;}}}; if (document.layers) { document.captureEvents(Event.MOUSEDOWN); document.onmousedown=cNS; }	else { document.onmouseup=cNS; document.oncontextmenu=cIE; }; document.oncontextmenu = new Function("return false");</script>
	</cfif>
	<cfscript>
		const_button_pressed_color_light_blue = 'lime';
		const_button_hilite_color_light_yellow = 'cyan';
	</cfscript>
	<cfsavecontent variable="_jsCode">
		<cfoutput>
			const_button_pressed_color_light_blue = '#const_button_pressed_color_light_blue#';
			const_button_hilite_color_light_yellow = '#const_button_hilite_color_light_yellow#';
	
			const_backgroundColor_symbol = 'backgroundColor';
			const_object_symbol = 'object';
			
			_cache_Button_style = [];
			
			function trim() {  
			 	var s = null;
				// trim white space from the left  
				s = this.replace(/^[\s]+/,"");  
				// trim white space from the right  
				s = s.replace(/[\s]+$/,"");  
				return s;
			}
			
			String.prototype.trim = trim;
	
			function $(id) {
				var obj = -1;
				obj = ((document.getElementById) ? document.getElementById(id) : ((document.all) ? document.all[id] : ((document.layers) ? document.layers[id] : null)));
				return obj;
			}
	
			function jsObjectEx$(o, bool_useAlert) {
				var _db = ''; 
				var m = -1;
				var o_m = -1;
				var typOf = typeof o;
				
				bool_useAlert = ((!!bool_useAlert) ? bool_useAlert : false);
			
				if (typOf == const_object_symbol) {
					for (m in o) {
						_db += 'o[' + m + '] = '; 
						try {
							o_m = o[m];
						} catch(e) {
							o_m = 'undefined';
						} finally {
						}
						_db += '(' + o_m + ')\n'; 
					}
				}
				_db = 'jsObjectEx$(' + o + ', typeOf = [' + typOf + ']) ::' + ((o.length) ? ' o.length = [' + ((o.length) ? o.length : 'undefined') + ']' : '') + '\n' + _db;
				if (bool_useAlert) {
					alert(_db);
				} else {
					return _db;
				}
			}
	
			function jsErrorEx$(e, funcName) {
				funcName = ((!!funcName) ? funcName : '');
				var _db = ''; 
				_db += "e.number is: " + (e.number & 0xFFFF) + '\n'; 
				_db += "e.description is: " + e.description + '\n'; 
				_db += "e.name is: " + e.name + '\n'; 
				_db += "e.message is: " + e.message + '\n';
				alert(funcName + '\n' + e.toString() + '\n' + _db);
			}
	
			function cacheBtnStyleById(id, selector) {
				var obj = -1;
				var _id = id + '_' + selector;
				if (id.trim().length > 0) {
					if (_cache_Button_style[_id] == null) {
						obj = $(id);
						if (obj != null) {
							_cache_Button_style[_id] = eval('obj.style.' + selector);
						}
					}
				}
				return _cache_Button_style[_id];
			}
			
			function clear_cacheBtnStyleById(id, selector) {
				var obj = -1;
				var _id = id + '_' + selector;
				if (id.trim().length > 0) {
					if (_cache_Button_style[_id] != null) {
						obj = $(id);
						if (obj != null) {
							_cache_Button_style[_id] = null;
						}
					}
				}
				return _cache_Button_style[_id];
			}
			
			function handle_mouseFuncs(containerObj, objType) {
				var const_on_symbol = 'on';
				var const_onmouseover_symbol = 'mouseover';
				var const_onmouseout_symbol = 'mouseout';
				var const_onclick_symbol = 'click';
				
				var _myCapture = [ const_onmouseover_symbol, const_onmouseout_symbol, const_onclick_symbol ];
				var handle_mouseFuncs_inuse_flag = false;
			
				function explainColor(aColor) {
					return ((aColor == const_button_pressed_color_light_blue) ? 'color light blue' : ((aColor == const_button_hilite_color_light_yellow) ? 'color light yellow' : (((aColor == null) || (aColor.trim().length == 0)) ? 'UNKNOWN' : 'DEFAULT (' + aColor + ')')));
				}
			
				_captureFunc = function(event) {
					var _color = -1;
					var aColor = -1;
					
					if (handle_mouseFuncs_inuse_flag) {return}
					handle_mouseFuncs_inuse_flag = true;
					_color = cacheBtnStyleById(event.srcElement.id, const_backgroundColor_symbol);
					aColor = ((event.type.trim().toUpperCase() == const_onclick_symbol.trim().toUpperCase()) ? const_button_pressed_color_light_blue : const_button_hilite_color_light_yellow);
					event.srcElement.style.backgroundColor = ((const_onmouseout_symbol.trim().toUpperCase().indexOf(event.type.trim().toUpperCase()) != -1) ? _color : aColor);
					event.cancelBubble = true;
					handle_mouseFuncs_inuse_flag = false;
				};
				
				function capEvents(el) {
					for (var i = 0; i < _myCapture.length; i++) {
						el.attachEvent(const_on_symbol + _myCapture[i], _captureFunc);
					}
				}
			
				var kids = containerObj.getElementsByTagName(objType);
	
				if ( (containerObj != null) && (containerObj.getElementsByTagName) ) {
					for (var i = 0; i < kids.length; i++) {
						var aKid = kids[i];
						if ( (aKid.type) && (aKid.type.trim().toUpperCase() == 'BUTTON') ) {
							capEvents(aKid);
						}
					}
				}
			}
	
			window.onload = function () {
				dObj = $('div_button_container');
				if (!!dObj) {
					handle_mouseFuncs(dObj, 'BUTTON');
				}
			};
		</cfoutput>
	</cfsavecontent>
	<cfscript>
	//	Request.jsCodeAnalyzer.analyzeThis(Request.commonCode.obfuscateJScode(_jsCode));
	</cfscript>
	<cfdump var="#Request.jsCodeAnalyzer#" label="Request.jsCodeAnalyzer" expand="No">
	<script type="text/javascript" language="JavaScript1.3">
		#Request.commonCode.obfuscateJScode(_jsCode)#
	</script>
</head>

	<body>
	
	<div id="div_button_container">
		<table width="100%" cellpadding="-1" cellspacing="-1">
			<tr>
				<td>
					<h2 align="left"><a href="#CGI.SCRIPT_NAME#">ezCluster<SUP><FONT SIZE="-1">TM</FONT></SUP></a> <small>Web Server Cluster Management System, the Easy Way.</small></h2>
				</td>
			</tr>
			<tr>
				#Request.commonCode.menuBar()#
			</tr>
		</table>
	</div>
	
	</body>
</cfoutput>

</html>
