<!--- 
	Wordpress2BlogCFC Migration Tool
Last Updated		: 10/8/2009
Website				: http://www.experimental-playground.com
--->
<cfcomponent name="bc">

	<cfset variables.bcDSN = "" />
	<cfset variables.bcPre = "" />
	
	<cffunction name="init" access="public" returntype="any">
    	<cfargument name="bcDSN" type="string" required="true" hint="blogcfc datasource" />
		<cfargument name="bcPre" type="string" required="false" default="tbl" hint="blogcfc table prefix" />
        <cfset variables.bcDSN = arguments.bcDSN />
        <cfset variables.bcPre = arguments.bcPre />
        
    	<cfreturn this />
    </cffunction>
	
	<cffunction name="createPage" access="public" returntype="void">
		<cfargument name="blog" type="string" required="false" default="Default" />
		<cfargument name="title" type="string" required="true" />
		<cfargument name="alias" type="string" required="true" />
		<cfargument name="body" type="string" required="true" />
		
		<cfset var sql = QueryNew("") />
		<cfquery name="sql" datasource="#variables.bcDSN#">
			INSERT INTO
				#variables.bcPre#blogpages( id,
											blog,
											title,
											alias,
											body)
				VALUES( <cfqueryparam value="#createUUID()#" cfsqltype="cf_sql_varchar" />,
						<cfqueryparam value="#arguments.blog#" cfsqltype="cf_sql_varchar" />,
						<cfqueryparam value="#arguments.title#" cfsqltype="cf_sql_varchar" />,
						<cfqueryparam value="#arguments.alias#" cfsqltype="cf_sql_varchar" />,
						<cfqueryparam value="#arguments.body#" cfsqltype="cf_sql_varchar" />
					)
		</cfquery>
		<cfreturn />
	</cffunction>
	
	<cffunction name="createUser" access="public" returntype="void">
		<cfargument name="username" type="string" required="true" />
		<cfargument name="name" type="string" required="false" />
		<cfargument name="password" type="string" required="true" />
		<cfargument name="blog" type="string" required="false" default="Default" />
		
		<cfset var sql = QueryNew("") />
		<cfquery name="sql" datasource="#variables.bcDSN#">
			INSERT INTO
				#variables.bcPre#users( username,
										name,
										password,
										blog
										)
				VALUES(	<cfqueryparam value="#arguments.username#" cfsqltype="cf_sql_varchar" />,
						<cfqueryparam value="#arguments.name#" cfsqltype="cf_sql_varchar" />,
						<cfqueryparam value="#arguments.password#" cfsqltype="cf_sql_varchar" />,
						<cfqueryparam value="#arguments.blog#" cfsqltype="cf_sql_varchar" />
						)
		</cfquery>
		<cfreturn />
	</cffunction>
	
	<cffunction name="createCategory" access="public" returntype="void">
		<cfargument name="categoryName" type="string" required="false" default="" />
		<cfargument name="categoryAlias" type="string" required="false" default="" />
		<cfargument name="blog" type="string" required="false" default="Default" />
	
		<cfset var sql = QueryNew("") />
		<cfquery name="sql" datasource="#variables.bcDSN#">
			INSERT INTO
				#variables.bcPre#blogcategories(	categoryid,
													categoryname,
													categoryalias,
													blog
												)
				VALUES(	<cfqueryparam value="#createUUID()#" cfsqltype="cf_sql_varchar" />,
						<cfqueryparam value="#arguments.categoryName#" cfsqltype="cf_sql_varchar" />,
						<cfqueryparam value="#arguments.categoryAlias#" cfsqltype="cf_sql_varchar" />,
						<cfqueryparam value="#arguments.blog#" cfsqltype="cf_sql_varchar" />
						)
		</cfquery>
		<cfreturn />
	</cffunction>
	
	<cffunction name="getCategoryByName" access="public" returntype="query">
		<cfargument name="categoryName" type="string" required="true" />
		<cfargument name="blog" type="string" required="true" />
		
		<cfset var sql = QueryNew("") />
		<cfquery name="sql" datasource="#variables.bcDSN#">
			SELECT
				categoryID,
				categoryName
				blog
			FROM
				#variables.bcPre#blogcategories
			WHERE
				categoryName IN (<cfqueryparam value="#arguments.categoryName#" cfsqltype="cf_sql_varchar" list="true" />)
				AND blog = <cfqueryparam value="#arguments.blog#" cfsqltype="cf_sql_varchar" />
		</cfquery>
		<cfreturn sql />
	</cffunction>
	
	<cffunction name="createBlogEntry" access="public" returntype="void">
		<cfargument name="id" type="string" required="true" />
		<cfargument name="title" type="string" required="false" default="" />
		<cfargument name="body" type="string" required="false" default="" />
		<cfargument name="posted" type="string" required="false" default="" />
		<cfargument name="alias" type="string" required="false" default="" />
		<cfargument name="username" type="string" required="false" default="" />
		<cfargument name="blog" type="string" required="false" default="" />
		<cfargument name="allowcomments" type="numeric" required="false" default="" />
		
		<cfset var sql = QueryNew("") />
		<cfquery name="sql" datasource="#variables.bcDSN#">
			INSERT INTO
				#variables.bcPre#blogentries(	id,
												title,
												body,
												posted,
												alias,
												username,
												blog,
												allowcomments,
												enclosure,
												filesize,
												mimetype,
												views,
												released,
												mailed,
												summary,
												subtitle,
												keywords,
												duration
											)
			VALUES(	<cfqueryparam value="#arguments.id#" cfsqltype="cf_sql_varchar" />,
					<cfqueryparam value="#arguments.title#" cfsqltype="cf_sql_varchar" />,
					<cfqueryparam value="#arguments.body#" cfsqltype="cf_sql_varchar" />,
					<cfqueryparam value="#arguments.posted#" cfsqltype="cf_sql_date" />,
					<cfqueryparam value="#arguments.alias#" cfsqltype="cf_sql_varchar" />,
					<cfqueryparam value="#arguments.username#" cfsqltype="cf_sql_varchar" />,
					<cfqueryparam value="#arguments.blog#" cfsqltype="cf_sql_varchar" />,
					<cfqueryparam value="#arguments.allowcomments#" cfsqltype="cf_sql_bit" />,
					'',
					0,
					'',
					0,
					1,
					1,
					'',
					'',
					'',
					''
				)
		</cfquery>
		<cfreturn />
	</cffunction>
	
	<cffunction name="createBlogEntriesCategories" access="public" returntype="void">
		<cfargument name="entryID" type="string" required="true" />
		<cfargument name="categoryID" type="string" required="true" />

		<cfset var sql = QueryNew("") />
		<cfquery name="sql" datasource="#variables.bcDSN#">
			INSERT INTO
				#variables.bcPre#blogentriescategories(	entryidfk,
														categoryidfk
														)
				VALUES(	<cfqueryparam value="#arguments.entryID#" cfsqltype="cf_sql_varchar" />,
						<cfqueryparam value="#arguments.categoryID#" cfsqltype="cf_sql_varchar" />
						)
		</cfquery>
		<cfreturn />
	</cffunction>
	
	<cffunction name="createBlogComment" access="public" returntype="void">
		<cfargument name="entryidfk" type="string" required="true" />
		<cfargument name="name" type="string" required="false" default="" />
		<cfargument name="email" type="string" required="false" default="" />
		<cfargument name="comment" type="string" required="false" default="" />
		<cfargument name="posted" type="string" required="false" default="" />
		<cfargument name="subscribe" type="string" required="false" default="1" />
		<cfargument name="website" type="string" required="false" default="" />
		<cfargument name="moderated" type="string" required="false" default="1" />
		<cfargument name="subscribeonly" type="string" required="false" default="0" />
		
		<cfset var sql = QueryNew("") />
		<cfquery name="sql" datasource="#variables.bcDSN#">
			INSERT INTO
				#variables.bcPre#blogcomments(	id,
												entryidfk,
												name,
												email,
												comment,
												posted,
												subscribe,
												website,
												moderated,
												killcomment,
												subscribeonly
												)
				VALUES(	<cfqueryparam value="#createUUID()#" cfsqltype="cf_sql_varchar" />,
						<cfqueryparam value="#arguments.entryidfk#" cfsqltype="cf_sql_varchar" />,
						<cfqueryparam value="#arguments.name#" cfsqltype="cf_sql_varchar" />,
						<cfqueryparam value="#arguments.email#" cfsqltype="cf_sql_varchar" />,
						<cfqueryparam value="#arguments.comment#" cfsqltype="cf_sql_varchar" />,
						<cfqueryparam value="#arguments.posted#" cfsqltype="cf_sql_varchar" />,
						<cfqueryparam value="#arguments.subscribe#" cfsqltype="cf_sql_varchar" />,
						<cfqueryparam value="#arguments.website#" cfsqltype="cf_sql_varchar" />,
						<cfqueryparam value="#arguments.moderated#" cfsqltype="cf_sql_varchar" />,
						<cfqueryparam value="#createUUID()#" cfsqltype="cf_sql_varchar" />,
						<cfqueryparam value="#arguments.subscribeonly#" cfsqltype="cf_sql_varchar" />
				)
		</cfquery>
		<cfreturn />
	</cffunction>
</cfcomponent>