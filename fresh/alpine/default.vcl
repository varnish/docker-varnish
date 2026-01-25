# Important documentation links:
# - general entry point: https://www.varnish-cache.org/docs/
# - VCL primer: https://varnish-cache.org/docs/2.1/tutorial/vcl.html
# - more VCL information: https://www.varnish-software.com/developers/tutorials/varnish-configuration-language-vcl/
# - logging: https://docs.varnish-software.com/tutorials/vsl-query/

vcl 4.1;

# https://github.com/varnish/toolbox/tree/master/vcls/hit-miss
include "hit-miss.vcl";

# import vmod_dynamic for better backend name resolution
import dynamic;
import std;

# Before you configure anything, we just disable the backend to avoid
# any mistake, but you can delete that line and uncomment the following
# ones to define a proper backend to fetch content from
backend default none;

# we may not have ipv6 in a container, so we'll only contact backend using ipv4
acl ipv4_only { "0.0.0.0"/0; }

# create a director that can find backends on-the-fly
sub vcl_init {
	new dynamic_director = dynamic.director(whitelist = ipv4_only);
}

# VCL allows you to implement a series of callback to dictate how to process
# each request. vcl_recv is the first one being called, right after Varnish
# receives some request headers. It's usually used to sanitize the request
sub vcl_recv {
	# if VARNISH_BACKEND_HOST and VARNISH_BACKEND_PORT, use them to find a backend
	# if not, generate a synthetic response with vcl_synth
	if (std.getenv("VARNISH_BACKEND_HOST") && std.getenv("VARNISH_BACKEND_PORT")) {
		set req.backend_hint = dynamic_director.backend(std.getenv("VARNISH_BACKEND_HOST"), std.getenv("VARNISH_BACKEND_PORT"));
		# tweak the host header to match the backend's info
		if (std.getenv("VARNISH_BACKEND_PORT") == "80") {
			set req.http.host = std.getenv("VARNISH_BACKEND_HOST");
		} else {
			set req.http.host = std.getenv("VARNISH_BACKEND_HOST") + ":" + std.getenv("VARNISH_BACKEND_PORT");
		}
	} else {
		return(synth(200));
	}
}

# build an HTML page explaining to the user what they need to do to configure
# the backend
sub vcl_synth {
	set resp.http.content-type = "text/html; charset=UTF-8;";
	synthetic(std.fileread("/etc/varnish/index.html"));
	return (deliver);
}

# if no synthetic response was generated, the request will go the the backend.
# vcl_backend_response is your chance to sanitize the response and possibly to
# set a TTL
sub vcl_backend_response {
}

# https://github.com/varnish/toolbox/tree/master/vcls/verbose_builtin
include "verbose_builtin.vcl";
