cmake_minimum_required(VERSION 3.4)

project("plugin.openssl")

set(PLUGIN_OPENSSL_ROOT_DIR ${CMAKE_CURRENT_LIST_DIR}/..)
set(LUA_OPENSSL_SRC_DIR ${PLUGIN_OPENSSL_ROOT_DIR}/../sdk-lua-openssl/src)
set(LUASOCKET_SRC_DIR ${PLUGIN_OPENSSL_ROOT_DIR}/../sdk-luasocket/src)
set(MY_LIBRARY_DIR ${PLUGIN_OPENSSL_ROOT_DIR}/lib)

add_library(ssl STATIC IMPORTED)
set_target_properties(ssl PROPERTIES
    IMPORTED_LOCATION ${MY_LIBRARY_DIR}/libs/${ANDROID_ABI}/${CMAKE_STATIC_LIBRARY_PREFIX}ssl${CMAKE_STATIC_LIBRARY_SUFFIX}
    INTERFACE_INCLUDE_DIRECTORIES ${MY_LIBRARY_DIR}/includes/${ANDROID_ABI}
)

add_library(crypto STATIC IMPORTED)
set_target_properties(crypto PROPERTIES
    IMPORTED_LOCATION ${MY_LIBRARY_DIR}/libs/${ANDROID_ABI}/${CMAKE_STATIC_LIBRARY_PREFIX}crypto${CMAKE_STATIC_LIBRARY_SUFFIX}
    INTERFACE_INCLUDE_DIRECTORIES ${MY_LIBRARY_DIR}/includes/${ANDROID_ABI}
)

# CAUTION: when you change SOLAR2D_NATIVE_DIR by register another Solar2D version
# need "Refresh Linked C++ Projects" on Android Studio, otherwise execute_process won't run
set(SOLAR2D_NATIVE_DIR "/Applications/CoronaEnterprise")
set(SOLAR2D_CORONA_AAR_FILE "${SOLAR2D_NATIVE_DIR}/Corona/android/lib/gradle/Corona.aar")
set(SOLAR2D_BUILD_FILE "${SOLAR2D_NATIVE_DIR}/Corona/BUILD")
execute_process(COMMAND cat -s "/Applications/CoronaEnterprise/Corona/BUILD"
        WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
        TIMEOUT 5
        OUTPUT_VARIABLE SOLAR2D_BUILD
)
message(WARNING "Use ${SOLAR2D_BUILD} as interface")
execute_process(COMMAND unzip -ju "${SOLAR2D_CORONA_AAR_FILE}" "jni/${ANDROID_ABI}/libcorona.so" "jni/${ANDROID_ABI}/liblua.so"
        WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
        TIMEOUT 10
)

add_library(solar2d-lua SHARED IMPORTED)
set_target_properties(solar2d-lua PROPERTIES
    IMPORTED_LOCATION ${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_SHARED_LIBRARY_PREFIX}lua${CMAKE_SHARED_LIBRARY_SUFFIX}
    INTERFACE_INCLUDE_DIRECTORIES ${SOLAR2D_NATIVE_DIR}/Corona/shared/include/lua
    IMPORTED_NO_SONAME TRUE
)

add_library(solar2d-corona SHARED IMPORTED)
set_target_properties(solar2d-corona PROPERTIES
    IMPORTED_LOCATION ${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_SHARED_LIBRARY_PREFIX}corona${CMAKE_SHARED_LIBRARY_SUFFIX}
    INTERFACE_INCLUDE_DIRECTORIES ${SOLAR2D_NATIVE_DIR}/Corona/shared/include/corona
    IMPORTED_NO_SONAME TRUE
)

set(SOLAR2D_NATIVE_BIN_DIR ${SOLAR2D_NATIVE_DIR}/Corona/mac/bin)
set(LUA2C_PATH ${SOLAR2D_NATIVE_BIN_DIR}/lua2c.sh)
add_custom_command(
    OUTPUT ${LUA_OPENSSL_SRC_DIR}/plugin_luasec_https.c ${LUA_OPENSSL_SRC_DIR}/plugin_luasec_ssl.c
    COMMAND ${LUA2C_PATH} '${LUA_OPENSSL_SRC_DIR}/../input_for_lua2c/plugin_luasec_https.lua' '${LUA_OPENSSL_SRC_DIR}' '${CMAKE_BUILD_TYPE}' '${SOLAR2D_NATIVE_BIN_DIR}'
    COMMAND ${LUA2C_PATH} '${LUA_OPENSSL_SRC_DIR}/../input_for_lua2c/plugin_luasec_ssl.lua' '${LUA_OPENSSL_SRC_DIR}' '${CMAKE_BUILD_TYPE}' '${SOLAR2D_NATIVE_BIN_DIR}'
    DEPENDS ${LUA_OPENSSL_SRC_DIR}/../input_for_lua2c/plugin_luasec_https.lua ${LUA_OPENSSL_SRC_DIR}/../input_for_lua2c/plugin_luasec_ssl.lua
)

