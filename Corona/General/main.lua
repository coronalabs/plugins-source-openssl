--------------------------------------------------------------------------------
-- Sample code is MIT licensed, see http://www.coronalabs.com/links/code/license
-- Copyright (C) 2016 Corona Labs Inc. All Rights Reserved.
--------------------------------------------------------------------------------

--
-- Demonstrates various features of the OpenSSL plugin (Big Numbers, encryption, x509)
--

local greeting = display.newText("OpenSSL tests - see console for results", display.actualContentWidth/2, 20)

print( "OpenSSL sample start" )

Runtime:setCheckGlobals( true )

local is_opensslv3 = true
local good, openssl = pcall( require, "plugin.opensslv3" )

local function check_error()
	if openssl.error then
		local reason, lib_reason, code = openssl.error()
		if reason then
			print( "code", tostring(code) )
			print( "reason", tostring(reason) )
			print( "lib_reason", tostring(lib_reason) )
		end
	end
end

if good == false then
	is_opensslv3 = false
	print( "WARNING: v3 not found, pcall require message is:", tostring( openssl ) )
	print( "Now require plugin.openssl..." )
	openssl = require( "plugin.openssl" )
end

check_error()

local lua_openssl_version, lua_version, openssl_version = openssl.version()
print( "lua-openssl version: " .. lua_openssl_version, lua_version, openssl_version )
greeting.text = openssl_version

check_error()

--dump a table 
local function dump(t,i)
        for k,v in pairs(t) do
                if(type(v)=='table') then
                        print( string.rep('\t',i),k..'={')
                                dump(v,i+1)
                        print( string.rep('\t',i),k..'=}')
                else
                        print( string.rep('\t',i),k..'='..tostring(v))
                end
        end
end

local function HexDumpString(str,spacer)
	return ( string.gsub(str,"(.)", function (c)
										return string.format("%02X%s",string.byte(c), spacer or "")
									end) )
end

local testcases = {}
function testcases.test_bn()

	-- test bn ("BIGNUM") library
	local bn = openssl.bn
	------------------------------------------------------------------------------
	print("bn.version: ", bn.version)
	print()

	p=bn.aprime(100)
	q=bn.aprime(250)
		print("p",p)
		print("q",q)
	m=p*q
		print("m",m)
	mx=(p-1)*(q-1)
		print("mx",mx)
	e=bn.number"X10001"
		print("e",e)
	d=bn.invmod(e,mx)
		print("d",d)
		assert(bn.mulmod(e,d,mx):isone())
	t=bn.number(2)
	x=bn.powmod(t,e,m)
	y=bn.powmod(x,d,m)
		assert(t==y)
		print()

	message="The quick brown fox jumps over the lazy dog"
		print("message as text")
		print(message)

	encoded=bn.text(message)
		print("encoded message")
		print(encoded)
		assert(encoded<m)
		assert(message==bn.totext(encoded))

	x=bn.powmod(encoded,e,m)
		print("encrypted message")
		print(x)

	y=bn.powmod(x,d,m)
		print("decrypted message as number")
		print(y)
		assert(y==encoded)
	y=bn.totext(y)
		print("decrypted message as text")
		print(y)
		assert(y==message)

	print()

	d=bn.number"X816f0d36f0874f9f2a78acf5643acda3b59b9bcda66775b7720f57d8e9015536160e728230ac529a6a3c935774ee0a2d8061ea3b11c63eed69c9f791c1f8f5145cecc722a220d2bc7516b6d05cbaf38d2ab473a3f07b82ec3fd4d04248d914626d2840b1bd337db3a5195e05828c9abf8de8da4702a7faa0e54955c3a01bf121"
	m=bn.number"Xbfedeb9c79e1c6e425472a827baa66c1e89572bbfe91e84da94285ffd4c7972e1b9be3da762444516bb37573196e4bef082e5a664790a764dd546e0d167bde1856e9ce6b9dc9801e4713e3c8cb2f12459788a02d2e51ef37121a0f7b086784f0e35e76980403041c3e5e98dfa43ab9e6e85558c5dc00501b2f2a2959a11db21f"
	t=bn.number(2)
	x=bn.powmod(t,e,m)
	y=bn.powmod(x,d,m)
	assert(t==y)

end

function testcases.test_csr()

	local raw_data =
