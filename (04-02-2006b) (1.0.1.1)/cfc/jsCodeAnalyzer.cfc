<cfcomponent displayname="jsCodeAnalyzer" output="No" extends="commonCode">
	<!--- 
		The problems with this approach surrounds the collisions with names of things that ought not be manipulated such as names of var's.
		A better approach would be to perform a lexical analysis of each item within a body of JavaScript source to determine how each item
		is being used and then to only act upon those items that should be acted upon through the use of some kind of tree data structure.
	 --->
	<cfscript>
		this.jsCodeArray = -1;
		this.aStruct = -1;
		this.const_function_symbol = 'function';
		this.qQuery = -1;
		this.qQuery2 = -1;
		this.qQuery3 = -1;
		this.qQuery3a = -1;
		this.shortNameChars = 'abcdefghijklmnopqrstuvwxyz0123456789';
		
		function init() {
			this.jsCodeArray = ArrayNew(1);
			this.aStruct = StructNew();
			this.aStruct.functions = ArrayNew(1);
			this.aStruct.instances = ArrayNew(1);
						
			return this;
		}
		
		function nextShortNameBasedOn(aName) {
			var i = -1;
			var x = -1;
			var y = -1;
			var leftMostChar = '';
			var leftMostChar2 = '';
			var rightMostChar = '';
			if (Len(aName) eq 0) {
				aName = '$';
			} else {
				rightMostChar = Right(aName, 1);
				if (rightMostChar eq '$') {
					aName = aName & Left(this.shortNameChars, 1);
				} else {
					i = Find(rightMostChar, this.shortNameChars);
					if (i gt 0) {
						x = -1;
						if ((i + 1) gt Len(this.shortNameChars)) {
							i = 0;
							x = 0;
						}
						leftMostChar = Left(aName, Len(aName) + x);
						if (Len(leftMostChar) gt 1) {
							leftMostChar2 = Right(leftMostChar, 1);
							if (leftMostChar2 eq '9') {
								y = Find(leftMostChar2, this.shortNameChars);
								if ((y + 1) gt Len(this.shortNameChars)) {
									y = 0;
								}
								leftMostChar2 = Mid(this.shortNameChars, y + 1, 1);
								leftMostChar = Left(leftMostChar, Len(leftMostChar) - 1) & leftMostChar2;
							}
						}
						aName = leftMostChar & Mid(this.shortNameChars, i + 1, 1);
					}
				}
			}
			return aName;
		}
		
		function isNameShortAlready(aName) {
			var bool = ( (Find('$', aName) gt 0) AND (Len(aName) lte 4) );
		//	writeOutput('isNameShortAlready(#aName#) = [#bool#]<br>');
			return bool;
		}
		
		function analyzeThis(jsCode) {
			var xPos = 1;
			var yPos = -1;
			var iPos = -1;
			var aTok = '';
			var aTok2 = '';
			var i = -1;
			var n = -1;
			var j = -1;
			var aStruct = -1;
			var _aStruct = -1;
			var aStruct2 = -1;
			var aShortName = '';
			var bool_shortNameOkay = false;
			var whiteSpaceToSkip = -1;
			var _jsCode = '';

			var x1 = -1;
			var x2 = -1;
			var x3 = -1;
			
			this.jsCodeArray[ArrayLen(this.jsCodeArray) + 1] = jsCode;
			while (xPos neq 0) {
				xPos = REFindNoCase(this.const_function_symbol & '\s', jsCode, xPos);
				if (xPos gt 0) {
					xPos = xPos - Len(this.const_function_symbol);
					yPos = REFind('\(.*\)', jsCode, xPos + Len(this.const_function_symbol));
					if (yPos gt 0) {
						aTok = Trim(Mid(jsCode, xPos, yPos - xPos + 1));
						iPos = FindNoCase(this.const_function_symbol, aTok, 1);
						if (iPos gt 0) {
							aTok = Right(aTok, Len(aTok) - (iPos + Len(this.const_function_symbol)));
							aTok = Replace(aTok, '(', '');
						}
						if (Len(aTok) gt 0) {
							aStruct = StructNew();
							aStruct.aTok = aTok;
							aStruct.xPos = xPos + Len(this.const_function_symbol);
							aStruct.count = -1;
							this.aStruct.functions[ArrayLen(this.aStruct.functions) + 1] = aStruct;
						}
						xPos =yPos + 1;
					}
				}
			}
			// Perform Frequency Analysis for each function found in the prior pass...
			n = ArrayLen(this.aStruct.functions);
			for (i = 1; i lte n; i = i + 1) {
				aTok = '';
				xPos = 1;
				while (xPos neq 0) {
					aStruct = this.aStruct.functions[i];
					xPos = REFindNoCase('\s' & Replace(aStruct.aTok, '$', '\$', 'all'), jsCode, xPos);
					if (xPos gt 0) {
						aTok = Trim(Mid(jsCode, xPos, Len(aStruct.aTok) + 1));
						aTok2 = Trim(Mid(jsCode, aStruct.xPos + Len(this.const_function_symbol), Len(aStruct.aTok) + 1));
						for (j = 1; j lte n; j = j + 1) {
							_aStruct = this.aStruct.functions[j];
							if (_aStruct.aTok eq aTok2) {
								if (_aStruct.count lt 0) {
									_aStruct.count = 0;
								}
								_aStruct.count = _aStruct.count + 1;
								break;
							}
						}
						aStruct2 = StructNew();
						aStruct2.aTok = aStruct.aTok;
						aStruct2.xPos = xPos;
						this.aStruct.instances[ArrayLen(this.aStruct.instances) + 1] = aStruct2;
						writeOutput('xPos = [xPos=#xPos#] [aStruct.aTok=#aStruct.aTok#] [aTok=#aTok#] [aStruct.xPos=#aStruct.xPos#] [<b>#aTok2#</b>]<br>');
						xPos = xPos + Len(aStruct.aTok) + 1;
					}
				}
			}
			this.qQuery = QueryNew('id, aTok, cnt, newTok', 'integer, varchar, integer, varchar');
			for (i = 1; i lte n; i = i + 1) {
				aStruct = this.aStruct.functions[i];
				QueryAddRow(this.qQuery);
				QuerySetCell(this.qQuery, 'id', this.qQuery.recordCount, this.qQuery.recordCount);
				QuerySetCell(this.qQuery, 'aTok', aStruct.aTok, this.qQuery.recordCount);
				QuerySetCell(this.qQuery, 'cnt', aStruct.count, this.qQuery.recordCount);
				QuerySetCell(this.qQuery, 'newTok', '', this.qQuery.recordCount);
			}
		//	writeOutput(cf_dump(this.qQuery, 'this.qQuery', false));
			safely_execSQL('this.qQuery2', '', "SELECT * FROM this.qQuery ORDER BY cnt DESC");
		//	writeOutput('[Request.dbError=#Request.dbError#]<br>');
			if (Request.dbError) {
				writeOutput(Request.explainErrorHTML);
			}
		//	writeOutput(cf_dump(this.qQuery2, 'A. this.qQuery2', false));
			
			aShortName = '';
			for (i = 1; i lte this.qQuery2.recordCount; i = i + 1) {
				if (NOT isNameShortAlready(this.qQuery2.aTok[i])) {
					aShortName = nextShortNameBasedOn(aShortName);
				//	writeOutput('A. aShortName = [#aShortName#]<br>');
		
					bool_shortNameOkay = false;
					while (NOT bool_shortNameOkay) {
						safely_execSQL('qNewNames1', '', "SELECT * FROM this.qQuery2 WHERE (aTok = '#aShortName#') OR (newTok = '#aShortName#') ORDER BY cnt DESC");
						if (Request.dbError) {
							writeOutput(Request.explainErrorHTML);
						}
					//	writeOutput(cf_dump(qNewNames1, 'qNewNames1', false));
						if ( (IsQuery(qNewNames1)) AND (qNewNames1.recordCount gt 0) ) {
							aShortName = nextShortNameBasedOn(aShortName);
						//	writeOutput('A.1. aShortName = [#aShortName#]<br>');
						} else {
							bool_shortNameOkay = true;
						}
					}
					this.qQuery2.newTok[i] = aShortName;
				} else {
					this.qQuery2.newTok[i] = this.qQuery2.aTok[i];
				}
			}

			writeOutput(cf_dump(this.qQuery2, 'B. this.qQuery2', false));
			
			// sort the instances in increasing order...
			this.qQuery3 = QueryNew('id, aTok, xPos', 'integer, varchar, integer');
			n = ArrayLen(this.aStruct.instances);
			for (i = 1; i lte n; i = i + 1) {
				aStruct = this.aStruct.instances[i];
				QueryAddRow(this.qQuery3);
				QuerySetCell(this.qQuery3, 'id', this.qQuery3.recordCount, this.qQuery3.recordCount);
				QuerySetCell(this.qQuery3, 'aTok', aStruct.aTok, this.qQuery3.recordCount);
				QuerySetCell(this.qQuery3, 'xPos', aStruct.xPos, this.qQuery3.recordCount);
			}
		//	writeOutput(cf_dump(this.qQuery3, 'this.qQuery', false));
			safely_execSQL('this.qQuery3a', '', "SELECT * FROM this.qQuery3 ORDER BY xPos");
		//	writeOutput('[Request.dbError=#Request.dbError#]<br>');
			if (Request.dbError) {
				writeOutput(Request.explainErrorHTML);
			}
		//	writeOutput(cf_dump(this.qQuery3a, 'A. this.qQuery3a', false));
			
			_jsCode = jsCode;
			n = this.qQuery3a.recordCount;
			for (j = n; j gte 1; j = j - 1) {
				aTok = Mid(_jsCode, this.qQuery3a.xPos[j], Len(this.qQuery3a.aTok[j]) + 1);
				
				for (i = 1; i lte Len(aTok); i = i + 1) {
					if (REFind('\s', Mid(aTok, i, Len(aTok) - i + 1), i) eq 0) {
						whiteSpaceToSkip = i - 1;
					//	writeOutput('WhiteSpace to skip over is [#whiteSpaceToSkip#] for aTok = [#aTok#]. ');
						break;
					}
				}

				safely_execSQL('qGetNewName', '', "SELECT * FROM this.qQuery2 WHERE (aTok = '#this.qQuery3a.aTok[j]#')");
				if (Request.dbError) {
					writeOutput(Request.explainErrorHTML);
				} else {
					if (this.qQuery3a.aTok[j] neq Trim(qGetNewName.newTok)) {
						x1 = Len(_jsCode) - (this.qQuery3a.xPos[j] + whiteSpaceToSkip + Len(this.qQuery3a.aTok[j]));
					//	writeOutput('<b><u>|1|</u></b> this.qQuery3a.aTok[#j#] = [#this.qQuery3a.aTok[j]#], qGetNewName.newTok = [#qGetNewName.newTok#], Len(_jsCode) = [#Len(_jsCode)#], [#this.qQuery3a.xPos[j]#] [#whiteSpaceToSkip#] [#Len(this.qQuery3a.aTok[j])#] = [#x1#]<br>');
						try {
							x2 = Left(_jsCode, this.qQuery3a.xPos[j] + whiteSpaceToSkip - 1);
					//		writeOutput('<b>A1:</b><textarea class="textClass" cols="120" readonly rows="10">#x2#</textarea><br>');
							x3 = Right(_jsCode, x1 + 1);
					//		writeOutput('<b>A2:</b><textarea class="textClass" cols="120" readonly rows="10">#x3#</textarea><br><hr align="left" width="80%" color="blue">');
							_jsCode = x2 & Trim(qGetNewName.newTok) & x3;
					//		writeOutput('<b>A3:</b><textarea class="textClass" cols="120" readonly rows="10">#_jsCode#</textarea><br><hr align="left" width="80%" color="red">');
						} catch (Any e) {
							writeOutput('<span class="errorStatusBoldClass">Failure to adjust the code during the final step of the process.</span><br>');
							break;
						}
					}
				}

			//	writeOutput('this.qQuery3a.aTok[#j#] = [#this.qQuery3a.aTok[j]#], this.qQuery3a.xPos[#j#] = [#this.qQuery3a.xPos[j]#] [<b>#aTok#</b>]<br>');
			}
			this.jsCodeArray[ArrayLen(this.jsCodeArray) + 1] = _jsCode;
		}
	</cfscript>
</cfcomponent>
