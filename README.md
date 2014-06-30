CFtoXML
=======

**CFtoXML converts coldfusion variables into an XML Document.**

####Features:
- Recursively converts structures, arrays, object properties with getters and simple values.
- Struct key names that end with "id" are added as element properties.
- Object getter introspection. Finds an object getters and adds their values as elements.
- XML document header optionally prepended
- Auto sub-element naming of arrays with plural names
- Lowercase element naming
- Adds a base 0 index property to array elements 
- Adds object type to element properties

####Usage Example:
```
<cfsetting enableCFoutputOnly="true" showDebugOutput="false"/>
<cfscript>
	variables.ServiceCFtoXML = createObject("component", "CFtoXML");
	
	variables.testData = {
		members:[
			{
				id:12345
				,fname:"Lyle"
				,lname:"Svendsen"
				,phone:"612-867-5309"
				,permissions:[1,4,6,7,8]
			}
			,{
				id:56789
				,fname:"Mary"
				,lname:"OldSpice"
				,phone:"866-617-4247"
				,permissions:[1,3,6,8]
			}
		]
		,action:"sendemail"
		,attempts:3
	};
	
	// Get XML String
	variables.strXML= variables.ServiceCFtoXML.getXML(sourceVar:variables.testData, rootElement:"response");
</cfscript>
<cfoutput><cfcontent type="application/xml; charset=UTF-8" reset="true">#variables.strXML#</cfoutput><cfabort />
```

####Output Example:
```
<response type="complex">
	<members length="2" type="array">
		<member id="12345" index="0" type="complex">
			<phone>612-867-5309</phone>
			<fname>Lyle</fname>
			<permissions length="5" type="array">
				<permission index="0">1</permission>
				<permission index="1">4</permission>
				<permission index="2">6</permission>
				<permission index="3">7</permission>
				<permission index="4">8</permission>
			</permissions>
			<id>12345</id>
			<lname>Svendsen</lname>
		</member>
		<member id="56789" index="1" type="complex">
			<phone>866-617-4247</phone>
			<fname>Mary</fname>
			<permissions length="4" type="array">
				<permission index="0">1</permission>
				<permission index="1">3</permission>
				<permission index="2">6</permission>
				<permission index="3">8</permission>
			</permissions>
			<id>56789</id>
			<lname>OldSpice</lname>
		</member>
	</members>
	<attempts>3</attempts>
	<action>sendemail</action>
</response>
```

I've only had a chance to run this on CF10, but off the top of my head I can't think of a reason it won't work in cf9. Let me know. ;-)

**Feedback Welcome!**

**Special Thanks To Olson:**
This script was made available with permission from Olson, a U.S. based loyalty and brand marketing firm. http://olson.com
