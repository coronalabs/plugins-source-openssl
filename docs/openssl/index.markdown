# Library.OpenSSL.*

> --------------------- ------------------------------------------------------------------------------------------
> __Type__              [provider][api.type.CoronaProvider]
> __Revision__          [REVISION_LABEL](REVISION_URL)
> __Keywords__          openssl, security
> __Sample code__       
> __See also__          [Marketplace](http://www.coronalabs.com/store/plugin)
> __Availability__      Pro, Enterprise
> --------------------- ------------------------------------------------------------------------------------------

## Overview

The OpenSSL plugin provides access to the OpenSSL library, as exposed by

George Zhao's

https://github.com/zhaozg/lua-openssl

OpenSSL's documentation is available here:

http://www.openssl.org/docs/

## Platforms

The following platforms are supported:

* Android
* iOS

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
