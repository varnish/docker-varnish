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

#backend default {
#    .host = "127.0.0.1";
#    .port = "8080";
#}

sub vcl_init {
	new d = dynamic.director();
}

# VCL allows you to implement a series of callback to dictate how to process
# each request. vcl_recv is the first one being called, right after Varnish
# receives some request headers. It's usually used to sanitize the request
sub vcl_recv {
	if (std.getenv("VARNISH_BACKEND_HOST") && std.getenv("VARNISH_BACKEND_PORT")) {
		set req.backend_hint = d.backend(std.getenv("VARNISH_BACKEND_HOST"), std.getenv("VARNISH_BACKEND_PORT"));
	}

	# if no backend is configured, generate a welcome message by sending
	# processing to `vcl_synth
	if (!req.backend_hint) {
		return(synth(200));
	}
}

# Just fill the response body and deliver it
sub vcl_synth {
	synthetic("""<!DOCTYPE html>
			<html><body>

				<h1>Varnish is running!</h1>
				<p>Please edit <code>/etc/varnish/default.vcl</code> or set <code>VARNISH_BACKEND_HOST</code> and <code>VARNISH_BACKEND_PORT</code> environment variables to setup a backend.</p>

			</body></html>""");
	return (deliver);
}

# if no synthetic response was generated, the request will go the the backend.
# vcl_backend_response is your chance to sanitize the response and possibly to
# set a TTL
sub vcl_backend_response {
}

# https://github.com/varnish/toolbox/tree/master/vcls/verbose_builtin
include "verbose_builtin.vcl";
