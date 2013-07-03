# Library.OpenSSL.*

> --------------------- ------------------------------------------------------------------------------------------
> __Type__              [library][api.type.library]
> __Revision__          [REVISION_LABEL](REVISION_URL)
> __Keywords__          openssl, security
> __Sample code__       [Sample code](https://github.com/coronalabs/plugins-sample-openssl)
> __See also__          [Marketplace](http://www.coronalabs.com/store/plugin)
> __Availability__      Pro, Enterprise
> --------------------- ------------------------------------------------------------------------------------------

## Overview

The OpenSSL plugin provides access to the OpenSSL library, as exposed by George Zhao's [lua-openssl](https://github.com/zhaozg/lua-openssl)

OpenSSL's documentation is available from [openssl.org](http://www.openssl.org/docs/)

## Gotchas

The OpenSSL plugin allows you to do secure socket communication in Lua using __luasec__. This wraps your insecure protocol in SSL. Please refer to the [samples](https://github.com/coronalabs/plugins-sample-openssl) in the Corona Labs GitHub repository. The __luasec__ sample explains how to create the server-side of the secure connection.

Note that HTTPS requests are done much more easily using [network.request()][api.library.network.request] - web documents shouldn’t be requested using __luasec__.

## Platforms

The following platforms are supported:

* Android
* iOS
* Mac
* Windows

## Syntax

	local openssl = require "plugin.openssl"

## Project Settings

### SDK

When you build using the Corona Simulator, the server automatically takes care of integrating the plugin into your project. 

All you need to do is add an entry into a `plugins` table of your `build.settings`. The following is an example of a minimal `build.settings` file:

``````
settings =
{
	plugins =
	{
		-- key is the name passed to Lua's 'require()'
		["plugin.openssl"] =
	},		
}
``````

## Sample Code

See the sample code provided with the Corona SDK.

## Support

More support is available from the Corona Labs team:

* [E-mail](mailto://sean@coronalabs.com)
* [Forum](http://forum.coronalabs.com/plugin/openssl)
* [Plugin Publisher](http://www.coronalabs.com)
