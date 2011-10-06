##! Software identification and extraction for HTTP traffic.

@load base/frameworks/software/main

module HTTP;

export {
	redef enum Software::Type += {
		SERVER,
		APPSERVER,
		BROWSER,
	};

	## The pattern of HTTP User-Agents which you would like to ignore.
	const ignored_user_agents = /NO_DEFAULT/ &redef;
}

event http_header(c: connection, is_orig: bool, name: string, value: string) &priority=2
	{
	if ( is_orig )
		{
		if ( name == "USER-AGENT" && ignored_user_agents !in value )
			Software::found(c$id, Software::parse(value, c$id$orig_h, BROWSER));
		}
	else
		{
		if ( name == "SERVER" )
			Software::found(c$id, Software::parse(value, c$id$resp_h, SERVER));
		else if ( name == "X-POWERED-BY" )
			Software::found(c$id, Software::parse(value, c$id$resp_h, APPSERVER));
		else if ( name == "MICROSOFTSHAREPOINTTEAMSERVICES" )
			{
			value = cat("SharePoint/", value);
			Software::found(c$id, Software::parse(value, c$id$resp_h, APPSERVER));
			}
		}
	}