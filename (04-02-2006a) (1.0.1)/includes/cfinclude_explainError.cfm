<cfscript>
	function StructExplainer(st, _bool_asHTML, _bool_includeStackTrace) {
		var e = -1;
		var v = -1;
		var i = -1;
		var sMisc = -1;
		var _content = '';
		var sCurrent = -1;
		var sMiscList = -1;
		var nTagStack = -1;
		var bool_isError = -1;
		var content_specialList = '';
		var _StackTraceSymbol = '<StackTrace>';
		
		if (NOT IsBoolean(_bool_asHTML)) {
			_bool_asHTML = false;
		}
		
		if (NOT IsBoolean(_bool_includeStackTrace)) {
			_bool_includeStackTrace = false;
		}

		if (_bool_asHTML) {
			_content = _content & '<UL>';
		}
		for (e in st) {
			if (FindNoCase('<#e#>', '<TagContext>') eq 0) {
				try {
					v = st[e];
				} catch (Any ee) {
					v = '--- ERROR --';
				}
				if (FindNoCase('<#e#>', _StackTraceSymbol) neq 0) {
					if (NOT _bool_asHTML) {
						content_specialList = content_specialList & '#e#=#v#, ' & Chr(13);
					} else {
						v = '<textarea cols="160" rows="10" readonly style="font-size: 10px;">#v#</textarea>';
						content_specialList = content_specialList & '<li><b>#e#</b>&nbsp;#v#</li>';
					}
				} else if (IsSimpleValue(v)) {
					if (NOT _bool_asHTML) {
						_content = _content & '#e#=#v#,' & Chr(13);
					} else {
						_content = _content & '<li><b>#e#</b>&nbsp;#v#</li>';
					}
				} else {
					try {
						if (NOT _bool_asHTML) {
							_content = _content & '#e#=#StructExplainer(v, _bool_asHTML, _bool_includeStackTrace)#,' & Chr(13);
						} else {
							_content = _content & '<li><b>#e#</b>&nbsp;#StructExplainer(v, _bool_asHTML, _bool_includeStackTrace)#</li>';
						}
					} catch (Any e4) {
					}
				}
			} else {
				if (_bool_includeStackTrace) {
					nTagStack = ArrayLen(st.TAGCONTEXT);
					if (NOT _bool_asHTML) {
						_content = _content &	'The contents of the tag stack are: nTagStack = [#nTagStack#], ' & Chr(13);
					} else {
						_content = _content &	'<li><p><b>The contents of the tag stack are: nTagStack = [#nTagStack#] </b>';
					}
					if (nTagStack gt 0) {
						if (_bool_asHTML) {
							_content = _content & '<OL>';
						}
						for (i = 1; i lte nTagStack; i = i + 1) {
							bool_isError = false;
							try {
								sCurrent = st.TAGCONTEXT[i];
							} catch (Any e2) {
								bool_isError = true;
							}
							if (NOT bool_isError) {
								sMiscList = '';
								for (sMisc in sCurrent) {
									if (NOT _bool_asHTML) {
										sMiscList = ListAppend(sMiscList, ' [#sMisc#=#sCurrent[sMisc]#] ', ' | ') & Chr(13);
									} else {
										sMiscList = sMiscList & '<li><b><small>[#sMisc#=#sCurrent[sMisc]#]</small></b></li>';
									}
								}
								if (NOT _bool_asHTML) {
									_content = _content & sMiscList & '.' & Chr(13);
								} else {
									_content = _content & '<li><UL>' & sMiscList & '</UL></li>';
								}
							}
						}
						if (_bool_asHTML) {
							_content = _content & '</OL>';
						}
					}
					if (_bool_asHTML) {
						_content = _content & '</p></li>';
					}
					_content = _content & '<StackTrace>';
					if (_bool_asHTML) {
						_content = _content & '</ul>';
					} else {
						_content = _content & ',' & Chr(13);
					}
				}
			}
		}
		_content = _content & content_specialList;
		if (_bool_asHTML) {
			_content = _content & '</UL>';
		}
		return _content;
	}
	
	function _explainError(_error, bool_asHTML, bool_includeStackTrace) {
		var e = '';
		var v = '';
		var vn = '';
		var i = -1;
		var k = -1;
		var bool_isError = false;
		var sCurrent = -1;
		var sId = -1;
		var sLine = -1;
		var sColumn = -1;
		var sTemplate = -1;
		var nTagStack = -1;
		var sMisc = '';
		var sMiscList = '';
		var _content = '<ul>';
		var _ignoreList = '<remoteAddress>,<browser>,<dateTime>,<HTTPReferer>,<diagnostics>,<TagContext>';
		var _StackTraceSymbol = '<StackTrace>';
		var content_specialList = '';
		var aToken = '';

		if (NOT IsBoolean(bool_asHTML)) {
			bool_asHTML = false;
		}
		
		if (NOT IsBoolean(bool_includeStackTrace)) {
			bool_includeStackTrace = false;
		}
		
		if (NOT bool_asHTML) {
			_content = '';
		}

		for (e in _error) {
			if (FindNoCase('<#e#>', _ignoreList) eq 0) {
				try {
					v = _error[e];
				} catch (Any ee) {
					v = '--- ERROR --';
				}

				if (FindNoCase('<#e#>', _StackTraceSymbol) neq 0) {
					if (NOT bool_asHTML) {
						content_specialList = content_specialList & '#e#=#v#, ' & Chr(13);
					} else {
						v = '<textarea cols="160" rows="10" readonly style="font-size: 10px;">#v#</textarea>';
						content_specialList = content_specialList & '<li><b>#e#</b>&nbsp;#v#</li>';
					}
				} else if (IsSimpleValue(v)) {
					if (NOT bool_asHTML) {
						_content = _content & '#e#=#v#,' & Chr(13);
					} else {
						_content = _content & '<li><b>#e#</b>&nbsp;#v#</li>';
					}
				} else {
					try {
						if (NOT bool_asHTML) {
							_content = _content & '#e#=#StructExplainer(v, bool_asHTML, bool_includeStackTrace)#,' & Chr(13);
						} else {
							_content = _content & '<li><b>#e#</b>&nbsp;#StructExplainer(v, bool_asHTML, bool_includeStackTrace)#</li>';
						}
					} catch (Any e2) {
					}
				}
			}
		}
		if (bool_includeStackTrace) {
			nTagStack = ArrayLen(_error.TAGCONTEXT);
			if (NOT bool_asHTML) {
				_content = _content &	'The contents of the tag stack are: nTagStack = [#nTagStack#], ' & Chr(13);
			} else {
				_content = _content &	'<li><p><b>The contents of the tag stack are: nTagStack = [#nTagStack#] </b>';
			}
			if (nTagStack gt 0) {
				for (i = 1; i neq nTagStack; i = i + 1) {
					bool_isError = false;
					try {
						sCurrent = _error.TAGCONTEXT[i];
					} catch (Any e2) {
						bool_isError = true;
					}
					if (NOT bool_isError) {
						sMiscList = '';
						for (sMisc in sCurrent) {
							if (NOT bool_asHTML) {
								sMiscList = ListAppend(sMiscList, ' [#sMisc#=#sCurrent[sMisc]#] ', ' | ') & Chr(13);
							} else {
								sMiscList = sMiscList & '<b><small>[#sMisc#=#sCurrent[sMisc]#]</small></b><br>';
							}
						}
						if (NOT bool_asHTML) {
							_content = _content & sMiscList & '.' & Chr(13);
						} else {
							_content = _content & '<br>' & sMiscList & '.';
						}
					}
				}
			}
			if (bool_asHTML) {
				_content = _content & '</p></li>';
			}
			_content = _content & content_specialList;
			if (bool_asHTML) {
				_content = _content & '</ul>';
			} else {
				_content = _content & ',' & Chr(13);
			}
		}
		
		return _content;
	}

	function explainError(_error, bool_asHTML) {
		return _explainError(_error, bool_asHTML, false);
	}

	function explainErrorWithStack(_error, bool_asHTML) {
		return _explainError(_error, bool_asHTML, true);
	}
</cfscript>
