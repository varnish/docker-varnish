# Important documentation links:
# - general entry point: https://www.varnish-cache.org/docs/
# - VCL primer: https://varnish-cache.org/docs/2.1/tutorial/vcl.html
# - more VCL information: https://www.varnish-software.com/developers/tutorials/varnish-configuration-language-vcl/
# - logging: https://docs.varnish-software.com/tutorials/vsl-query/

vcl 4.1;

import fileserver;
import reqwest;
import std;

# https://github.com/varnish/toolbox/tree/master/vcls/hit-miss
include "hit-miss.vcl";

backend default none;

sub vcl_init {
    # sanity check to fail the VCL loading if VARNISH_BACKEND_HOST
    # doesn't look right
    if (std.getenv("VARNISH_BACKEND_HOST") &&
        std.getenv("VARNISH_BACKEND_HOST") !~ "^https?://") {
        return(fail("VARNISH_BACKEND_HOST is set but doesn't start with http:// or https://"));
    }
    new http_backend = reqwest.client(base_url = std.getenv("VARNISH_BACKEND_HOST"));
    new file_backend = fileserver.root("/var/www/html");
}

sub vcl_recv {
    if (std.getenv("VARNISH_BACKEND_HOST")) {
        # if VARNISH_BACKEND_HOST is set, use the HTTP backend
        set req.backend_hint = http_backend.backend();
    } else {
        # otherwise, force the path to our default page and serve
        # from disk
        set req.backend_hint = file_backend.backend();
        set req.url = "/index.html";
    }
}

# if the request goes to the backend, unset the host header and let
# vmod-reqwest set it, according to VARNISH_BACKEND_HOST (and it doesn't
# matter for file_backend)
sub vcl_backend_fetch {
    unset bereq.http.host;
}

# vcl_backend_response is the opportunity to set/unset backend response headers
# (beresp.http.*) before they enter the cache
sub vcl_backend_response {
    set beresp.http.varnish-default-vcl = "true";
}

# https://github.com/varnish/toolbox/tree/master/vcls/verbose_builtin
include "verbose_builtin.vcl";
