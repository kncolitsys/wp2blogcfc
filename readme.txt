
Name: Wordpress to BlogCFC (wp2blogcfc)
Purpose: A coldfusion migration script for transferring Wordpress Blogs to BlogCFC
Date: October 8th 2009
Version: 1.0

	
	
DETAILS:
=============================================
Wordpress to BlogCFC (wp2blogcfc) is a tool that allows for easy migration from Wordpress to BlogCFC.

SETUP:
=============================================
Before running the migration script, you will need to configure a few settings in the "wp2blogcfc.cfm" script.

migrator.wordpress.dsn = "your wordpress datasource";
migrator.wordpress.pre = "wp_"; /* wordpress table prefix, wp_ is the default */

migrator.blogcfc.dsn = "your blogcfc datasource";
migrator.blogcfc.pre = "tbl"; /* blogcfc table prefix, tbl is the default */
migrator.blogcfc.blog = "blogname"; /* Default is the default */



VERSION:
=============================================
1.0 - Initial Release - 2009/10/08

Structures that are currently migrated are:
	Users
	Pages
	Categories
	Posts
	Comments
	Link Categories
	Links

Wordpress Link Categories are mapped into BlogCFC as pages, with the links as the page's content.

Wordpress User passwords are reset to a random password that will be available to you in the migrator structure dump on migration completion.