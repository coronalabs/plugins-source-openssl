--------------------------------------------------------------------------------
-- Sample code is MIT licensed, see https://coronalabs.com/links/code/license
-- Copyright (C) 2016 Corona Labs Inc. All Rights Reserved.
--------------------------------------------------------------------------------

--
-- Demonstrates two ways to retrieve data from secure web servers 
--

local greeting = display.newText("luasec tests - see console for results", display.actualContentWidth/2, 20)

print( "plugin.openssl secure socket test start" )

local json = require('json')

-- required by plugin_luasec_ssl
local is_opensslv3 = true
local good, openssl = pcall(require, "plugin.opensslv3")
if not good then
	is_opensslv3 = false
	openssl = require("plugin.openssl")
end

local socket = require('socket')
local http = require('socket.http')
local ltn12 = require('ltn12')
local plugin_luasec_ssl = require('plugin_luasec_ssl')

local lua_openssl_version, lua_version, openssl_version = openssl.version()
print( "lua-openssl version: " .. lua_openssl_version, lua_version, openssl_version )

--------------------------------------------------------------------------------

local function test(serverName)

	print("test for server", serverName)

	print("Requesting secure web page on raw TCP socket from: " .. serverName)

	-- TLS/SSL client parameters
	local params =
	{
		mode = "client",
		protocol = "any", -- "tlsv1_2"
		verify = "none",
		options = "all",
	}

	local conn = socket.tcp()
	-- network permission required, otherwise return nil
	local server_address = socket.dns.toip(serverName)
	local server_port = 443

	print("    Connecting to: " .. string.format("%s:%s", server_address, server_port))
	conn:settimeout(10)
	local result, error = conn:connect( server_address, server_port )
	if result then
		-- We're connected.
	else
		print( "Failed to connect to: " .. server_address .. ":" .. tostring( server_port ) .. " Error: " .. error )
		return
	end

	-- TLS/SSL initialization
	local msg
	conn, msg = plugin_luasec_ssl.wrap(conn, params)

	if not conn then
		print("wrap failed: ", msg)
	end

	-- specify sni, otherwise solar2d.com will failed handshake
	conn:sni(serverName)
	result, msg = conn:dohandshake()
	if not result then
		print("conn:dohandshake: failed with:", msg)
	end

	local conn_info = conn:info()
	if conn_info then
		local fmtedstr, _ = json.prettify(conn_info):gsub("\n", "\n    ")
		print("    conn:info: " .. fmtedstr)
	end

	conn:send( "GET / HTTP/1.0\nHost: " .. serverName .. "\n\n" )

	local data, status, partial_data = conn:receive("*a")

	if status then
		print("status:", status)
	end
	if data then
		if partial_data then
			data = data.partial_data
		end

		print("    received ".. data:len() .." bytes (raw response is larger due to HTTP headers)")
	end

	conn:close()

	print("")

	--------------------------------------------------------------------------------

	local plugin_luasec_https = require('plugin_luasec_https')
	local lfs = require('lfs')

	local url = "https://" .. serverName .. "/"
	local outfile = system.pathForFile('out.dat', system.TemporaryDirectory)
	local outfilePtr = io.open(outfile, 'w')

	print("Requesting secure URL on HTTPS socket: " .. url)

	plugin_luasec_https.request({
					url = url,
					sink = ltn12.sink.file(outfilePtr),
					protocol = "any"
				})

	print("    received ".. lfs.attributes(outfile).size .." bytes")

	--------------------------------------------------------------------------------

	local function networkListener( event )
		if ( event.isError ) then
			print( "ERROR:", event.response )
		else
			print( "RESPONSE:", #event.response, string.sub( event.response, 1, 1000 ) )
		end
	end

	print("Requesting secure URL on network.request: " .. url)
	network.request( url, "GET", networkListener )
end

test("coronalabs.com")
test("solar2d.com")

print( "plugin.openssl secure socket samples done" )
