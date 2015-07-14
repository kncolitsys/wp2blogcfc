<!--- 
	Wordpress2BlogCFC Migration Tool
	Wordpress Component
Last Updated		: 10/8/2009
Website				: http://www.experimental-playground.com
--->
<cfcomponent name="wp">

	<cfset variables.wpDSN = "" />
	<cfset variables.wpPre = "" />
	
	<cffunction name="init" access="public" returntype="any">
    	<cfargument name="wpDSN" type="string" required="true" hint="wordpress datasource" />
		<cfargument name="wpPre" type="string" required="false" default="wp_" hint="wordpress table prefix" />
        <cfset variables.wpDSN = arguments.wpDSN />
        <cfset variables.wpPre = arguments.wpPre />
        
    	<cfreturn this />
    </cffunction>
	
	<cffunction name="getTaxonomy" access="public" returntype="query">
		<cfargument name="taxonomy" type="string" required="true" />
		<cfset var sql = QueryNew("") />
		<cfquery name="sql" datasource="#variables.wpDSN#">
			SELECT
				wt.term_id AS categoryid,
				LEFT(wt.name,50) AS categoryname,
				LEFT(wt.slug,50) AS categoryalias
			FROM
				#variables.wpPre#terms AS wt
					INNER JOIN
				#variables.wpPre#term_taxonomy AS wtt
					ON wtt.term_id = wt.term_id
			WHERE
				wtt.taxonomy = <cfqueryparam value="#arguments.taxonomy#" cfsqltype="cf_sql_varchar" />
		</cfquery>
		<cfreturn sql />
	</cffunction>
	
	<cffunction name="getCategoryByPost" access="public" returntype="query">
		<cfargument name="postID" type="numeric" required="true" />
		
		<cfset var sql = QueryNew("") />
		<cfquery name="sql" datasource="#variables.wpDSN#">
			SELECT
				t.name AS category
			FROM
				#variables.wpPre#term_relationships AS tr
					INNER JOIN
				#variables.wpPre#term_taxonomy AS tt
					ON tt.term_taxonomy_id = tr.term_taxonomy_id
					INNER JOIN
				#variables.wpPre#terms AS t
					ON t.term_id = tt.term_id
			WHERE
				tr.object_id = <cfqueryparam value="#arguments.postID#" cfsqltype="cf_sql_integer" />
		</cfquery>
		<cfreturn sql />
	</cffunction>

	<cffunction name="getPosts" access="public" returntype="query">
		<cfset var sql = QueryNew("") />
		<cfquery name="sql" datasource="#variables.wpDSN#">
			SELECT
				p.id,
				LEFT(p.post_title,100) AS title,
				p.post_content AS body,
				p.post_date AS posted,
				LEFT(p.post_name,100) AS alias,
				u.user_login AS username,
				CASE p.comment_status
					WHEN 'open' THEN 1
					ELSE 0
				END AS allowcomments
			FROM
				#variables.wpPre#posts AS p
					INNER JOIN
				#variables.wpPre#users AS u
					ON u.id = p.post_author
			WHERE
				p.post_status = 'publish'
				AND p.post_type = 'post'
		</cfquery>
		<cfreturn sql />
	</cffunction>
	
	<cffunction name="getPages" access="public" returntype="query">
		<cfset var sql = QueryNew("") />
		<cfquery name="sql" datasource="#variables.wpDSN#">
			SELECT
				LEFT(p.post_title,100) AS title,
				p.post_content AS body,
				LEFT(p.post_name,100) AS alias
			FROM
				#variables.wpPre#posts AS p
			WHERE
				p.post_status = 'publish' 
				AND p.post_type = 'page'
		</cfquery>
		<cfreturn sql />
	</cffunction>
	
	<cffunction name="getUsers" access="public" returntype="query">
		<cfset var sql = QueryNew("") />
		<cfquery name="sql" datasource="#variables.wpDSN#">
			SELECT
				user_login AS username,
				display_name AS name
			FROM
				#variables.wpPre#users
			WHERE
				user_status = 0
				and user_login <> 'admin'
		</cfquery>
		<cfreturn sql />
	</cffunction>
	
	<cffunction name="getCommentsByPost" access="public" returntype="query">
		<cfargument name="postID" type="numeric" required="true" />
		
		<cfset var sql = QueryNew("") />
		<cfquery name="sql" datasource="#variables.wpDSN#">
			SELECT
				c.comment_author AS name,
				c.comment_author_email AS email,
				c.comment_author_url AS website,
				c.comment_content AS comment,
				c.comment_date AS posted
			FROM
				#variables.wpPre#comments AS c
					INNER JOIN
				#variables.wpPre#posts AS p
					ON p.id = c.comment_post_id
			WHERE
				p.id = <cfqueryparam value="#arguments.postID#" cfsqltype="cf_sql_integer" />
		</cfquery>
		<cfreturn sql />
	</cffunction>
	
	<cffunction name="getLinks" access="public" returntype="query">
		<cfargument name="categoryID" type="numeric" required="true" />
		
		<cfset var sql = QueryNew("") />
		<cfquery name="sql" datasource="#variables.wpDSN#">
			SELECT
				l.link_url,
				l.link_name,
				l.link_description
			FROM
				#variables.wpPre#terms AS t
					INNER JOIN
				#variables.wpPre#term_taxonomy AS tt
					ON tt.term_id = t.term_id
					INNER JOIN
				#variables.wpPre#term_relationships AS tr
					ON tr.term_taxonomy_id = tt.term_taxonomy_id
					INNER JOIN
				#variables.wpPre#links AS l
					ON l.link_id = tr.object_id
			WHERE
				tt.taxonomy = 'link_category'
				AND t.term_id = <cfqueryparam value="#arguments.categoryID#" cfsqltype="cf_sql_integer" />
		</cfquery>
		<cfreturn sql />
	</cffunction>
</cfcomponent>