/*
The MIT License (MIT)

Copyright (c) 2014 Lyle Svendsen (@lylesvendsen)

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
associated documentation files (the "Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the
following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial
portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT
NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE
OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

Special Thanks To Olson: 
This script was made available with permission from Olson, a U.S. based loyalty and brand marketing firm. http://olson.com

*/

component displayname="cftoxml" accessors="true" output="false"
{
	property name="arrayElementDefault" type="string" default="element";

	
	public string function getXML(
		required any sourceVar
		,string rootElement=""
		,struct propertyVars={}
		,boolean docHeader=true
	) {
		
		local.response = "";
		local.propertyVars = duplicate(arguments.propertyVars);
		
		if(arguments.docHeader){
			local.response &= '<?xml version="1.0" encoding="UTF-8"?>';
		}
		
		if(!len(trim(arguments.rootElement))){
			arguments.rootElement = "element";
		}
		
		if(IsSimpleValue(arguments.sourceVar)){
			local.data = xmlformat(arguments.sourceVar);
		}else if(isObject(arguments.sourceVar)){
			local.sourceVar = objectToStuct(arguments.sourceVar);
			structAppend(local.propertyVars, getIdProperties(local.sourceVar), false);
			structAppend(local.propertyVars, {type:"complex"}, false);
			structAppend(local.propertyVars, {objecttype:listLast(getMetaData(arguments.sourceVar).name,".")}, false);
			local.data = getStructXML(local.sourceVar);
		}else if(isValid("struct", arguments.sourceVar)){
			structAppend(local.propertyVars, getIdProperties(arguments.sourceVar), false);
			structAppend(local.propertyVars, {type:"complex"}, false);
			local.data = getStructXML(arguments.sourceVar);
		}else if(isValid("array", arguments.sourceVar)){
			structAppend(local.propertyVars, {length:arraylen(arguments.sourceVar), type:"array"}, false);
			local.data = getArrayXML(sourceVar:arguments.sourceVar, rootElement:arguments.rootElement);
		}else if(isValid("query", arguments.sourceVar)){
			local.data = getArrayXML(sourceVar:queryToArray(arguments.sourceVar), rootElement:arguments.rootElement);
		}else{
			local.data = "Unsupported Data Type";
		}
		
		local.response &= '<#lcase(arguments.rootElement)##getProperyString(local.propertyVars)#>';
		local.response &= local.data;
		local.response &= '</#lcase(arguments.rootElement)#>';
		
		return local.response;
	}
	
	
	
	public string function getStructXML(
		 required struct sourceVar
	){
	
		local.response = "";
		
		for(local.key IN arguments.sourceVar){
			local.response &= getXML(sourceVar:arguments.sourceVar[local.key], rootElement:local.key, docHeader:false);
		}
		
		return local.response;
	}
	
	
	public string function getArrayXML(
		 required array sourceVar
		,string rootElement=""
	){
	
		local.response = "";
		local.itemName = getArrayElementDefault();
		local.index = 0;
		
		if(right(arguments.rootElement,3) == "ies"){
			local.itemName = left(arguments.rootElement, (len(arguments.rootElement)-3)) & "y";
		}else if(right(arguments.rootElement,1) == "s" && right(arguments.rootElement,2) != "ss"){
			local.itemName = left(arguments.rootElement, (len(arguments.rootElement)-1));
		}
		
		
		
		for(local.aryItem IN arguments.sourceVar){
			local.propertyVars.index = local.index;
			local.response &= getXML(sourceVar:local.aryItem, rootElement:local.itemName, docHeader:false, propertyVars:local.propertyVars);
			local.index += 1;
		}
		
		return local.response;
	}
	
	
	public string function getProperyString(
		 required struct propertyVars
	){
	
		local.response = "";
	
		for(local.key IN arguments.propertyVars){
			local.response &= " " & lcase(local.key) & "=""" & xmlformat(arguments.propertyVars[local.key]) & """";
		}
		
		return local.response;
	}
	
	public struct function getIdProperties(
		 required struct sourceVar
	){
	
		local.properties = {};
		
		for(local.key IN arguments.sourceVar){
			if(right(local.key,2) == "id"){
				local.properties[local.key] = lcase(arguments.sourceVar[local.key]);
			}
		}
		
		return local.properties;
	}
	
	
	
	function queryToArray(required query q){
		local.aryResults = arraynew(1);
		local.cols = ListtoArray(lcase(arguments.q.columnlist));
		local.col = 1;
		
		for(local.row = 1; local.row LTE arguments.q.recordcount; local.row = local.row + 1){
			local.thisRow = structnew();
			for(local.col = 1; local.col LTE arraylen(local.cols); local.col += 1){
				local.thisRow[local.cols[local.col]] = arguments.q[local.cols[local.col]][local.row];
			}
			arrayAppend(local.aryResults,duplicate(local.thisRow));
		}
		return(local.aryResults);
	}
	
	
	public struct function objectToStuct_cfToXml(){
		local.result = {};
		local.properties = [];
		// Extract Property Names
		for(local.data IN getMetaData(this).properties){
			arrayAppend(local.properties, local.data.name);
		}
		
		// Set Property Values to Struct
		for(local.propName IN local.properties){
			if(structKeyExists(this, "get" & local.propName)){
				local.getter = this["get" & local.propName];
				local.result[lcase(local.propName)] = local.getter();
			}else{
				local.result[lcase(local.propName)] = "";
			}
		}
		
		return result;
	}
	
	
	public struct function objectToStuct(required any obj){
		local.result = {};
		local.properties = [];
		
		arguments.obj.objectToStuct_cfToXml = variables.objectToStuct_cfToXml;
		
		return arguments.obj.objectToStuct_cfToXml();
	}
	

	
}
