<!--- 
	Random Password Generator
Last Updated		: 10/8/2009
Website				: http://www.experimental-playground.com
--->
<cfcomponent name="pw" output="false">

	<cffunction name="init" returntype="pw">
		<cfreturn this />
	</cffunction>

	<!--- generates a random password with special characters of the length provided --->
	<cffunction name="generatePassword" access="public" returntype="string">
		<cfargument name="pwLen" type="numeric" default="10" required="false" hint="length of password to generate"/>
		<cfargument name="bUCase" type="boolean" default="true" required="false" hint="allow upper case letters"/>
		<cfargument name="bLCase" type="boolean" default="true" required="false" hint="allow lower case letters" />
		<cfargument name="bNumbers" type="boolean" default="true" required="false" hint="allow numbers" />
		<cfargument name="bSpecials" type="boolean" default="true" required="false" hint="allow special characters" />
		<cfscript>
			var pw = "";
			var chrPass = 0;
			var rangeLO = 33;
			var rangeHI = 126;
			if(bUCase OR bLCase OR bNumbers OR bSpecials){
				do{
					chrPass = RandRange(rangeLO,rangeHI);
					if((arguments.bUCase eq false) AND (chrPass gte 65 AND chrPass lte 90)){chrPass = 0;}
					if((arguments.bLCase eq false) AND (chrPass gte 97 AND chrPass lte 122)){chrPass = 0;}
					if((arguments.bNumbers eq false) AND (chrPass gte 48 AND chrPass lte 57)){chrPass = 0;}
					if((arguments.bSpecials eq false) AND ((chrPass gte 33 AND chrPass lte 47) OR (chrPass gte 58 AND chrPass lte 64) OR (chrPass gte 91 AND chrPass lte 96) OR (chrPass gte 123 AND chrPass lte 126))){chrPass = 0;}
					if(chrPass gt 0){pw = pw & #Chr(chrPass)#;}
								
				}while(len(pw) lt arguments.pwLen);
			}else{
				pw = "ChangeMePlease!";
			}
			return pw;
		</cfscript>
	</cffunction>
    	
</cfcomponent>