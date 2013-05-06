#include <dlfcn.h>
#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <jni.h>
#include <android/log.h>

#include <unistd.h>

#include <lua.h>
typedef int ( *luaopen_plugin_openssl_core_t )( lua_State * );

#define LOGI( ... )		__android_log_print( ANDROID_LOG_INFO, __FILE__, __VA_ARGS__ )

#define DEBUG_LOADING	( 0 )

void *getlib( const char *name )
{
#	if DEBUG_LOADING

		LOGI( ":::::::::::::::::::::::::::::::::::::::::::::::::::::::::\n" );
		LOGI( ":::::::::::::::::::::::::::::::::::::::::::::::::::::::::\n" );
		LOGI( ":::::::::: %s : lib: %s\n", __FUNCTION__, name );
		LOGI( ":::::::::::::::::::::::::::::::::::::::::::::::::::::::::\n" );

#	endif // DEBUG_LOADING

	// Clean any existing error.
	dlerror();

	void *p = dlopen( name, ( RTLD_NOW | RTLD_GLOBAL ) );
	const char *error = dlerror();

#	if DEBUG_LOADING

		LOGI( ":::::::::: dlopen() : %s : %p : %s\n",
				name,
				p,
				( p ? "No error." : error ) );
		LOGI( ":::::::::::::::::::::::::::::::::::::::::::::::::::::::::\n" );

#	endif // DEBUG_LOADING

	return p;
}

void *getsym( void *lib, const char *name )
{
#	if DEBUG_LOADING

		LOGI( ":::::::::::::::::::::::::::::::::::::::::::::::::::::::::\n" );
		LOGI( ":::::::::::::::::::::::::::::::::::::::::::::::::::::::::\n" );
		LOGI( ":::::::::: %s : lib: %p : symb: %s\n", __FUNCTION__, lib, name );
		LOGI( ":::::::::::::::::::::::::::::::::::::::::::::::::::::::::\n" );

#	endif // DEBUG_LOADING

	// Clean any existing error.
	dlerror();

	void *p = dlsym( lib, name );
	const char *error = dlerror();

#	if DEBUG_LOADING

		LOGI( ":::::::::: dlsym() : %s : %p : %s\n",
				name,
				p,
				( p ? "No error." : error ) );
		LOGI( ":::::::::::::::::::::::::::::::::::::::::::::::::::::::::\n" );

#	endif // DEBUG_LOADING

	return p;
}

extern "C" int luaopen_plugin_openssl( lua_State *L )
{
	// Load the dependencies first.
	//WE DON'T HAVE TO PROVIDE THE FULL PATH!!!
	//"liblua.so" IS ENOUGH!!!
	void *liblua = getlib("/data/data/com.ansca.test.Corona/lib/liblua.so");
	void *libcrypto = getlib("/data/data/com.ansca.test.Corona/lib/libcrypto.so");

#	if DEBUG_LOADING

		void *f0 = getsym( libcrypto, "d2i_TS_RESP_bio" );
		void *f1 = getsym( libcrypto, "BN_mod_sqrt" );
		void *f2 = getsym( libcrypto, "TS_TST_INFO_new" );
		void *f3 = getsym( libcrypto, "d2i_TS_RESP" );
		void *f4 = getsym( libcrypto, "d2i_TS_REQ" );
		void *f5 = getsym( libcrypto, "TS_REQ_dup" );

#	endif // DEBUG_LOADING

	void *libssl = getlib("/data/data/com.ansca.test.Corona/lib/libssl.so");
	void *libplugin = getlib("/data/data/com.ansca.test.Corona/lib/libplugin.openssl_core.so");

	void *f = getsym( libplugin, "luaopen_plugin_openssl_core" );

	return ( (luaopen_plugin_openssl_core_t)f )( L );
}