[[
-----BEGIN CERTIFICATE-----
MIIBoTCCAQqgAwIBAgIMA/016215epG+OPNOMA0GCSqGSIb3DQEBBQUAMBExDzAN
BgNVBAMTBnpoYW96ZzAeFw0xMTA3MDYwNTI3MDlaFw0xMjA3MDUwNTI3MDlaMBEx
DzANBgNVBAMTBnpoYW96ZzCBnzANBgkqhkiG9w0BAQEFAAOBjQAwgYkCgYEAy48u
FWSdZmSET1gdJqczdL6jxxssCCq/lEthPj9SRr1iZl/lkZ95VhwA/llJHVLpOA4m
DjIJd8jFW+g/Bo2XyqHa2unSHtYW7xT6iUMAQOGlvkF81NtXzmEffFNAj4Ud/T2r
pKdFY/5YZI+CFCi6m1hT/xbwR84bASL/dBXoOOUCAwEAATANBgkqhkiG9w0BAQUF
AAOBgQA8LAd0UXbzPN6v1lIM4KcR88mH/SKeRvNXJqv8JEF4qosXr6wN0XT4bIqN
fv/5OBot6ECcEm8aeGR08gBmjtsQAYtGc07ksvzYtytKsGWdcTLAf/+K2bKg6VGy
pM4KW8DPKCZ16zylyzRbVKbQJ/sjcCPqd55M3THg2gRnxywalw==
-----END CERTIFICATE----- 
]]

	local x = (is_opensslv3 and openssl.x509.read or openssl.x509_read)( raw_data )
	dump(x:parse(),0)

	local csr_data =
[[
-----BEGIN CERTIFICATE REQUEST-----
MIIBvjCCAScCAQAwfjELMAkGA1UEBhMCQ04xCzAJBgNVBAgTAkJKMRAwDgYDVQQH
EwdYSUNIRU5HMQ0wCwYDVQQKEwRUQVNTMQ4wDAYDVQQLEwVERVZFTDEVMBMGA1UE
AxMMMTkyLjE2OC45LjQ1MRowGAYJKoZIhvcNAQkBFgtzZGZAc2RmLmNvbTCBnzAN
BgkqhkiG9w0BAQEFAAOBjQAwgYkCgYEA0auDcE3VFsp6J3NvyPBiiZLLnAUnUMPQ
lxmGUcbGI12UA3Z0+hNcRprDX5vD7ODUVZrR4iAozaTKUGe5w2KrhElrV/3QGzGH
jMUKvYgtlYr/vK1cAX9wx67y7YBnPbIRVqdLQRLF9Zu8T5vaMx0a/e1dzQq7EvKr
xjPVjCSgZ8cCAwEAAaAAMA0GCSqGSIb3DQEBBQUAA4GBAF3sMj2dtIcVTHAnLmHY
lemLpEEo65U7iLJUskUNMsDrNLEVt7kuWlz0uQDnuZ4qgrRVJ2BpxskTR5D5Yzzc
wSpxg0VN6+i6u9C9n4xwCe1VyteOC2In0LbxMAGL3rVFm9yDFRU3LDy3EWG6DIg/
4+QM/GW7qfmes65THZt0Hram
-----END CERTIFICATE REQUEST----- 
]]

	local x509 = (is_opensslv3 and openssl.x509.req.read or openssl.csr_read)( csr_data )
	dump(x509:parse(),0)

end

function testcases.test_random()
	local bytes = 64
	print( (is_opensslv3 and openssl.random or openssl.random_bytes)( bytes ) )
end

function testcases.test_sha1_empty()

	local sha1 = (is_opensslv3 and openssl.digest.get or openssl.get_digest)( 'sha1' )

	local d = sha1:digest('')

	-- SHA1 of empty string should be:
	-- "da39a3ee5e6b4b0d3255bfef95601890afd80709"
	-- Outputs:
	-- "DA39A3EE5E6B4B0D3255BFEF95601890AFD80709"
	print( "SHA1 digest: ", HexDumpString( d, "" ) )

end

function testcases.test_md5_empty()

	local md5 = (is_opensslv3 and openssl.digest.get or openssl.get_digest)( 'md5' )

	local d = md5:digest('')

	-- MD5 of empty string should be:
	-- "d41d8cd98f00b204e9800998ecf8427e"
	-- Outputs:
	-- "D41D8CD98F00B204E9800998ECF8427E"
	print( "MD5 digest: ", HexDumpString( d, "" ) )

end