add_library("plugin.openssl" SHARED
    ${LUASOCKET_SRC_DIR}/auxiliar.c
    ${LUASOCKET_SRC_DIR}/buffer.c
    ${LUASOCKET_SRC_DIR}/compat.c
    ${LUASOCKET_SRC_DIR}/context.c
    ${LUASOCKET_SRC_DIR}/except.c
    ${LUASOCKET_SRC_DIR}/inet.c
    ${LUASOCKET_SRC_DIR}/io.c
    ${LUASOCKET_SRC_DIR}/luasocket.c
    ${LUASOCKET_SRC_DIR}/makefile
    ${LUASOCKET_SRC_DIR}/mime.c
    ${LUASOCKET_SRC_DIR}/options.c
    ${LUASOCKET_SRC_DIR}/select.c
    ${LUASOCKET_SRC_DIR}/ssl.c
    ${LUASOCKET_SRC_DIR}/tcp.c
    ${LUASOCKET_SRC_DIR}/timeout.c
    ${LUASOCKET_SRC_DIR}/udp.c
    ${LUASOCKET_SRC_DIR}/unix.c
    ${LUASOCKET_SRC_DIR}/usocket.c
    ${LUASOCKET_SRC_DIR}/x509.c
    ${LUASOCKET_SRC_DIR}/ec.c
    ${LUASOCKET_SRC_DIR}/config.c

    ${LUA_OPENSSL_SRC_DIR}/plugin_luasec_https.c
    ${LUA_OPENSSL_SRC_DIR}/plugin_luasec_ssl.c
    ${LUA_OPENSSL_SRC_DIR}/../deps/auxiliar/subsidiar.c
    ${LUA_OPENSSL_SRC_DIR}/../deps/lua-compat/c-api/compat-5.3.c
    ${LUA_OPENSSL_SRC_DIR}/asn1.c
    ${LUA_OPENSSL_SRC_DIR}/bio.c
    ${LUA_OPENSSL_SRC_DIR}/callback.c
    ${LUA_OPENSSL_SRC_DIR}/cipher.c
    ${LUA_OPENSSL_SRC_DIR}/cms.c
    ${LUA_OPENSSL_SRC_DIR}/compat.c
    ${LUA_OPENSSL_SRC_DIR}/crl.c
    ${LUA_OPENSSL_SRC_DIR}/csr.c
    ${LUA_OPENSSL_SRC_DIR}/dh.c
    ${LUA_OPENSSL_SRC_DIR}/digest.c
    ${LUA_OPENSSL_SRC_DIR}/dsa.c
    ${LUA_OPENSSL_SRC_DIR}/ec.c
    ${LUA_OPENSSL_SRC_DIR}/engine.c
    ${LUA_OPENSSL_SRC_DIR}/hmac.c
    ${LUA_OPENSSL_SRC_DIR}/lbn.c
    ${LUA_OPENSSL_SRC_DIR}/lhash.c
    ${LUA_OPENSSL_SRC_DIR}/misc.c
    ${LUA_OPENSSL_SRC_DIR}/ocsp.c
    ${LUA_OPENSSL_SRC_DIR}/oids.txt
    ${LUA_OPENSSL_SRC_DIR}/openssl.c
    ${LUA_OPENSSL_SRC_DIR}/ots.c
    ${LUA_OPENSSL_SRC_DIR}/pkcs12.c
    ${LUA_OPENSSL_SRC_DIR}/pkcs7.c
    ${LUA_OPENSSL_SRC_DIR}/pkey.c
    ${LUA_OPENSSL_SRC_DIR}/private.h
    ${LUA_OPENSSL_SRC_DIR}/rsa.c
    ${LUA_OPENSSL_SRC_DIR}/sk.h
    ${LUA_OPENSSL_SRC_DIR}/srp.c
    ${LUA_OPENSSL_SRC_DIR}/ssl.c
    ${LUA_OPENSSL_SRC_DIR}/th-lock.c
    ${LUA_OPENSSL_SRC_DIR}/util.c
    ${LUA_OPENSSL_SRC_DIR}/x509.c
    ${LUA_OPENSSL_SRC_DIR}/xattrs.c
    ${LUA_OPENSSL_SRC_DIR}/xexts.c
    ${LUA_OPENSSL_SRC_DIR}/xname.c
    ${LUA_OPENSSL_SRC_DIR}/xalgor.c
    ${LUA_OPENSSL_SRC_DIR}/xstore.c
)
set_target_properties("plugin.openssl" PROPERTIES OUTPUT_NAME "plugin.opensslv3")

target_compile_definitions("plugin.openssl" 
    PRIVATE
        $<$<CONFIG:Debug>:Rtt_DEBUG>
        ANDROID_NDK
        NDEBUG
        _REENTRANT
        Rtt_ANDROID_ENV
    )

target_include_directories("plugin.openssl"
    PRIVATE
        ${LUA_OPENSSL_SRC_DIR}
        ${LUASOCKET_SRC_DIR}
        ${LUA_OPENSSL_SRC_DIR}/../deps/auxiliar
        ${LUA_OPENSSL_SRC_DIR}/../deps/lua-compat/c-api
        )

# link order matters
target_link_libraries("plugin.openssl" log z ssl crypto solar2d-lua solar2d-corona)
