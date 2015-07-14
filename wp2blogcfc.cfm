<!--- 
	Wordpress2BlogCFC Migration Tool
Last Updated		: 10/8/2009
Website				: http://www.experimental-playground.com
--->
<!--- setup the migration settings before executing --->
<cfscript>
	migrator = StructNew();
	
	migrator.wordpress.dsn = "wordpressDSN";
	migrator.wordpress.pre = "wp_";
	
	migrator.blogcfc.dsn = "blogcfcDSN";
	migrator.blogcfc.pre = "tbl";
	migrator.blogcfc.blog = "Default";
	
	migrator.stats_categories = 0;
	migrator.stats_comments = 0;
	migrator.stats_links = 0;
 	migrator.stats_pages = 0;
	migrator.stats_posts = 0;

	migrator.stats_users = ArrayNew(1);
	
	migrator.errors = ArrayNew(1);
</cfscript>

<!--- wordpress object --->
<cfset objWP = createObject("component","cfc.wp").init(wpDSN = migrator.wordpress.dsn, wpPre = migrator.wordpress.pre) />
<!--- blogcfc object --->
<cfset objBC = createObject("component","cfc.bc").init(bcDSN = migrator.blogcfc.dsn, bcPre = migrator.blogcfc.pre) />
<!--- random password generator object --->
<cfset objPW = createObject("component","cfc.pw").init() />

<!--- get all wordpress users --->
<cfset wpUsers = objWP.getUsers() />
<!--- get all wordpress categories --->
<cfset wpCategories = objWP.getTaxonomy(taxonomy = 'category') />
<!--- get all wordpress link categories --->
<cfset wpLinkCategories = objWP.getTaxonomy(taxonomy = 'link_category') />
<!--- get all wordpress posts --->
<cfset wpPosts = objWP.getPosts() />
<!--- get all wordpress pages --->
<cfset wpPages = objWP.getPages() />

<!--- Step 1. --->
<!--- transfer wordpress users to blogcfc users. wp user passwords are MD5 hashed so we will not be able to keep the passwords --->
<cfloop query="wpUsers">
	<cftry>
		<!--- generate a random password for our users, we'll need to send them their passwords when the migration is done, or they can reset them --->
		<cfset newPW = objPW.generatePassword(pwLen = 8, bSpecials = false) />
		<!--- create the user --->
		<cfset objBC.createUser(username = wpUsers.username,
								name = wpUsers.name,
								password = newPW,
								blog = migrator.blogcfc.blog
								) />
		<cfset migrator.stats_users[wpUsers.currentRow][1] = wpUsers.username />
		<cfset migrator.stats_users[wpUsers.currentRow][2] = newPW />
		<cfcatch type="any">
			<cfset ArrayAppend(migrator.errors, "User - #wpUsers.username# - Fail") />
		</cfcatch>
	</cftry>
</cfloop>

<!--- Step 2. --->
<!--- transfer wordpress pages to blogcfc blogPages --->
<cfloop query="wpPages">
	<cftry>
		<cfset objBC.createPage(	blog = migrator.blogcfc.blog,
									title = wpPages.title,
									alias = wpPages.alias,
									body = wpPages.body
								) />
		<cfset migrator.stats_pages = migrator.stats_pages + 1 />
		<cfcatch type="any">
			<cfset ArrayAppend(migrator.errors, "Page - #wpPages.title# - Fail") />
		</cfcatch>
	</cftry>
</cfloop>

<!--- Step 3. --->
<!--- transfer wordpress categories taxonomy to blogcfc blogCategories --->
<cfloop query="wpCategories">
	<cftry>
		<cfset objBC.createCategory(	categoryName = wpCategories.categoryname,
										categoryAlias = wpCategories.categoryalias,
										blog = migrator.blogcfc.blog
									) />
		<cfset migrator.stats_categories = migrator.stats_categories + 1 />
		<cfcatch type="any">
			<cfset ArrayAppend(migrator.errors, "Category - #wpCategories.categoryname# - Fail") />
		</cfcatch>
	</cftry>
</cfloop>

<!--- Step 4. --->
<!--- transfer wordpress posts to blogcfc entries --->
<cfloop query="wpPosts">
	<cftry>
		<!--- fetch the categories for the post from wordpress by the post id. we can re-use wpCategories since we're done with it above --->
		<cfset wpCategories = objWP.getCategoryByPost(	postID = wpPosts.id ) />
		<!--- fetch the category information from blogcfc for each category returned from wordpress --->
		<cfset bcCategories = objBC.getCategoryByName(	categoryName = valueList(wpCategories.category,","), blog = migrator.blogcfc.blog ) />
		<!--- fetch the comments for the post --->
		<cfset wpComments = objWP.getCommentsByPost(	postID = wpPosts.id	) />
		<!--- import the post from wordpress to blogcfc --->
		<cftransaction>
			<cfset entryID = createUUID() />
			<cfset objBC.createBlogEntry(	id = entryID,
											title = wpPosts.title,
											body = wpPosts.body,
											posted = wpPosts.posted,
											alias = wpPosts.alias,
											username = wpPosts.username,
											blog = migrator.blogcfc.blog,
											allowcomments = wpPosts.allowcomments
										) />
			<cfloop query="bcCategories">
				<!--- link the entry to its applicable categories --->
				<cfset objBC.createBlogEntriesCategories(entryID = entryID, categoryID = bcCategories.categoryID) />
			</cfloop>
			
			<cfloop query="wpComments">
				<!--- create the blog comment and link it up --->
				<cfset objBC.createBlogComment(	entryidfk = entryid,
												name = wpComments.name,
												email = wpComments.email,
												comment = wpComments.comment,
												posted = wpComments.posted,
												website = wpComments.website
											) />
				<cfset migrator.stats_comments = migrator.stats_comments + 1 />
			</cfloop>
		</cftransaction>
		<cfset migrator.stats_posts = migrator.stats_posts + 1 />
		<cfcatch type="any">
			<cfset ArrayAppend(migrator.errors, "Post - #wpPosts.id# - #wpPosts.title# - Fail") />
		</cfcatch>
	</cftry>
</cfloop>

<!--- Step 5. --->
<!--- transfer wordpress link categories and their contained links into blogCFC pages + content --->
<cfloop query="wpLinkCategories">
	<!--- <cftry> --->
		<cfset wpLinks = objWP.getLinks(categoryID = wpLinkCategories.categoryid) />
		<cftransaction>
			<cfset linkPage = "" />
			<cfloop query="wpLinks">
				<cfset linkPage = listAppend(linkPage,"<a href=""#wpLinks.link_url#"">#wpLinks.link_name#</a> - #wpLinks.link_description#<br>"," ") /> 
			</cfloop>
			<cfset objBC.createPage(	blog = migrator.blogcfc.blog,
										title = wpLinkCategories.categoryname,
										alias = wpLinkCategories.categoryalias,
										body = linkPage
									) />
			<cfset migrator.stats_links = migrator.stats_links + 1 />
		</cftransaction>
		<!--- <cfcatch type="any">
			<cfset ArrayAppend(migrator.errors, "Link Catgory - #wpLinkCategories.categoryname# - Fail") />
		</cfcatch>
	</cftry> --->
</cfloop>
<cfdump var="#migrator#" />