function testcases.test_x509()

	--[[
		1. Generate kaypair
	]]

	-- create a rsa private key
	local pkey = (is_opensslv3 and openssl.pkey.new or openssl.pkey_new)( 'rsa', 1024, 0x10001 )

	-- DO NOT PRINT OUT PRIVATE KEY IN PRODUCTION
	-- print pkey for debug
	print( pkey:export() )
	print( 'pkey is_private:', pkey:is_private() )

	if ( pkey:is_private() ) then

		-- export public key
		local pubstr = nil
		if is_opensslv3 then
			local pub = pkey:get_public()
			pubstr = pub:export(
				"pem", -- ‘pem’ or ‘der’, default ‘pem’
				false -- default false
			)
		else
			pubstr = pkey:export(
				true, -- only public
				false -- not raw format
			)
		end

		print( "Encoded public key is:" )
		print( pubstr )

		-- import public key
		local pub_imported = (is_opensslv3 and openssl.pkey.read or openssl.pkey_read)( pubstr )
		print( "imported public key is:", pub_imported )
	end

	-- print key information
	print('pkey information:')
	local t = pkey:parse()
	dump(t,0)

	print('pkey generate OK')
	print(string.rep('-',78))

	--[[
		2. Create CSR(Certificate Signing Request)
	]]

	local csr
	local digest_alg = "sha1WithRSAEncryption"
	if is_opensslv3 then
		local cadn = {
			{CN = 'CA'},
			{OU = "lua-openssl"},
			{O = "Solar2D"},
			{C = 'CN'}
		  }
		-- make x509_name
		cadn = openssl.x509.name.new(cadn)
		-- generate signed CSR
		csr = openssl.x509.req.new(cadn, pkey, digest_alg)
	else
		local args = { digest = digest_alg }
		local dn = { commonName='my_name_example', emailAddress='my_name_example@example.com' }
		csr = openssl.csr_new( pkey, dn, args )
	end
	dump(csr:parse(), 0)
	print('CSR generate OK')
	print(string.rep('-',78))

	--[[
		3. Self-signed certificate
	]]

	-- make a self sign certificate
	local self_sign_cert
	if is_opensslv3 then
		self_sign_cert = csr:to_x509( pkey, 365, digest_alg )
	else
		local args = {
			digest = digest_alg,
			serialNumber = '1234567890abcdef', --hexencode big number
			num_days = 365
		}
		self_sign_cert = csr:sign( nil, pkey, args )
	end
	dump(self_sign_cert:parse(), 0);
	print('self signed certificate generate OK')
	print(string.rep('-',78))

	--[[
		4. Sign and verify
	]]

	-- sign something.
	local signed_data
	if is_opensslv3 then
		signed_data = pkey:sign('I love lua', 'sha1')
	else
		signed_data = openssl.sign('I love lua', pkey, 'sha1')
	end
	print('#signed_data:', #signed_data)

	-- get verify method
	local sha1 = (is_opensslv3 and openssl.digest.get or openssl.get_digest)( 'sha1' )
	print(sha1)

	-- is verified, public key from cert
	local verified, pubkey
	if is_opensslv3 then
		pubkey = self_sign_cert:pubkey()
		verified = pubkey:verify('I love lua', signed_data, sha1)
	else
		pubkey = self_sign_cert:get_public()
		verified = openssl.verify('I love lua', signed_data, pubkey, sha1)
	end
	assert(verified)
	print('sign and verify OK')

	--[[
		5. Exchange crypted message
	]]

	local m = "albert"
    local e = pubkey:encrypt(m)
    print(#e,e)

    d = pkey:decrypt(e)
    print(#d,d)

    assert(d==m)
	print('decrypt using PKI OK')

end

function testcases.test_sha1()

	local sha1 = (is_opensslv3 and openssl.digest.get or openssl.get_digest)( 'sha1' )
	local msg = string.rep('I love lua.',1000)

	print( "digest: ", HexDumpString(sha1:digest(msg), "") )

end

function testcases.test_aes()

	--local evp_cipher = openssl.get_cipher('des3')
	--local evp_cipher = openssl.get_cipher('des')
	--local evp_cipher = openssl.get_cipher('bf')
	local evp_cipher = (is_opensslv3 and openssl.cipher.get or openssl.get_cipher)( 'aes-256-ecb' )

	m = 'abcdefghijk'
	key = m
	cdata = evp_cipher:encrypt(m,key)
	m1 = evp_cipher:decrypt(cdata,key)

	print( m )
	print( cdata )
	print( m1 )

	if m == m1 then
		print( "Good" )
	else
		print( "Bad" )
	end

end

for name, case in pairs( testcases ) do
	if type(case) == "function" then
		print("====== start testcase name:", name)
		case()
		check_error()
		print("======  end  testcase name:", name)
	else
		print(name, "not a function")
	end
end

print( "OpenSSL sample done" )
