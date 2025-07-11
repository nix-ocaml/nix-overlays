{ self
, stdenv
, bash
, fetchpatch
, fetchFromGitHub
, fzf
, lib
, linuxHeaders
, nixpkgs
, pam
, net-snmp
, openssl
, postgresql
, zstd
}:

with self;

let
  isFlambda2 = lib.hasSuffix "flambda2" ocaml.version;
  js_of_ocaml-compiler = self.js_of_ocaml-compiler.override { version = "5.9.1"; };
  js_of_ocaml = self.js_of_ocaml.override { inherit js_of_ocaml-compiler; };
  gen_js_api = self.gen_js_api.override {
    inherit js_of_ocaml-compiler;
    ojs = self.ojs.override { inherit js_of_ocaml-compiler; };
  };
  js_of_ocaml-ppx = self.js_of_ocaml-ppx.override { inherit js_of_ocaml; };
in

{
  abstract_algebra = (janePackage {
    pname = "abstract_algebra";
    hash = "sha256-W2rSSbppNkulCgGeTiovzP5zInPWIVfflDxWkGpEOFA=";
    meta.description = "A small library describing abstract algebra concepts";
    propagatedBuildInputs = [ base ppx_jane ];
  }).overrideAttrs (o: {
    src =
      if isFlambda2
      then
        fetchFromGitHub
          {
            owner = "janestreet";
            repo = "abstract_algebra";
            rev = "3b71934227f034fa9a8e2b8d662e7129114cfbec";
            hash = "sha256-F5qLHzy8JTR75132SYyj/KVSlf9RQzHNKFVrV2O6KzU=";
          }
      else o.src;

  });

  accessor = (janePackage {
    pname = "accessor";
    hash = "sha256-1inoFwDDhnfhW+W3aAkcFNUkf5Umy8BDGDEbMty+Fts=";
    meta.description = "A library that makes it nicer to work with nested functional data structures";
    propagatedBuildInputs = [ base higher_kinded ppx_jane ];
  }).overrideAttrs (o: {
    src =
      if isFlambda2
      then
        fetchFromGitHub
          {
            owner = "janestreet";
            repo = "accessor";
            rev = "b192a00353115bede0f7f53cff44555ea26f14ba";
            hash = "sha256-4ZkYX6gkmE9c8wctFcD+wWlycAh2VxZoKd6m6hD5NYA=";
          }
      else o.src;

  });

  accessor_async = (janePackage {
    pname = "accessor_async";
    hash = "sha256-EYyxZur+yshYaX1EJbWc/bCaAa9PDKiuK87fIeqhspo=";
    meta.description = "Accessors for Async types, for use with the Accessor library";
    propagatedBuildInputs = [ accessor_core async_kernel core ppx_accessor ppx_jane ];
  }).overrideAttrs (o: {
    src =
      if isFlambda2
      then
        fetchFromGitHub
          {
            owner = "janestreet";
            repo = "accessor_async";
            rev = "f22161c0bf03272f60d98b063eab61c5a414a3d3";
            hash = "sha256-iQgdE4IX6WAegSFW5Oh+XXvyJE98T5eC+TTUqXlTJ3E=";
          }
      else o.src;

  });

  accessor_base = (janePackage {
    pname = "accessor_base";
    hash = "sha256-6LJ8dKPAuaxWinArkPl4OE0eYPqvM7+Ao6jff8jhjXc=";
    meta.description = "Accessors for Base types, for use with the Accessor library";
    propagatedBuildInputs = [ ppx_accessor ];
  }).overrideAttrs (o: {
    src =
      if isFlambda2
      then
        fetchFromGitHub
          {
            owner = "janestreet";
            repo = "accessor_base";
            rev = "0fad4ef29e8df2796367722dfaee99412b426c5f";
            hash = "sha256-C51Gg15HHlTOiJOGoG2yjA6xteOyk3XoKzKpD45j0fI=";
          }
      else o.src;
  });

  accessor_core = (janePackage {
    pname = "accessor_core";
    hash = "sha256-ku83ZfLtVI8FvQhrKcnJmhmoNlYcVMKx1tor5N8Nq7M=";
    meta.description = "Accessors for Core types, for use with the Accessor library";
    propagatedBuildInputs = [ accessor_base core_kernel ];
  }).overrideAttrs (o: {
    src =
      if isFlambda2
      then
        fetchFromGitHub
          {
            owner = "janestreet";
            repo = "accessor_core";
            rev = "e2cdcc763ec8719119242ae5ce9c127e8792ab72";
            hash = "sha256-G8Li9w6WcGxDW0GzrzbM3vbGaO4yw8k3i+o91eSbOz8=";
          }
      else o.src;

  });

  async = (janePackage {
    pname = "async";
    hash = "sha256-CwRPH5tFZHJqptdmNwdZvKvSJ1Qr21gV1jaxsa/vFBU=";
    meta.description = "Monadic concurrency library";
    propagatedBuildInputs = [ async_rpc_kernel async_log async_unix textutils ];
    doCheck = false; # we don't have netkit_sockets
  }).overrideAttrs (o: {
    src =
      if isFlambda2
      then
        fetchFromGitHub
          {
            owner = "janestreet";
            repo = "async";
            rev = "9c6c215cef2c477ae26ab1f68d70c4f52456f920";
            hash = "sha256-ZLNjO/gDG9Nk9yhcOLRroDX+D1FEWC26U9Ye1VaVhDo=";
          }
      else o.src;
  });

  async_durable = (janePackage {
    pname = "async_durable";
    hash = "sha256-CAU54j3K47p4hQqAtHJYuAQ0IvZPMQZKFp5J7G+xtjM=";
    meta.description = "Durable connections for use with async";
    propagatedBuildInputs = [
      async_kernel
      async_rpc_kernel
      core
      core_kernel
      ppx_jane
    ];
  }).overrideAttrs (o: {
    src =
      if isFlambda2
      then
        fetchFromGitHub
          {
            owner = "janestreet";
            repo = "async_durable";
            rev = "5a5c7035da88cd62d87b63716467a3669ef6597a";
            hash = "sha256-8lOorr/FU+JSSTYYB8Ak8Rd/amVpqLuVaJa5pQMcpNk=";
          }
      else o.src;
  });

  async_extra = (janePackage {
    pname = "async_extra";
    hash = "sha256-rZUROyYrvtgnI+leTMXuGcw71MfVhqdkfp9EIhAFUnM=";
    meta.description = "Monadic concurrency library";
    propagatedBuildInputs = [ async_kernel ];
  }).overrideAttrs (o: {
    src =
      if isFlambda2
      then
        fetchFromGitHub
          {
            owner = "janestreet";
            repo = "async_extra";
            rev = "d06e8bbba5bea38bc43d65b597ca78ef9c465078";
            hash = "sha256-ZV3FFVZpxvetpaUujkVXX4733NHLq5MpJ83uoU9nTgU=";
          }
      else o.src;
  });

  async_find = (janePackage {
    pname = "async_find";
    hash = "sha256-byvLJvhq7606gKP1kjLRYe3eonkAG3Vz6wQcsjJOiOE=";
    meta.description = "Directory traversal with Async";
    propagatedBuildInputs = [ async ];
  }).overrideAttrs (o: {
    src =
      if isFlambda2
      then
        fetchFromGitHub
          {
            owner = "janestreet";
            repo = "async_find";
            rev = "23d67513c6e46934e420abf917478d0b1d6cff29";
          }
      else o.src;
  });

  async_inotify = janePackage {
    pname = "async_inotify";
    hash = "sha256-608G8OKQxqrQdYc1Cfrd8g8WLX6QwSeMUz8ORuSbmA8=";
    meta.description = "Async wrapper for inotify";
    propagatedBuildInputs = [ async_find inotify ];
  };

  async_interactive = janePackage {
    pname = "async_interactive";
    hash = "sha256-hC7mLDLtvIEMKLMeDOC5ADiAGJlJqYF35RDI+porsKA=";
    meta.description = "Utilities for building simple command-line based user interfaces";
    propagatedBuildInputs = [ async ];
  };

  async_js = janePackage {
    pname = "async_js";
    hash = "sha256-4t7dJ04lTQ0b6clf8AvtyC8ip43vIcEBXgHJLiRbuGM=";
    meta.description = "A small library that provide Async support for JavaScript platforms";
    buildInputs = [ js_of_ocaml-ppx ];
    propagatedBuildInputs = [ async_rpc_kernel js_of_ocaml uri-sexp ];
  };

  async_kernel = (janePackage {
    pname = "async_kernel";
    hash = "sha256-fEbo7EeOJHnBqTYvC/o2a2x69XPnANbe15v/yv29l/4=";
    meta.description = "Monadic concurrency library";
    propagatedBuildInputs = [ core_kernel ];
  }).overrideAttrs (o: {
    src =
      if isFlambda2
      then
        fetchFromGitHub
          {
            owner = "janestreet";
            repo = "async_kernel";
            rev = "364ab5b3c0c70a3b2da1e31b05b89853d59aace5";
            hash = "sha256-cfXrkT3PG4LciYEP/B5cAgO8WkQ9QhMvtXFxeoqr1ws=";
          }
      else o.src;
  });

  async_log = (janePackage {
    pname = "async_log";
    hash = "sha256-XeWC3oC0n4or3EDLrNLWXMWhyhH6kcah0Mdb56rZ5lA=";
    meta.description = "Logging library built on top of Async_unix";
    propagatedBuildInputs = [
      async_kernel
      async_unix
      core
      core_kernel
      ppx_jane
    ];
  }).overrideAttrs (o: {
    src =
      if isFlambda2
      then
        fetchFromGitHub
          {
            owner = "janestreet";
            repo = "async_log";
            rev = "016d58861525058813fcc0be9d7b51b5fd87b910";
            hash = "sha256-SUHxEtEiDMmWAToT8oUqpN8kCs0pz0yENqVAhhsoQKI=";
          }
      else o.src;
  });

  async_rpc_kernel = (janePackage {
    pname = "async_rpc_kernel";
    hash = "sha256-zSqmRgybvWhS9XiNIqgxUjQU8xc9aXM69ZaBq4+r+HA=";
    meta.description = "Platform-independent core of Async RPC library";
    propagatedBuildInputs = [
      async_kernel
      protocol_version_header
      pipe_with_writer_error
    ];
  }).overrideAttrs (o: {
    src =
      if isFlambda2
      then
        fetchFromGitHub
          {
            owner = "janestreet";
            repo = "async_rpc_kernel";
            rev = "15f4fa1a6e31052b3a2738dc79dd4c5cb252dfd2";
            hash = "sha256-XyKvbevz6zm3mncDl85NuvbZ0pekSlddD85k4P26zjE=";
          }
      else o.src;
  });

  async_rpc_websocket = janePackage {
    pname = "async_rpc_websocket";
    hash = "sha256-pbgG872Av6rX/CH2sOKgTVR42XpP0xhzdR/Bqoq7bSU=";
    meta.description = "Library to serve and dispatch Async RPCs over websockets";
    propagatedBuildInputs = [ async_rpc_kernel async_websocket cohttp_async_websocket ];
  };

  async_sendfile = janePackage {
    pname = "async_sendfile";
    hash = "sha256-x2chts7U9hoGW6uvyfpHMkSwCx1JXhHX601Xg92Wk3U=";
    meta.description = "Thin wrapper around [Linux_ext.sendfile] to send full files";
    propagatedBuildInputs = [ async_unix ];
  };

  async_shell = janePackage {
    pname = "async_shell";
    hash = "sha256-/wqfuKiQQufs/KhNtBn8C9AzX7GbP8s8cyWGynJ0m1M=";
    meta.description = "Shell helpers for Async";
    propagatedBuildInputs = [ async shell ];
  };

  async_smtp = janePackage {
    pname = "async_smtp";
    hash = "sha256-RWtbg6Vpp71ock8Duya5j9Y89OUY4wRXh0pDOxM1NT4=";
    meta.description = "SMTP client and server";
    propagatedBuildInputs = [ async_extra async_inotify async_sendfile async_shell async_ssl email_message resource_cache re2_stable sexp_macro ];
  };

  async_ssl = (janePackage {
    pname = "async_ssl";
    hash = "sha256-7obEoeckwydi2wHBkBmX0LynY1QVCb3sQ/U945eteJo=";
    meta.description = "Async wrappers for SSL";
    buildInputs = [ dune-configurator ];
    propagatedBuildInputs = [ async ctypes ctypes-foreign openssl ];
    env = lib.optionalAttrs stdenv.cc.isGNU {
      NIX_CFLAGS_COMPILE = "-Wno-error=incompatible-pointer-types";
    };
  }).overrideAttrs (o: {
    src =
      if isFlambda2
      then
        fetchFromGitHub
          {
            owner = "janestreet";
            repo = "async_ssl";
            rev = "77910a421d99c7ccca173b9ec1b6b1b728ab2f82";
            hash = "sha256-qqEiH1SPWMBHTpg/O9JoNUyPQ4rf94lKEnQfqOPMaDc=";
          }
      else o.src;
  });

  async_udp = janePackage {
    pname = "async_udp";
    hash = "sha256-ekAqIE/SsPep5ExLTMp4c7muBdWO6U1cITbb70hGmbc=";
    meta.description = "Monadic concurrency library";
    propagatedBuildInputs = [ async core_unix ppx_jane ];
  };

  async_unix = (janePackage {
    pname = "async_unix";
    hash = "sha256-fA1e5AnNe/tMTMZ60jtGUofRi4rh+MmVx81kfhfaBaQ=";
    meta.description = "Monadic concurrency library";
    propagatedBuildInputs = [ async_kernel cstruct core_unix ];
  }).overrideAttrs (o: {
    src =
      if isFlambda2
      then
        fetchFromGitHub
          {
            owner = "janestreet";
            repo = "async_unix";
            rev = "6cc10173fff7a87c9f97839f70857ebc37cfa1dc";
            hash = "sha256-VcEbD/QqCTOSp8uqIb8usDWdEJHJWM+tmJTMFjMdshU=";
          }
      else o.src;
  });

  async_websocket = janePackage {
    pname = "async_websocket";
    hash = "sha256-22N+QO9hpkKHv3n9WkvtmJouxb/nuauv1UXdVV0zOGA=";
    meta.description = "A library that implements the websocket protocol on top of Async";
    propagatedBuildInputs = [ async cryptokit ];
  };

  babel = janePackage {
    pname = "babel";
    hash = "sha256-mRSlLXtaGj8DcdDZGUZbi16qQxtfb+fXkwxz6AXxN3o=";
    meta.description = "A library for defining Rpcs that can evolve over time without breaking backward compatibility.";
    propagatedBuildInputs = [ async_rpc_kernel core ppx_jane streamable tilde_f ];
    checkInputs = [ alcotest ];
  };

  base = (janePackage {
    pname = "base";
    version = "0.17.1";
    hash = "sha256-5wqBpOHhiIy9JUuxb3OnpZHrHSM7VODuLSihaIyeFn0=";
    meta.description = "Full standard library replacement for OCaml";
    buildInputs = [ dune-configurator ];
    propagatedBuildInputs = [ ocaml_intrinsics_kernel sexplib0 ];
  }).overrideAttrs (o: {
    src =
      if isFlambda2
      then
        fetchFromGitHub
          {
            owner = "janestreet";
            repo = "base";
            rev = "b6ea40197d507005d3970c3fadb60b0cc5f0b234";
            hash = "sha256-CkGYgDum7mCZrj7+mjLmhRtEsaU+sSu4E80rhBnIVUw=";
          }
      else o.src;
  });

  base_bigstring = (janePackage {
    pname = "base_bigstring";
    hash = "sha256-tGDtkVOU10GzNsJ4wZtbqyIMjY5lHM4+rA3+w34TYOE=";
    meta.description = "String type based on [Bigarray], for use in I/O and C-bindings";
    propagatedBuildInputs = [ int_repr ppx_jane ];
  }).overrideAttrs (o: {
    src =
      if isFlambda2
      then
        fetchFromGitHub
          {
            owner = "janestreet";
            repo = "base_bigstring";
            rev = "e0a078cd2065f20a215276520307603f9ad1e2cf";
            hash = "sha256-LSf2j9LprBnYijyO7mHnJWovD9f9ifhOKCYiRgA+Prs=";
          }
      else o.src;
  });

  base_quickcheck = (janePackage {
    pname = "base_quickcheck";
    hash = "sha256-jDxO+/9Qnntt6ZNX1xvaWvoJ0JpnPqeq8X8nsYpeqsY=";
    minimalOCamlVersion = "4.04.2";
    meta.description = "Randomized testing framework, designed for compatibility with Base";
    propagatedBuildInputs = [ ppx_base ppx_fields_conv ppx_let ppx_sexp_value splittable_random ];
  }).overrideAttrs (o: {
    src =
      if isFlambda2
      then
        fetchFromGitHub
          {
            owner = "janestreet";
            repo = "base_quickcheck";
            rev = "ca81f8736b682f00af3e843e878ee85027d50bff";
            hash = "sha256-aY5G69KLo+srFHEGq0l53hXatnmvE/55eEmArgv4sbA=";
          }
      else o.src;
  });

  base_trie = janePackage {
    pname = "base_trie";
    hash = "sha256-KuVDLJiEIjbvLCNI51iFLlsMli+hspWMyhrMk5pSL58=";
    minimalOCamlVersion = "4.14";
    meta.description = "Trie data structure library";
    propagatedBuildInputs = [ base core expect_test_helpers_core ppx_jane ];
  };

  bidirectional_map = janePackage {
    pname = "bidirectional_map";
    hash = "sha256-LnslyNdgQpa9DOAkwb0qq9/NdRvKNocUTIP+Dni6oYc=";
    minimalOCamlVersion = "4.14";
    meta.description = "A library for bidirectional maps and multimaps.";
  };

  bigdecimal = janePackage {
    pname = "bigdecimal";
    hash = "sha256-DMZJ9x3m9WUmNNvT3LYZZBAnzFy7RywpEG5lT2wWOCQ=";
    propagatedBuildInputs = [ bignum core expect_test_helpers_core ppx_jane zarith ];
    meta.description = "Arbitrary-precision decimal based on Zarith";
  };

  bignum = janePackage {
    pname = "bignum";
    hash = "sha256-QhVEZ97n/YUBBXYCshDa5UnZpv0BKK6xRN1kXabY3Es=";
    propagatedBuildInputs = [ core_kernel zarith zarith_stubs_js ];
    meta.description = "Core-flavoured wrapper around zarith's arbitrary-precision rationals";
  };

  bin_prot = (janePackage {
    pname = "bin_prot";
    hash = "sha256-5QeK8Cdu+YjNE/MLiQps6SSf5bRJ/eYZYsJH7oYSarg=";
    minimalOCamlVersion = "4.04.2";
    meta.description = "A binary protocol generator";
    propagatedBuildInputs = [
      ppx_compare
      ppx_custom_printf
      ppx_fields_conv
      ppx_optcomp
      ppx_variants_conv
      ppx_stable_witness
    ];
    postPatch = ''
      rm -rf xen META.bin_prot.template
    '';
  }).overrideAttrs (o: {
    src =
      if isFlambda2
      then
        fetchFromGitHub
          {
            owner = "janestreet";
            repo = "bin_prot";
            rev = "c8a7ce450fa20f240e9705673f29098fafb79b10";
            hash = "sha256-3RIa106qsseBtqGiuWYm9lYnLrzadRIJenoY9G2sQb8=";
          }
      else o.src;
  });

  bonsai = janePackage {
    pname = "bonsai";
    hash = "sha256-rr87o/w/a6NtCrDIIYmk2a5IZ1WJM/qJUeDqTLN1Gr4=";
    meta.description = "A library for building dynamic webapps, using Js_of_ocaml";
    buildInputs = [ ppx_pattern_bind ];
    nativeBuildInputs = [ js_of_ocaml-compiler ocaml-embed-file ppx_css ];
    postPatch = ''
      substituteInPlace examples/open_source/rpc_chat/server/src/bonsai_chat_open_source_native.ml \
      --replace-fail "?flush" ""
    '' + (if lib.versionAtLeast ocaml.version "5.2" then ''
      substituteInPlace "web/persistent_var.ml" "web/persistent_var.mli" \
        "web_test/of_bonsai_itself/rpc_effect_tests.ml" \
        --replace-fail "effect " "\#effect "

      substituteInPlace "web_ui/form/test/bonsai_web_ui_form_automatic_test.ml" \
        "web_ui/element_size_hooks/src/position_tracker.ml" "src/proc.ml" \
        "web_ui/element_size_hooks/src/bulk_size_tracker.ml" \
        "extra/bonsai_extra.ml" "extra/bonsai_extra.mli" \
        "web_ui/form/src/form_manual.ml" "web/persistent_var.ml" "web/rpc_effect.ml" \
        "web_ui/form/test/bonsai_web_ui_form_manual_test.ml" \
        "test/of_bonsai_itself/test_cont_bonsai.ml" "test/of_bonsai_itself/test_one_at_a_time.ml" \
        --replace-fail " effect" " \#effect"

      substituteInPlace \
        "test/of_bonsai_itself/test_effect_throttling.ml" \
        "web_ui/scroll_utilities/bonsai_web_ui_scroll_utilities.ml" \
        "test/of_bonsai_itself/test_proc_bonsai.ml" \
        --replace-fail " effect " " \#effect "

      substituteInPlace "src/cont.ml" "src/proc.ml" "web_ui/form/src/form_manual.ml" \
        "test/of_bonsai_itself/test_cont_bonsai.ml" \
        "test/of_bonsai_itself/test_proc_bonsai.ml" \
        --replace-fail "~effect" "~\#effect"

      substituteInPlace "src/cont.mli" "src/proc_intf.ml" \
        --replace-fail " effect:" " \#effect:"

      substituteInPlace "test/of_bonsai_itself/test_cont_bonsai.ml" \
        "test/of_bonsai_itself/test_proc_bonsai.ml" \
        --replace-fail "(effect" "(\#effect"

      substituteInPlace "test/of_bonsai_itself/test_one_at_a_time.ml" \
        --replace-fail ".effect" ".\#effect" \
        --replace-fail "(effect," "(\#effect,"

      substituteInPlace "test/of_bonsai_itself/test_proc_bonsai.ml" \
        --replace-fail " effect)" " \#effect)"
    '' else "");
    propagatedBuildInputs = [
      async
      async_durable
      async_extra
      async_js
      async_rpc_kernel
      async_rpc_websocket
      babel
      cohttp-async
      core_bench
      core_unix
      fuzzy_match
      indentation_buffer
      ordinal_abbreviation
      polling_state_rpc
      versioned_polling_state_rpc
      ppx_quick_test
      sexp_grammar
      incr_dom
      js_of_ocaml-ppx
      patdiff
      ppx_css
      ppx_typed_fields
      profunctor
      textutils
    ];
  };

  capitalization = janePackage {
    pname = "capitalization";
    hash = "sha256-wq8SO+SXF+UQhSu+ElVYv9erZ8S54G3SzJd0HX/Vwyk=";
    meta.description = "Defines case conventions and functions to rename identifiers according to them";
    propagatedBuildInputs = [ ppx_base ];
  };

  cinaps = janePackage {
    pname = "cinaps";
    version = "0.15.1";
    hash = "sha256-LycruanldSP251uYJjQqIfI76W0UQ6o5i5u8XjszBT0=";
    meta.description = "Trivial metaprogramming tool";
    propagatedBuildInputs = [ re ];
    doCheck = false;
  };

  codicons = janePackage {
    pname = "codicons";
    hash = "sha256-S4VrMObA5+SNeL/XsWU6SoSD/0TVvuqHjthUaQCDoRU=";
    meta.description = "Icons from VS code";
    propagatedBuildInputs = [ core ppx_jane virtual_dom ];
  };

  cohttp_async_websocket = janePackage {
    pname = "cohttp_async_websocket";
    hash = "sha256-0InGCF34LWQes9S4OgbR6w+6cylThYuj1Dj0aQyTnuY=";
    meta.description = "Websocket library for use with cohttp and async";
    propagatedBuildInputs = [ async_ssl async_websocket cohttp-async ppx_jane uri-sexp ];
    postPatch = ''
      substituteInPlace "src/cohttp_async_websocket.ml" \
        --replace-fail Cohttp_async.Io Cohttp_async.Io.IO \
        --replace-fail "read_websocket_response request reader" \
          'read_websocket_response request (Cohttp_async__Input_channel.create reader)'
    '';
  };

  cohttp_static_handler = janePackage {
    pname = "cohttp_static_handler";
    hash = "sha256-RB/sUq1tL8A3m9YhHHx2LFqoExTX187VeZI9MRb1NeA=";
    meta.description = "A library for easily creating a cohttp handler for static files";
    propagatedBuildInputs = [ cohttp-async ];
    postPatch = ''
      substituteInPlace "src/cohttp_static_handler.ml" --replace-fail "?flush" ""
    '';
  };

  command_rpc = janePackage {
    pname = "command_rpc";
    hash = "sha256-0qEI5inalvrjjFc7Hr+wPhK50dyiTUwcDQVWvTcHJ/8=";
    meta.description = "Utilities for Versioned RPC communication with a child process over stdin and stdout";
    propagatedBuildInputs = [ core async ppx_jane ];
    doCheck = false;
  };

  content_security_policy = janePackage {
    pname = "content_security_policy";
    hash = "sha256-AQN2JJA+5B0PERNNOA9FXX6rIeej40bwJtQmHP6GKw4=";
    meta.description = "A library for building content-security policies";
    propagatedBuildInputs = [ core ppx_jane base64 cryptokit ];
  };

  core = (janePackage {
    pname = "core";
    meta.description = "Industrial strength alternative to OCaml's standard library";
    version = "0.17.1";
    hash = "sha256-XkABcvglVJLVnWJmvfr5eVywyclPSDqanVOLQNqdNtQ=";
    buildInputs = [ jst-config ];
    propagatedBuildInputs = [
      base
      base_bigstring
      base_quickcheck
      ppx_jane
      time_now
      ppx_diff
    ];
  }).overrideAttrs (o: {
    src =
      if isFlambda2
      then
        fetchFromGitHub
          {
            owner = "janestreet";
            repo = "core";
            rev = "d8071a5d100759f5cf7b4c098112e139d43eb3df";
            hash = "sha256-EZK7tpG5oP0OVjAzhcFwj/lFX6hJUh8KxFxJfV9/L8s=";
          }
      else o.src;
  });

  core_bench = janePackage {
    pname = "core_bench";
    hash = "sha256-oXE3FuCCIbX2M0r4Ds2BMUU6g1bqe9E87lDo2CcMtMU=";
    meta.description = "Benchmarking library";
    propagatedBuildInputs = [ textutils core_extended delimited_parsing ];
  };

  core_extended = janePackage {
    pname = "core_extended";
    hash = "sha256-Xl6czD1gdnvHkXDz+qa7TWZq6dm8wlDqywxEIi2R6bI=";
    meta.description = "Extra components that are not as closely vetted or as stable as Core";
    propagatedBuildInputs = [ core_unix record_builder ];
  };

  core_kernel = (janePackage {
    pname = "core_kernel";
    hash = "sha256-l7U0edUCNHTroYMBHiEMDx5sl7opEmmmeo2Z06tCMts=";
    meta.description = "System-independent part of Core";
    buildInputs = [ jst-config ];
    propagatedBuildInputs = [ base_bigstring core int_repr sexplib uopt ];
    doCheck = false; # we don't have quickcheck_deprecated
  }).overrideAttrs (o: {
    src =
      if isFlambda2
      then
        fetchFromGitHub
          {
            owner = "janestreet";
            repo = "core_kernel";
            rev = "8c10b1c9653d2598cba5da65fe4003766461e6da";
            hash = "sha256-n2C4PVmOfVB91gkujNkpL8wNiYEx9egaCElyF52KOWQ=";
          }
      else o.src;
  });

  core_profiler = janePackage {
    pname = "core_profiler";
    hash = "sha256-UStqVfWHYr78SzMuOgJKMlz5PZBW5LZt1OwpSicEOF0=";
    meta.description = "Profiling library";
    propagatedBuildInputs = [ core core_kernel core_unix ppx_jane re2 shell textutils textutils_kernel ];
  };

  core_unix = (janePackage {
    pname = "core_unix";
    version = "0.17.1";
    hash = "sha256-xJoBW6TBBnzR5n38E5LHBFYO2CRIsME7OTdEZKn8EqU=";
    meta.description = "Unix-specific portions of Core";
    buildInputs = [ jst-config ];
    propagatedBuildInputs = [
      core
      core_kernel
      expect_test_helpers_core
      # ocaml_intrinsics
      ppx_jane
      timezone
      spawn
    ];
    postPatch = ''
      patchShebangs unix_pseudo_terminal/src/discover.sh
    '';
    doCheck = false;
  }).overrideAttrs (o: {
    src =
      if isFlambda2
      then
        fetchFromGitHub
          {
            owner = "janestreet";
            repo = "core_unix";
            rev = "e8efb05a79b22646dffafc66ac3df42873e3b518";
            hash = "sha256-FnBemRcIVw0NUI3grvtWYxocyLmTilHr/6YIsB3V1XQ=";
          }
      else o.src;
  });

  csvfields = janePackage {
    pname = "csvfields";
    hash = "sha256-hCH2NGQIRTU5U3TUOYHao6Kz5PhnLbySmzic4ytppEc=";
    propagatedBuildInputs = [ core num ];
    meta.description = "Runtime support for ppx_xml_conv and ppx_csv_conv";
  };

  dedent = janePackage {
    pname = "dedent";
    hash = "sha256-Scir/gaIhmNowXZ0tv57M/Iv1GXQIkyDks1sU1DAoIQ=";
    propagatedBuildInputs = [ base ppx_jane stdio ];
    meta.description = "A library for improving redability of multi-line string constants in code.";
  };

  delimited_parsing = janePackage {
    pname = "delimited_parsing";
    hash = "sha256-bgt99kQvaU7FPK1+K1UOAUbSaaaCB1DV23Cuo3A68M0=";
    propagatedBuildInputs = [ async core_extended ];
    meta.description = "Parsing of character (e.g., comma) separated and fixed-width values";
  };

  diffable = janePackage {
    pname = "legacy_diffable";
    hash = "sha256-wUSG04bHCnwqXpWKgkceAORs1inxexiPKZIR9fEVmCo=";
    propagatedBuildInputs = [ core ppx_jane stored_reversed streamable ];
    meta.description = "An interface for diffs.";
  };

  ecaml = janePackage {
    pname = "ecaml";
    hash = "sha256-CEroXMEIAfvXD603bnIVwzcrE3KbVaOOhGZastkQcdU=";
    meta.description = "Library for writing Emacs plugin in OCaml";
    propagatedBuildInputs = [
      async
      core_unix
      expect_test_helpers_core
    ];
  };

  email_message = janePackage {
    pname = "email_message";
    hash = "sha256-1OJ6bQb/rdyfAgMyuKT/ylpa8qBldZV5kEm0B45Ej1w=";
    meta.description = "E-mail message parser";
    propagatedBuildInputs = [ angstrom async base64 cryptokit magic-mime re2 ];
  };

  env_config = janePackage {
    pname = "env_config";
    hash = "sha256-vG309p7xqanTnrnHBwvuCO3YD4tVbTNa7F1F9sZDZE0=";
    meta.description = "Helper library for retrieving configuration from an environment variable";
    propagatedBuildInputs = [ async core core_unix ppx_jane ];
  };

  expect_test_helpers_async = janePackage {
    pname = "expect_test_helpers_async";
    hash = "sha256-oInNgNISqOrmQUXVxzjDy+mS06yPEeFPGIvaKnCETjk=";
    meta.description = "Async helpers for writing expectation tests";
    propagatedBuildInputs = [ async expect_test_helpers_core ];
  };

  expect_test_helpers_core = (janePackage {
    pname = "expect_test_helpers_core";
    hash = "sha256-vnlDZ8k3JFCdN6WGiaG9OEEdQJnw0/eMogFCfTXIu2Y=";
    meta.description = "Helpers for writing expectation tests";
    propagatedBuildInputs = [ core_kernel sexp_pretty ];
  }).overrideAttrs (o: {
    src =
      if isFlambda2
      then
        fetchFromGitHub
          {
            owner = "janestreet";
            repo = "expect_test_helpers_core";
            rev = "6aea0cabc965bfc08d04c8efe8fca81b72173162";
            hash = "sha256-k0DZz6DFmmvN8x4H/uCiyL4JztJ3OEfKDtx5bHu/QoU=";
          }
      else o.src;
  });

  fieldslib = janePackage {
    pname = "fieldslib";
    hash = "sha256-Zfnc32SghjZYTlnSdo6JPm4WCb7BPVjrWNDfeMZHaiU=";
    minimalOCamlVersion = "4.14";
    meta.description = "Syntax extension to define first class values representing record fields, to get and set record fields, iterate and fold over all fields of a record and create new record values";
    propagatedBuildInputs = [ base ];
  };

  file_path = janePackage {
    pname = "file_path";
    minimalOCamlVersion = "4.11";
    hash = "sha256-XSLfYasn6qMZmDzAUGssOM9EX09n2W9/imTgNoSBEyk=";
    meta.description =
      "A library for typed manipulation of UNIX-style file paths";
    propagatedBuildInputs = [
      async
      core
      core_kernel
      core_unix
      expect_test_helpers_async
      expect_test_helpers_core
      ppx_jane
    ];
  };

  fuzzy_match = janePackage {
    pname = "fuzzy_match";
    hash = "sha256-XB1U4mY0LcdsKYRnmV0SR4ODTIZynZetBk5X5SdHs44=";
    meta.description = "A library for fuzzy string matching";
    propagatedBuildInputs = [ core ppx_jane ];
  };

  fzf = janePackage {
    pname = "fzf";
    minimalOCamlVersion = "4.08";
    hash = "sha256-yHdvC3cB5sVXsZQbtNzUZkaaqOe/7y8pDHgLwugAlQg=";
    meta.description = "A library for running the fzf command line tool";
    propagatedBuildInputs = [ async core_kernel ppx_jane fzf ];
  };

  gel = janePackage {
    pname = "gel";
    hash = "sha256-zGDlxbJINXD1qG7EifZGDfKbQpehdHyR/WLRJRYlwUg=";
    meta.description = ''
      A library to mark non-record fields global. GEL stands for Global Even
      if inside a Local.
    '';
    propagatedBuildInputs = [ base ppx_jane ];
  };

  hex_encode = janePackage {
    pname = "hex_encode";
    minimalOCamlVersion = "4.14";
    hash = "sha256-5DqaCJllphdEreOpzAjT61qb3M6aN9b2xhiUjHVLrvE=";
    meta.description = "Hexadecimal encoding library";
    propagatedBuildInputs = [ core ppx_jane ];
    checkInputs = [ ounit ];
  };

  hg_lib = janePackage {
    pname = "hg_lib";
    minimalOCamlVersion = "4.14";
    hash = "sha256-DbKp1U7gRd4+3cbEYZbX2jKU578XCHYQDn/x8PA7zaM=";
    meta.description = "A library that wraps the Mercurial command line interface";
    propagatedBuildInputs = [ async core core_kernel expect_test_helpers_core ppx_jane ];
  };

  higher_kinded = janePackage {
    pname = "higher_kinded";
    hash = "sha256-6aZxgGzltRs2aS4MYJh23Gpoqcko6xJxU11T6KixXno=";
    meta.description = "A library with an encoding of higher kinded types in OCaml";
    propagatedBuildInputs = [ base ppx_jane ];
  };

  incr_dom = janePackage {
    pname = "incr_dom";
    hash = "sha256-dkF7+aq5Idw1ltDgGEjGYspdmOXjXqv8AA27b4M7U8A=";
    meta.description = "A library for building dynamic webapps, using Js_of_ocaml";
    buildInputs = [ js_of_ocaml-ppx ];
    propagatedBuildInputs = [ async_js incr_map incr_select virtual_dom ];
  };

  incr_dom_interactive = janePackage {
    pname = "incr_dom_interactive";
    hash = "sha256-QdwjQnf2CBaCKLDWHJhaCuBOd2HP0sNZaLu+tQp11XU=";
    meta.description = "A monad for composing chains of interactive UI elements";
    buildInputs = [ js_of_ocaml-ppx ];
    propagatedBuildInputs = [
      async_js
      async_kernel
      incr_dom
      incr_map
      incr_select
      incremental
      ppx_jane
      splay_tree
      virtual_dom
      js_of_ocaml
    ];
  };

  incr_dom_partial_render = janePackage {
    pname = "incr_dom_partial_render";
    hash = "sha256-bGTcUXRwy5tmdwhOwbLNYl3fDye7b5+z3hyTWGsUc3Y=";
    meta.description = "A library for simplifying rendering of large amounts of data";
    buildInputs = [ js_of_ocaml-ppx ];
    propagatedBuildInputs = [ incr_dom ppx_jane ppx_pattern_bind splay_tree virtual_dom js_of_ocaml ];
  };

  incr_dom_sexp_form = janePackage {
    pname = "incr_dom_sexp_form";
    hash = "sha256-xAArZwTNARoLbyyMTjWm9NQkOn4xM+0qja686cdtfMc=";
    meta.description = "A library for building forms that allow the user to edit complicated types";
    buildInputs = [ js_of_ocaml-ppx ];
    propagatedBuildInputs = [
      incr_dom
      incr_dom_interactive
      incr_map
      incr_select
      incremental
      ppx_jane
      splay_tree
      virtual_dom
      js_of_ocaml
    ];
  };

  incr_map = janePackage {
    pname = "incr_map";
    hash = "sha256-qNahlxe3Pe1EEcFz1bAKUw3vBaNjgDlahQeuj/+VqbI=";
    meta.description = "Helpers for incremental operations on map like data structures";
    buildInputs = [ ppx_pattern_bind ];
    propagatedBuildInputs = [ abstract_algebra bignum diffable incremental streamable ];
  };

  incr_select = janePackage {
    pname = "incr_select";
    hash = "sha256-/VCNiE8Y7LBL0OHd5V+tB/b3HGKhfSvreU6LZgurYAg=";
    meta.description = "Handling of large set of incremental outputs from a single input";
    propagatedBuildInputs = [ incremental ];
  };

  incremental = janePackage {
    pname = "incremental";
    hash = "sha256-siBN36Vv0Bktyxh+8tL6XkUGLqSYMxqvd0UWuTRgAnI=";
    meta.description = "Library for incremental computations";
    propagatedBuildInputs = [ core_kernel lru_cache ];
  };

  indentation_buffer = janePackage {
    pname = "indentation_buffer";
    hash = "sha256-/IUZyRkcxUsddzGGIoaLpXbpCxJ1satK79GkzPxSPSc=";
    meta.description = "A library for building strings with indentation";
    propagatedBuildInputs = [ core ppx_jane ];
  };

  int_repr = (janePackage {
    pname = "int_repr";
    hash = "sha256-yeaAzw95zB1wow9Alg18CU+eemZVxjdLiO/wVRitDwE=";
    meta.description = "Integers of various widths";
    propagatedBuildInputs = [ base ppx_jane ];
  }).overrideAttrs (o: {
    src =
      if isFlambda2
      then
        fetchFromGitHub
          {
            owner = "janestreet";
            repo = "int_repr";
            rev = "898d314e0ac9aac93d7a3fd9baa1e345a5e37810";
            hash = "sha256-nw/H1WSEH3Xx+FEsP2/yuX6+0s1GaDNRlrbL4R/lKLA=";
          }
      else o.src;
  });

  jane_rope = janePackage {
    pname = "jane_rope";
    hash = "sha256-Lo4+ZUX9R2EGrz4BN+LqdJgVXB3hQqNifgwsjFC1Hfs=";
    minimalOCamlVersion = "4.14";
    meta.description = "String representation with cheap concatenation.";
    propagatedBuildInputs = [ base ppx_jane ];
  };

  jane-street-headers = janePackage {
    pname = "jane-street-headers";
    hash = "sha256-nEa40utpXA3KiFhp9inWurKyDF4Jw1Jlln6fiW5MAkM=";
    minimalOCamlVersion = "4.04.2";
    meta.description = "Jane Street C header files";
  };

  janestreet_cpuid = (janePackage {
    pname = "janestreet_cpuid";
    hash = "sha256-3ZwEZQSkJJyFW5/+C9x8nW6+GrfVwccNFPlcs7qNcjQ=";
    minimalOCamlVersion = "4.04.2";
    meta.description = "A library for parsing CPU capabilities out of the `cpuid` instruction.";
    propagatedBuildInputs = [ core core_kernel ppx_jane ];
  }).overrideAttrs (_: {
    src = fetchFromGitHub {
      owner = "janestreet";
      repo = "janestreet_cpuid";
      rev = "55223d9708388fe990553669d881f78a811979b9";
      hash = "sha256-XzG/G65W/9hkVPI+MiQV160XpjGgU3tDNBdz39tXvHQ=";
    };
  });

  janestreet_csv = janePackage {
    pname = "janestreet_csv";
    hash = "sha256-at7ywGDaYIDsqhxxLYJhB8a697ccfPtKKI8LvCmRgG8=";
    minimalOCamlVersion = "4.04.2";
    meta.description = "Tools for working with CSVs on the command line";
    propagatedBuildInputs = [
      async
      bignum
      core_kernel
      core_unix
      csvfields
      delimited_parsing
      fieldslib
      numeric_string
      ppx_jane
      re2
      textutils
      ocaml_pcre
      tyxml
    ];
  };

  js_of_ocaml_patches = janePackage {
    pname = "js_of_ocaml_patches";
    hash = "sha256-N61IEZLGfCU3ZX+sw35DAUqUh3u8RaCFcNlXxU1dvL8=";
    meta.description = "Additions to js_of_ocaml's standard library that are required by Jane Street libraries.";
    propagatedBuildInputs = [ js_of_ocaml js_of_ocaml-ppx ];
    # Compat with jsoo 3.8.2
    postPatch = ''
      substituteInPlace js_of_ocaml_patches.ml js_of_ocaml_patches.mli \
        --replace-fail "unit meth" "bool Js_of_ocaml.Js.t -> unit meth"
    '';
  };

  jsonaf = janePackage {
    pname = "jsonaf";
    hash = "sha256-MMIDHc40cmPpO0n8yREIGMyFndw3NfvGUhy6vHnn40w=";
    meta.description = "A library for parsing, manipulating, and serializing data structured as JSON";
    propagatedBuildInputs = [ base ppx_jane angstrom faraday ];
  };

  jst-config = janePackage {
    pname = "jst-config";
    hash = "sha256-xwQ+q2Hsduu2vWMWFcjoj3H8Es00N7Mv9LwIZG4hw7c=";
    meta.description = "Compile-time configuration for Jane Street libraries";
    buildInputs = [ dune-configurator base ppx_assert ];
  };

  krb = null;

  line-up-words = janePackage {
    pname = "line-up-words";
    hash = "sha256-LXXS4tlJFjdkWxcTrHGi+PiVq2QCG49OgmOnLWuyrTY=";
    meta.description = "Align words in an intelligent way";
    propagatedBuildInputs = [ core core_unix patience_diff ppx_jane re2 ocaml_pcre ];
  };

  lru_cache = janePackage {
    pname = "janestreet_lru_cache";
    hash = "sha256-/UMSccN9yGAXF7/g6ueSnsfPSnF1fm0zJIRFsThZvH8=";
    meta.description = "An LRU Cache implementation.";
    propagatedBuildInputs = [ core ppx_jane ];
  };

  man_in_the_middle_debugger = janePackage {
    pname = "man_in_the_middle_debugger";
    minimalOCamlVersion = "4.14";
    hash = "sha256-ImEzn/EssgW63vdGhLMp4NB/FW0SsCMQ32ZNAs7bDg4=";
    propagatedBuildInputs = [ async core ppx_jane angstrom-async ];
    meta.description = "Man-in-the-middle debugging library";
  };

  memtrace = janePackage {
    pname = "memtrace";
    version = "0.2.3";
    meta.description = "Streaming client for Memprof";
    hash = "sha256-dWkTrN8ZgNUz7BW7Aut8mfx8o4n8f6UZaDv/7rbbwNs=";
    doCheck = ! lib.versionOlder "5.0" ocaml.version;
  };

  memtrace_viewer = janePackage {
    pname = "memtrace_viewer";
    hash = "sha256-vtqhN+ro9UUqmgt8mxNq3caAvtjBr2YVFFvrYF22JoE=";
    buildInputs = [ js_of_ocaml-ppx ];
    nativeBuildInputs = [ js_of_ocaml ocaml-embed-file ];
    propagatedBuildInputs = [
      async_js
      async_kernel
      async_rpc_kernel
      bonsai
      codicons
      core_kernel
      ppx_jane
      async_rpc_websocket
      ppx_pattern_bind
      virtual_dom
      memtrace
    ];
    postPatch = ''
      substituteInPlace "server/src/memtrace_viewer_native.ml" \
        --replace-fail "?flush" ""
    '' + (if lib.versionAtLeast ocaml.version "5.2" then ''
      substituteInPlace "client/src/after_next_display.ml" \
        --replace-fail "effect" "\#effect"
    '' else "");
    meta.description = ''
      Processes traces produced by the Memtrace library and displays the
      top allocators in a table or flame graph. To help find space leaks,
      events can be filtered by lifetime, showing only allocations of
      objects that are still live at peak memory usage.
    '';
  };

  mlt_parser = janePackage {
    pname = "mlt_parser";
    hash = "sha256-p+KDdm8JX3fTDlhnm+ZlJRPdi73xRENlOyOPlUsWx0Y=";
    meta.description = "Parsing of top-expect files";
    propagatedBuildInputs = [
      core
      ppx_here
      ppx_jane
      ppxlib
    ];
  };

  n_ary = janePackage {
    pname = "n_ary";
    hash = "sha256-xg4xK3m7SoO1P+rBHvPqFMLx9JXnADEeyU58UmAqW6s=";
    meta.description = "A library for N-ary datatypes and operations.";
    propagatedBuildInputs = [
      base
      expect_test_helpers_core
      ppx_compare
      ppx_enumerate
      ppx_hash
      ppx_jane
      ppx_sexp_conv
      ppx_sexp_message
    ];
  };

  netsnmp = janePackage {
    pname = "netsnmp";
    hash = "sha256-Pi36I/ULt980G005nMegLg9vhyLH9c/3v6YmT0dXsyk=";
    meta.description = "An interface to the Net-SNMP client library";
    propagatedBuildInputs = [ async core ppx_jane net-snmp openssl ];
  };

  notty_async = janePackage {
    pname = "notty_async";
    minimalOCamlVersion = "4.14";
    hash = "sha256-zD9V2vtgCJfjj4DAQLReGIno2SLeryukCPgScyoQFP0=";
    propagatedBuildInputs = [ async ppx_jane notty ];
    meta.description = "An Async driver for Notty";
  };

  numeric_string = janePackage {
    pname = "numeric_string";
    hash = "sha256-cU5ETGfavkkiqZOjehCYg06YdDk8W+ZDqz17FGWHey8=";
    propagatedBuildInputs = [ ppx_jane ];
    meta.description = ''
      A comparison function for strings that sorts numeric fragments of strings
      according to their numeric value, so that e.g. \"abc2\" < \"abc10\".
    '';
  };

  ocaml-compiler-libs = (janePackage ({
    pname = "ocaml-compiler-libs";
    version = "0.16.0";
    hash = "00if2f7j9d8igdkj4rck3p74y17j6b233l91mq02drzrxj199qjv";
    meta.description = "OCaml compiler libraries repackaged";
  } // (if lib.versionAtLeast ocaml.version "5.2" then {
    version = "0.17.0";
    hash = "sha256-QaC6BWrpFblra6X1+TrlK+J3vZxLvLJZ2b0427DiQzM=";
  } else {
    version = "0.12.4";
    hash = "00if2f7j9d8igdkj4rck3p74y17j6b233l91mq02drzrxj199qjv";
  }))).overrideAttrs
    (_: {
      patches = if isFlambda2 then [ ./flambda2-compiler-libs.patch ] else [ ];
    });

  ocaml-embed-file = janePackage {
    pname = "ocaml-embed-file";
    hash = "sha256-7fyZ5DNcRHud0rd4dLUv9Vyf3lMwMVxgkl9jVUn1/lw=";
    propagatedBuildInputs = [ async ppx_jane ];
    meta.description = "Files contents as module constants";
  };

  ocaml_intrinsics = (janePackage {
    pname = "ocaml_intrinsics";
    hash = "sha256-Ndt6ZPJamBYzr1YA941BLwvRgkkbD8AEQR/JjjR38xI=";
    meta.description = "Intrinsics";
    buildInputs = [ dune-configurator ocaml_intrinsics_kernel ];
  }).overrideAttrs (o: {
    src =
      if isFlambda2
      then
        fetchFromGitHub
          {
            owner = "janestreet";
            repo = "ocaml_intrinsics";
            rev = "9dc4e031e33de559385ca2e4c13f7f19ba804dcc";
            hash = "sha256-OpyjX/RDbBrUu5VAqo2dV9sSaskQyOVKiftJKLRuS1I=";
          }
      else o.src;

  });

  ocaml_intrinsics_kernel = (janePackage {
    pname = "ocaml_intrinsics_kernel";
    version = "0.17.1";
    hash = "sha256-2fBrJtI7bXbdFlILKhcBWWj4Q8/9hpi73egVbZmgBak=";
    meta.description = "Intrinsics";
  }).overrideAttrs (o: {
    src =
      if isFlambda2
      then
        fetchFromGitHub
          {
            owner = "janestreet";
            repo = "ocaml_intrinsics_kernel";
            rev = "997a5da542ade9efe0ff743e02ed21f291cde1ed";
            hash = "sha256-lHkX/6G5Hf5EbfvyvxK+B19jhLNOWDYVv+AN5+kOKUc=";
          }
      else o.src;
  });

  ocaml_openapi_generator = janePackage {
    pname = "ocaml_openapi_generator";
    hash = "sha256-HCq9fylcVjBMs8L6E860nw+EonWEQadlyEKpQI6mynU=";
    meta.description = "An OpenAPI 3 to OCaml client generator.";
    nativeBuildInputs = [ ocaml-embed-file ];
    propagatedBuildInputs = [
      async
      core
      core_kernel
      core_unix
      jsonaf
      ppx_jane
      ppx_jsonaf_conv
      httpaf
      jingoo
      uri
    ];
  };

  ocaml-probes = janePackage {
    pname = "ocaml-probes";
    hash = "sha256-jml2OxJJUYXshCx+1AiDO7kFhctcw7vB86bpPDWFJJY=";
    meta.description = "USDT probes for OCaml: command line tool";
    propagatedBuildInputs = [ owee linuxHeaders ];
    doCheck = false;
  };

  of_json = janePackage {
    pname = "of_json";
    minimalOCamlVersion = "4.14";
    hash = "sha256-pZCiwXRwZK6ohsGz/WLacgo48ekdT35uD4VESvGxH8A=";
    meta.description = "A friendly applicative interface for Jsonaf.";
    propagatedBuildInputs = [ core core_extended jsonaf ppx_jane ];
  };

  ordinal_abbreviation = janePackage {
    pname = "ordinal_abbreviation";
    hash = "sha256-kmTGnGbhdiUoXXw2DEAeZJL2sudEf8BRRt2RHCdL7HU=";
    meta.description = "A minimal library for generating ordinal names of integers.";
    propagatedBuildInputs = [ base ppx_jane ];
  };

  pam = janePackage {
    pname = "pam";
    hash = "sha256-oDqLSlwis9AbjVlI0A5ocXTferzgrxbRKBIQIhOfAhg=";
    meta = {
      description = "OCaml bindings for the Linux-PAM library";
      platforms = lib.platforms.linux;
    };
    propagatedBuildInputs = [ pam core ppx_jane ];
  };

  parsexp = janePackage {
    pname = "parsexp";
    hash = "sha256-iKrZ6XDLM6eRl7obaniDKK6X8R7Kxry6HD7OQBwh3NU=";
    minimalOCamlVersion = "4.14";
    meta.description = "S-expression parsing library";
    propagatedBuildInputs = [ sexplib0 ];
  };

  parsexp_io = janePackage {
    pname = "parsexp_io";
    hash = "sha256-r1HXO3VJ167QUgz4UIQuB5sY6p10FLE3Jrp9NmoDKoE=";
    minimalOCamlVersion = "4.14";
    meta.description = "S-expression parsing library";
    propagatedBuildInputs = [ base parsexp ppx_js_style stdio ];
  };

  patdiff = janePackage {
    pname = "patdiff";
    hash = "sha256-iphpQ0b8i+ItY57zM4xL9cID9GYuTCMZN7SYa7TDprI=";
    # Used by patdiff-git-wrapper.  Providing it here also causes the shebang
    # line to be automatically patched.
    buildInputs = [ bash ];
    propagatedBuildInputs = [ core_unix patience_diff ocaml_pcre ];
    doCheck = false;
    meta = {
      description = "File Diff using the Patience Diff algorithm";
    };
  };

  patience_diff = janePackage {
    pname = "patience_diff";
    hash = "sha256-sn/8SvMt7kzzuYUwhB/uH/3mO1aIKHw/oRYRzA7goFU=";
    meta.description = "Diff library using Bram Cohen's patience diff algorithm";
    propagatedBuildInputs = [ core_kernel ];
  };

  pipe_with_writer_error = (janePackage {
    pname = "pipe_with_writer_error";
    hash = lib.fakeHash;
    propagatedBuildInputs = [ ppx_jane async_kernel core ];
    meta.description =
      "Pipe that forces readers to consider errors from writers while reading";
  }).overrideAttrs (_: {
    src =
      if isFlambda2
      then
        fetchFromGitHub
          {
            owner = "janestreet";
            repo = "pipe_with_writer_error";
            rev = "5c3d4a746db76eacc23b0c090b63b073af989db3";
            hash = "sha256-ekfOUVxu52nJQDiVoxDVytPQIy/R2EU3TTtkJVydOWE=";
          }
      else
        fetchFromGitHub
          {
            owner = "janestreet";
            repo = "pipe_with_writer_error";
            rev = "5c3d4a746db76eacc23b0c090b63b073af989db3";
            hash = "sha256-ekfOUVxu52nJQDiVoxDVytPQIy/R2EU3TTtkJVydOWE=";
          };
  });

  polling_state_rpc = janePackage {
    pname = "polling_state_rpc";
    minimalOCamlVersion = "4.14";
    hash = "sha256-fZKGva11ztuM+q0Lc6rr9NEH/Qo+wFmE6Rr1/TJm7rA=";
    meta.description = "An RPC which tracks state on the client and server so it only needs to send diffs across the wire.";
    propagatedBuildInputs = [
      async_kernel
      async_rpc_kernel
      babel
      core
      core_kernel
      diffable
      ppx_jane
    ];
  };

  posixat = janePackage {
    pname = "posixat";
    hash = "sha256-G+5q8x1jfG3wEwNzX2tkcC2Pm4E5/ZYxQyBwCUNXIrw=";
    minimalOCamlVersion = "4.07";
    propagatedBuildInputs = [ ppx_optcomp ppx_sexp_conv ];
    meta.description = "Binding to the posix *at functions";
  };

  postgres_async = janePackage {
    pname = "postgres_async";
    minimalOCamlVersion = "4.14";
    hash = "sha256-IZ5k9L5k9RWdneyS/ADiHuvo0KeibR8P0ygLTIGsGLc=";
    meta.description = "OCaml/async implementation of the postgres protocol (i.e., does not use C-bindings to libpq)";
    propagatedBuildInputs = [ async async_ssl core core_kernel ppx_jane postgresql ];
  };

  ppx_accessor = janePackage {
    pname = "ppx_accessor";
    hash = "sha256-vK6lA0J98bDGtVthIdU76ckzH+rpNUD1cQ3vMzHy0Iw=";
    meta.description = "[@@deriving] plugin to generate accessors for use with the Accessor libraries";
    propagatedBuildInputs = [ accessor ];
  };

  ppx_assert = janePackage {
    pname = "ppx_assert";
    hash = "sha256-o9ywdFH6+qoJ3eWb29/gGlkWkHDMuBx626mNxrT1D8A=";
    minimalOCamlVersion = "4.14";
    meta.description = "Assert-like extension nodes that raise useful errors on failure";
    propagatedBuildInputs = [ ppx_cold ppx_compare ppx_here ppx_sexp_conv ];
  };

  ppx_base = janePackage {
    pname = "ppx_base";
    hash = "sha256-/s7c8vfLIO1pPajNldMgurBKXsSzQ8yxqFI6QZCHm5I=";
    minimalOCamlVersion = "4.14";
    meta.description = "Base set of ppx rewriters";
    propagatedBuildInputs = [
      ppx_cold
      ppx_enumerate
      ppx_hash
      ppx_globalize
    ];
  };

  ppx_bench = janePackage {
    pname = "ppx_bench";
    hash = "sha256-y4nL/wwjJUL2Fa7Ne0f7SR5flCjT1ra9M1uBHOUZWCg=";
    minimalOCamlVersion = "4.14";
    meta.description = "Syntax extension for writing in-line benchmarks in ocaml code";
    propagatedBuildInputs = [ ppx_inline_test ];
  };

  ppx_bin_prot = (janePackage {
    pname = "ppx_bin_prot";
    hash = "sha256-nQps/+Csx3+6H6KBzIm/dLCGWJ9fcRD7JxB4P2lky0o=";
    minimalOCamlVersion = "4.14";
    meta.description = "Generation of bin_prot readers and writers from types";
    propagatedBuildInputs = [ bin_prot ppx_here ];
    doCheck = false; # circular dependency with ppx_jane
  }).overrideAttrs (o: {
    src =
      if isFlambda2
      then
        fetchFromGitHub
          {
            owner = "janestreet";
            repo = "ppx_bin_prot";
            rev = "9427476a1043deaaf733da03572427694a566d83";
            hash = "sha256-npyGcr+kTyukrTl6UmLieT2hOHKXg1lfZeg2eRg1UqA=";
          }
      else o.src;
  });

  ppx_cold = janePackage {
    pname = "ppx_cold";
    hash = "sha256-fFZqlcbUS7D+GjnxSjGYckkQtx6ZcPNtOIsr6Rt6D9A=";
    minimalOCamlVersion = "4.14";
    meta.description = "Expands [@cold] into [@inline never][@specialise never][@local never]";
    propagatedBuildInputs = [ base ppxlib ];
  };

  ppx_compare = (janePackage {
    pname = "ppx_compare";
    hash = "sha256-uAXB9cba0IBl+cA2CAuGVVxuos4HXH5jlB6Qjxx44Y0=";
    minimalOCamlVersion = "4.14";
    meta.description = "Generation of comparison functions from types";
    propagatedBuildInputs = [ ppxlib ppxlib_jane base ];
  }).overrideAttrs (o: {
    src =
      if isFlambda2
      then
        fetchFromGitHub
          {
            owner = "janestreet";
            repo = "ppx_compare";
            rev = "aa309df74530af02877d5adb9699d9448ba34e0b";
            hash = "sha256-Akp4p/n2qKZ+BVQ99Erym6Suw58OCb3QFb6indzOxKs=";
          }
      else o.src;
  });

  ppx_conv_func = janePackage {
    pname = "ppx_conv_func";
    hash = "sha256-PJ8T0u8VkxefaxojwrmbMXDjqyfAIxKe92B8QqRY2JU=";
    minimalOCamlVersion = "4.14";
    meta.description = "Part of the Jane Street's PPX rewriters collection.";
    propagatedBuildInputs = [ base ppxlib ];
  };

  ppx_csv_conv = janePackage {
    pname = "ppx_csv_conv";
    hash = "sha256-NtqfagLIYiuyBjEAxilAhATx8acJwD7LykHBzfr+yAc=";
    minimalOCamlVersion = "4.14";
    meta.description = "Generate functions to read/write records in csv format";
    propagatedBuildInputs = [ base csvfields ppx_conv_func ppx_fields_conv ];
  };

  ppx_custom_printf = janePackage {
    pname = "ppx_custom_printf";
    hash = "sha256-DFgDb9MIFCqglYoMgPUN0zEaxkr7VJAXgLxq1yp8ap4=";
    minimalOCamlVersion = "4.04.2";
    meta.description = "Printf-style format-strings for user-defined string conversion";
    propagatedBuildInputs = [ ppx_sexp_conv ];
  };

  ppx_css = janePackage {
    pname = "ppx_css";
    hash = "sha256-mzLMVtNTy9NrVaNgsRa+oQynxXnh2qlHJCfr3FLFJ2I=";
    meta.description = "A ppx that takes in css strings and produces a module for accessing the unique names defined within";
    propagatedBuildInputs = [
      async
      async_unix
      core_kernel
      core_unix
      ppxlib
      js_of_ocaml
      js_of_ocaml-ppx
      sedlex
      virtual_dom
    ];
  };

  ppx_demo = janePackage {
    pname = "ppx_demo";
    hash = "sha256-blD96GhicOj3b6jYNniSpq6fBR+ul9Y2kn0ZmfbeVMo=";
    meta.description = "PPX that exposes the source code string of an expression/module structure.";
    propagatedBuildInputs = [ core dedent ppx_jane ppxlib ];
  };

  ppx_derive_at_runtime = janePackage {
    pname = "ppx_derive_at_runtime";
    hash = "sha256-Y/z4BKFRt3z1lUGdc7SznIv/ys//dZHoPSnsouj1GtI=";
    meta.description = "Define a new ppx deriver by naming a runtime module.";
    propagatedBuildInputs = [ base expect_test_helpers_core ppx_jane ppxlib ];
  };

  ppx_disable_unused_warnings = janePackage {
    pname = "ppx_disable_unused_warnings";
    hash = "sha256-KHWIufXU+k6xCLf8l50Pp/1JZ2wFrKnKT/aQYpadlmU=";
    minimalOCamlVersion = "4.04.2";
    meta.description = "Expands [@disable_unused_warnings] into [@warning \"-20-26-32-33-34-35-36-37-38-39-60-66-67\"]";
    propagatedBuildInputs = [ base ppxlib ];
  };

  ppx_diff = (janePackage {
    pname = "ppx_diff";
    hash = "sha256-MAn+vcU6vLR8g16Wq1sORyLcLgWxLsazMQY1syY6HsA=";
    meta.description = ''
      A PPX rewriter that generates the implementation of [Ldiffable.S].
      Generates diffs and update functions for OCaml types.
    '';
    propagatedBuildInputs = [ ppxlib_jane ppx_jane gel ];
  }).overrideAttrs (o: {
    src =
      if isFlambda2
      then
        fetchFromGitHub
          {
            owner = "janestreet";
            repo = "ppx_diff";
            rev = "4a766274acab51e0e85be19161d1f896597230ce";
            hash = "sha256-vT5Xt9Z3AB2DiajRD5corrwRC3N1HkawOEq/30Ff234=";
          }
      else o.src;
  });

  ppx_embed_file = janePackage {
    pname = "ppx_embed_file";
    hash = "sha256-Ew6/X7oAq81ldERU37QWXQdgReEtPD/lxbku8WZNJ6A=";
    meta.description = ''
      A PPX that allows embedding files directly into executables/libraries
      as strings or bytes
    '';
    propagatedBuildInputs = [ core ppx_jane ppxlib shell ];
  };

  ppx_enumerate = (janePackage {
    pname = "ppx_enumerate";
    hash = "sha256-YqBrxp2fe91k8L3aQVW6egoDPj8onGSRueQkE2Icdu4=";
    minimalOCamlVersion = "4.04.2";
    meta.description = "Generate a list containing all values of a finite type";
    propagatedBuildInputs = [ base ppxlib ppxlib_jane ];
  }).overrideAttrs (o: {
    src =
      if isFlambda2
      then
        fetchFromGitHub
          {
            owner = "janestreet";
            repo = "ppx_enumerate";
            rev = "b1167dbc9dc6f71daa7c592956f0c99f2bfd8ae8";
            hash = "sha256-+b9SiwcCSZcCa48R6Q0BOmWHPNV5fXQavf29bJEq0Sc=";
          }
      else o.src;
  });

  ppx_expect = (janePackage {
    pname = "ppx_expect";
    version = "0.17.2";
    hash = "sha256-na9n/+shkiHIIUQ2ZitybQ6NNsSS9gWFNAFxij+JNVo=";
    minimalOCamlVersion = "4.14";
    meta.description = "Cram like framework for OCaml";
    propagatedBuildInputs = [ base ppx_here ppx_inline_test stdio re ppx_compare ];
    doCheck = false; # test build rules broken
  }).overrideAttrs (o: {
    src =
      if isFlambda2
      then
        fetchFromGitHub
          {
            owner = "janestreet";
            repo = "ppx_expect";
            rev = "640e8a8bbedefb5a8c0f72929a645e8003ac9c3e";
            hash = "sha256-J5ePw8FD2Pft6MBA6Er/4LPvxDVuJpUI19CNI2UJqc4=";
          }
      else o.src;
  });

  ppx_fields_conv = janePackage {
    pname = "ppx_fields_conv";
    hash = "sha256-FA7hDgqJMJ2obsVwzwaGnNLPvjP0SkTec8Nh3znuNDQ=";
    minimalOCamlVersion = "4.04.2";
    meta.description = "Generation of accessor and iteration functions for ocaml records";
    propagatedBuildInputs = [ fieldslib ppxlib ];
  };

  ppx_fixed_literal = janePackage {
    pname = "ppx_fixed_literal";
    hash = "sha256-Xq+btvZQ/+6bcHoH9DcrrhD5CkwpFeedn7YEFHeLzsU=";
    minimalOCamlVersion = "4.04.2";
    meta.description = "Simpler notation for fixed point literals";
    propagatedBuildInputs = [ base ppxlib ];
  };

  ppx_globalize = (janePackage {
    pname = "ppx_globalize";
    minimalOCamlVersion = "4.14";
    hash = "sha256-LKV5zfaf6AXn3NzOhN2ka8NtjItPTIsfmoJVBw5bYi8=";
    meta.description = "A ppx rewriter that generates functions to copy local values to the global heap";
    propagatedBuildInputs = [ base ppxlib ppxlib_jane ];
  }).overrideAttrs (o: {
    src =
      if isFlambda2
      then
        fetchFromGitHub
          {
            owner = "janestreet";
            repo = "ppx_globalize";
            rev = "e1748590e4685ecb7a49fb727c5d2d15b073bd17";
            hash = "sha256-q681BioQSnFBiehKRcUrii3WOvzONz6yqiWt7XMIiIc=";
          }
      else
        o.src;
  });

  ppx_hash = (janePackage {
    pname = "ppx_hash";
    hash = "sha256-GADCLoF2GjZkvAiezn0xyReCs1avrUgjJGSS/pMNq38=";
    minimalOCamlVersion = "4.04.2";
    meta.description = "A ppx rewriter that generates hash functions from type expressions and definitions";
    propagatedBuildInputs = [ ppx_compare ppx_sexp_conv ];
  }).overrideAttrs (o: {
    src =
      if isFlambda2
      then
        fetchFromGitHub
          {
            owner = "janestreet";
            repo = "ppx_hash";
            rev = "b39dac492b40bbc017c387830921d9c1420c12ca";
            hash = "sha256-TyUn2bc6BWKxtW+jXE7G01TE8RAazVlA571clsRqqAw=";
          }
      else o.src;
  });

  ppx_here = janePackage {
    pname = "ppx_here";
    hash = "sha256-ybwOcv82uDRPTlfaQgaBJHVq6xBxIRUj07CXP131JsM=";
    minimalOCamlVersion = "4.04.2";
    meta.description = "Expands [%here] into its location";
    propagatedBuildInputs = [ base ppxlib ];
    doCheck = false; # test build rules broken
  };

  ppx_ignore_instrumentation = janePackage {
    pname = "ppx_ignore_instrumentation";
    hash = "sha256-73dp8XKfsLO0Z6A1p5/K7FjxgeUPMBkScx0IjfbOV+w=";
    minimalOCamlVersion = "4.08";
    meta.description = "Ignore Jane Street specific instrumentation extensions";
    propagatedBuildInputs = [ ppxlib ];
  };

  ppx_inline_test = janePackage {
    pname = "ppx_inline_test";
    hash = "sha256-pNdrmAlT3MUbuPUcMmCRcUIXv4fZ/o/IofJmnUKf8Cs=";
    minimalOCamlVersion = "4.04.2";
    meta.description = "Syntax extension for writing in-line tests in ocaml code";
    propagatedBuildInputs = [ ppxlib time_now ];
    doCheck = false; # test build rules broken
  };

  ppx_jane = (janePackage {
    pname = "ppx_jane";
    hash = "sha256-HgIob7iJkV0HcGi6IjjSUWdKOAu2TsC3GMyzpjYS1cs=";
    minimalOCamlVersion = "4.04.2";
    meta.description = "Standard Jane Street ppx rewriters";
    propagatedBuildInputs = [
      base_quickcheck
      ppx_bin_prot
      ppx_disable_unused_warnings
      ppx_expect
      ppx_fixed_literal
      ppx_ignore_instrumentation
      ppx_log
      ppx_module_timer
      ppx_optcomp
      ppx_optional
      ppx_pipebang
      ppx_stable
      ppx_string
      ppx_string_conv
      ppx_typerep_conv
      ppx_variants_conv
      ppx_tydi
    ];
  }).overrideAttrs (o: {
    src =
      if isFlambda2
      then
        fetchFromGitHub
          {
            owner = "janestreet";
            repo = "ppx_jane";
            rev = "b699ffd25f2de209bb8b2d2158c4c9ee8b3d434a";
            hash = "sha256-WRaT6huQaii0F00Ar77/6mmY2t3Y5g2EnXs/v2DVAMg=";
          }
      else o.src;
  });

  ppx_jsonaf_conv = janePackage {
    pname = "ppx_jsonaf_conv";
    hash = "sha256-v7CYOJ1g4LkqIv5De5tQjjkBWXqKHbvqfSr0X5jBUuM=";
    minimalOCamlVersion = "4.14";
    meta.description =
      "[@@deriving] plugin to generate Jsonaf conversion functions";
    propagatedBuildInputs = [ base jsonaf ppx_jane ppxlib ];
  };

  ppx_js_style = janePackage {
    pname = "ppx_js_style";
    hash = "sha256-7jRzxe4bLyZ2vnHeqWiLlCUvOlNUAk0dwCfBFhrykUU=";
    minimalOCamlVersion = "4.14";
    meta.description = "Code style checker for Jane Street Packages";
    propagatedBuildInputs = [ octavius base ppxlib ];
  };

  ppx_let = (janePackage {
    pname = "ppx_let";
    hash = "sha256-JkNQgbPHVDH659m4Xy9ipcZ/iqGtj5q1qQn1P+O7TUY=";
    minimalOCamlVersion = "4.04.2";
    meta.description = "Monadic let-bindings";
    propagatedBuildInputs = [ ppxlib ppx_here ppxlib_jane ];
  }).overrideAttrs (o: {
    src =
      if isFlambda2
      then
        fetchFromGitHub
          {
            owner = "janestreet";
            repo = "ppx_let";
            rev = "56a954cb7c19df5dee61b43efab12132ecf957e4";
            hash = "sha256-nkd84j0Jw5MvNVcQi95ZdFFzb7IBaA25Eg9gpSwVxOE=";
          }
      else o.src;
  });

  ppx_log = janePackage {
    pname = "ppx_log";
    hash = "sha256-llnjWeJH4eg5WtegILRxdwO3RWGWTFeCIKr6EbrUDI4=";
    minimalOCamlVersion = "4.08.0";
    meta.description = "Ppx_sexp_message-like extension nodes for lazily rendering log messages";
    propagatedBuildInputs = [
      base
      ppx_compare
      ppx_enumerate
      ppx_expect
      ppx_fields_conv
      ppx_let
      ppx_sexp_value
      ppx_variants_conv
      ppx_string
      ppx_here
      ppx_sexp_conv
      ppx_sexp_message
      sexplib
    ];
    doCheck = false;
  };

  ppx_module_timer = janePackage {
    pname = "ppx_module_timer";
    hash = "sha256-OWo1Ij9JAxsk9HlTlaz9Qw2+4YCvXDmIvytAOgFCLPI=";
    minimalOCamlVersion = "4.04.2";
    meta.description = "Ppx rewriter that records top-level module startup times";
    propagatedBuildInputs = [ stdio time_now ];
  };

  ppx_optcomp = (janePackage {
    pname = "ppx_optcomp";
    hash = "sha256-H9oTzhJx9IGRkcwY2YEvcvNgeJ8ETNO95qKcjTXJBwk=";
    minimalOCamlVersion = "4.04.2";
    meta.description = "Optional compilation for OCaml";
    propagatedBuildInputs = [ stdio ppxlib ppxlib_jane ];
  }).overrideAttrs (o: {
    src =
      if isFlambda2
      then
        fetchFromGitHub
          {
            owner = "janestreet";
            repo = "ppx_optcomp";
            rev = "f47aea71763e80c02c78b253d33b122726be7e93";
            hash = "sha256-u3hmnfjJgTuvesMXbAa8slv67Dp+JO2E55/ADnMWojo=";
          }
      else o.src;
  });

  ppx_optional = janePackage {
    pname = "ppx_optional";
    hash = "sha256-SHw2zh6lG1N9zWF2b3VWeYzRHUx4jUxyOYgHd2/N9wE=";
    minimalOCamlVersion = "4.04.2";
    meta.description = "Pattern matching on flat options";
    propagatedBuildInputs = [ base ppxlib ppxlib_jane ];
  };

  ppx_pattern_bind = janePackage {
    pname = "ppx_pattern_bind";
    hash = "sha256-IVDvFU9ERB2YFJOgP/glYcO4KhEH5VdQ7wCCfreboqA=";
    minimalOCamlVersion = "4.14";
    meta.description = "A ppx for writing fast incremental bind nodes in a pattern match";
    propagatedBuildInputs = [ ppx_let ];
  };

  ppx_pipebang = janePackage {
    pname = "ppx_pipebang";
    hash = "sha256-GBa1zzNChZOQfVSHyUeDEMFxuNUT3lj/pIQi/l1J35M=";
    minimalOCamlVersion = "4.04.2";
    meta.description = "A ppx rewriter that inlines reverse application operators `|>` and `|!`";
    propagatedBuildInputs = [ ppxlib ];
  };

  ppx_python = janePackage {
    pname = "ppx_python";
    hash = "sha256-WqTYH5Zz/vRak/CL1ha8oUbQ8+XRuUu9610uj8II74o=";
    meta.description = "A [@@deriving] plugin to generate Python conversion functions ";
    propagatedBuildInputs = [ ppx_base ppxlib pyml ];
    doCheck = false;
  };

  ppx_quick_test = janePackage {
    pname = "ppx_quick_test";
    hash = "sha256-Kxb0IJcosC4eYlUjEfZE9FhY8o1/gDHHLWD5Cby5hXY=";
    meta.description = ''
      Spiritual equivalent of let%expect_test, but for property based tests as
      an ergonomic wrapper to write quickcheck tests.
    '';
    propagatedBuildInputs = [
      async
      async_kernel
      base_quickcheck
      core
      core_kernel
      expect_test_helpers_core
      ppx_expect
      ppx_here
      ppx_jane
    ];
  };

  ppx_sexp_conv = (janePackage {
    pname = "ppx_sexp_conv";
    minimalOCamlVersion = "4.14";
    hash = "sha256-hUi0I50SODK1MpL86xy8eM8yn8f4q1Hv4LP9zFnnr70=";
    meta.description = "[@@deriving] plugin to generate S-expression conversion functions";
    propagatedBuildInputs = [ ppxlib sexplib0 base ppxlib_jane ];
  }).overrideAttrs (o: {
    src =
      if isFlambda2
      then
        fetchFromGitHub
          {
            owner = "janestreet";
            repo = "ppx_sexp_conv";
            rev = "37ba21167ae36f3c71bfd8d87d385272840ebf9f";
            hash = "sha256-OB5y8OBs7Hl6g78CPol//Z73c2jBbWjIwy+XopSV8A8=";
          }
      else o.src;
  });

  ppx_sexp_message = janePackage {
    pname = "ppx_sexp_message";
    hash = "sha256-SNgTvsTUgFzjqHpyIYk4YuA4c5MbA9e77YUEsDaKTeA=";
    minimalOCamlVersion = "4.04.2";
    meta.description = "A ppx rewriter for easy construction of s-expressions";
    propagatedBuildInputs = [ ppx_here ppx_sexp_conv ];
  };

  ppx_sexp_value = janePackage {
    pname = "ppx_sexp_value";
    hash = "sha256-f96DLNFI+s3TKsOj01i6xUoM9L+qRgAXbbepNis397I=";
    minimalOCamlVersion = "4.04.2";
    meta.description = "A ppx rewriter that simplifies building s-expressions from ocaml values";
    propagatedBuildInputs = [ ppx_here ppx_sexp_conv ];
  };

  ppx_stable = (janePackage {
    pname = "ppx_stable";
    hash = "sha256-N5oPjjQcLgiO9liX8Z0vg0IbQXaGZ4BqOgwvuIKSKaA=";
    minimalOCamlVersion = "4.04.2";
    meta.description = "Stable types conversions generator";
    propagatedBuildInputs = [ base ppxlib ppxlib_jane ];
  }).overrideAttrs (o: {
    src =
      if isFlambda2
      then
        fetchFromGitHub
          {
            owner = "janestreet";
            repo = "ppx_stable";
            rev = "006955a00a247585f21cb9446507c24b47a14cec";
            hash = "sha256-pfRxOBJOYb5t1BsZfiZNHfFvpZjwCe71xiXIlAahQMo=";
          }
      else o.src;
  });

  ppx_stable_witness = (janePackage {
    pname = "ppx_stable_witness";
    hash = "sha256-k45uR/OMPRsi5450CuUo592EVc82DPhO8TvBPjgJTh0=";
    minimalOCamlVersion = "4.14";
    meta.description = ''
      Ppx extension for deriving a witness that a type is intended to be
      stable. In this context, stable means that the serialization format will
      never change. This allows programs running at different versions of the
      code to safely communicate.
    '';
    propagatedBuildInputs = [ base ppxlib ppxlib_jane ];
  }).overrideAttrs (o: {
    src =
      if isFlambda2
      then
        fetchFromGitHub
          {
            owner = "janestreet";
            repo = "ppx_stable_witness";
            rev = "cec735a627ca91354c32e0f3965fab734ae8cbc4";
            hash = "sha256-/QbyG1LHr9L82QhUcYFm8KTgUo6pkLr/NX+LjSvcPYw=";
          }
      else o.src;
  });

  ppx_string = janePackage {
    pname = "ppx_string";
    minimalOCamlVersion = "4.04.2";
    hash = "sha256-taAvJas9DvR5CIiFf38IMdNqLJ0QJmnIdcNJAaVILgA=";
    meta.description = "Ppx extension for string interpolation";
    propagatedBuildInputs = [ ppx_base ppxlib stdio ];
  };

  ppx_string_conv = (janePackage {
    pname = "ppx_string_conv";
    hash = "sha256-r+XubSXjxVyCsra99D6keJ/lmXeK5SZbI6h/IFghvPQ=";
    meta.description = "Ppx extension for generating of_string & to_string";
    propagatedBuildInputs = [ base ppxlib ppx_let ppx_string capitalization ];
  }).overrideAttrs (o: {
    src =
      if isFlambda2
      then
        fetchFromGitHub
          {
            owner = "janestreet";
            repo = "ppx_string_conv";
            rev = "6e6f95e39f529017e83f9eee33e6270e09f877e7";
            hash = "sha256-sIlOv50+1kZBN3jv2oH3yJvFMsr5S8pFTuP9XjkK830=";
          }
      else o.src;
  });

  ppx_tydi = janePackage {
    pname = "ppx_tydi";
    hash = "sha256-PM89fP6Rb6M99HgEzQ7LfpW1W5adw6J/E1LFQJtdd0U=";
    minimalOCamlVersion = "4.14";
    meta.description = "Let expressions, inferring pattern type from expression.";
    propagatedBuildInputs = [ base ppxlib ];
  };

  ppx_typed_fields = janePackage {
    pname = "ppx_typed_fields";
    hash = "sha256-aTPEBBc1zniZkEmzubGkU064bwGnefBOjVDqTdPm2w8=";
    meta.description = "GADT-based field accessors and utilities";
    propagatedBuildInputs = [ core ppx_jane ppxlib ];
  };

  ppx_typerep_conv = (janePackage {
    pname = "ppx_typerep_conv";
    minimalOCamlVersion = "4.04.2";
    hash = "sha256-V9yOSy3cj5/bz9PvpO3J+aeFu1G+qGQ8AR3gSczUZbY=";
    meta.description = "Generation of runtime types from type declarations";
    propagatedBuildInputs = [ ppxlib typerep ppxlib_jane ];
  }).overrideAttrs (o: {
    src =
      if isFlambda2
      then
        fetchFromGitHub
          {
            owner = "janestreet";
            repo = "ppx_typerep_conv";
            rev = "31c6ede608ccdde8df06922e3e3b50c5fd7e5820";
            hash = "sha256-2PQwnxg0ThR/mzn3wOe1IP2ovEOvZ3pqq3ITsp2bnWw=";
          }
      else o.src;
  });

  ppx_variants_conv = (janePackage {
    pname = "ppx_variants_conv";
    minimalOCamlVersion = "4.04.2";
    hash = "sha256-Av2F699LzVCpwcdji6qG0jt5DVxCnIY4eBLaPK1JC10=";
    meta.description = "Generation of accessor and iteration functions for ocaml variant types";
    propagatedBuildInputs = [ variantslib ppxlib ppxlib_jane ];
  }).overrideAttrs (o: {
    src =
      if isFlambda2
      then
        fetchFromGitHub
          {
            owner = "janestreet";
            repo = "ppx_variants_conv";
            rev = "ace387c672335639f37934d349b88840c9946789";
            hash = "sha256-e0e6JKTTJS4alLxQFb+U0pbl4FMkYeLSK+YtLHdD2fc=";
          }
      else o.src;
  });

  ppx_xml_conv = janePackage {
    pname = "ppx_xml_conv";
    minimalOCamlVersion = "4.14";
    hash = "sha256-4U0ZlV8OYXwNUz3bbxf49qovGTI8vyn7L3YJy0AndrM=";
    meta.description = "Generate XML conversion functions from records";
    propagatedBuildInputs = [ base csvfields ppx_conv_func ppx_fields_conv ];
  };

  ppx_yojson_conv_lib = janePackage {
    pname = "ppx_yojson_conv_lib";
    minimalOCamlVersion = "4.14";
    hash = "sha256-XGgpcAEemBNEagblBjpK+BiL0OUsU2JPqOq+heHbqVk=";
    meta.description = "Runtime lib for ppx_yojson_conv";
    propagatedBuildInputs = [ yojson ];
  };

  ppx_yojson_conv = janePackage {
    pname = "ppx_yojson_conv";
    minimalOCamlVersion = "4.14";
    hash = "sha256-O7t6Bq23C4avBD1ef1DFL+QopZt3ZzHYAcdapF16cGY=";
    meta.description = "A PPX syntax extension that generates code for converting OCaml types to and from Yojson";
    propagatedBuildInputs = [ base ppx_js_style ppx_yojson_conv_lib ppxlib ];
  };

  ppxlib_jane = (janePackage {
    pname = "ppxlib_jane";
    hash = "sha256-8NC8CHh3pSdFuRDQCuuhc2xxU+84UAsGFJbbJoKwd0U=";
    meta.description = "Utilities for working with Jane Street AST constructs";
    propagatedBuildInputs = [ ppxlib ];
  }).overrideAttrs (o: {
    src =
      if isFlambda2
      then
        fetchFromGitHub
          {
            owner = "janestreet";
            repo = "ppxlib_jane";
            rev = "5793adbe30e2294d351a8145289cf2a220d0714f";
            hash = "sha256-KEQMDIN/AMfEbFGlRrFt/tcShuKe9P0QIxA5RdM8Wuo=";
          }
      else if lib.versionOlder "5.4" ocaml.version then
        fetchFromGitHub
          {
            owner = "janestreet";
            repo = "ppxlib_jane";
            rev = "7614fc7d9bef1b69a74c417c3df5eb3a9ed61719";
            hash = "sha256-cqF7aT0ubutRxsSTD5aHnHx4zvlPDkTzdBqONU6EgO0=";
          }
      else if lib.versionOlder "5.3" ocaml.version then
        fetchFromGitHub
          {
            owner = "janestreet";
            repo = "ppxlib_jane";
            rev = "v0.17.2";
            hash = "sha256-AQJSdKtF6p/aG5Lx8VHVEOsisH8ep+iiml6DtW+Hdik=";
          }
      else o.src;
  });

  profunctor = janePackage {
    pname = "profunctor";
    hash = "sha256-WYPJLt3kYvIzh88XcPpw2xvSNjNX63/LvWwIDK+Xr0Q=";
    meta.description = "A library providing a signature for simple profunctors and traversal of a record";
    propagatedBuildInputs = [ base ppx_jane record_builder ];
  };

  protocol_version_header = janePackage {
    pname = "protocol_version_header";
    hash = "sha256-WKy4vahmmj6o82/FbzvFYfJFglgNMrka0XhtCMUyct4=";
    meta.description = "Protocol versioning";
    propagatedBuildInputs = [ core_kernel ];
  };

  pythonlib = janePackage {
    pname = "pythonlib";
    version = "0.16.0";
    hash = "sha256-HrsdtwPSDSaMB9CDIR9P5iaAmLihUrReuNAPIYa+s3Y=";
    meta.description = "A library to help writing wrappers around ocaml code for python";
    buildInputs = [ ppx_optcomp ];
    minimalOCamlVersion = "4.11";
    propagatedBuildInputs = [
      ppx_expect
      ppx_let
      ppx_python
      stdio
      typerep
      ppx_string
      expect_test_helpers_core
    ];
  };

  re_parser = janePackage {
    pname = "re_parser";
    hash = "sha256-kZx652Znr3rUA/P5KiYvTScvtp55fzjnoxwQOZlvKiY=";
    meta.description = "Typed parsing using regular expressions.";
    propagatedBuildInputs = [ base regex_parser_intf re ];
  };

  re2 = janePackage {
    pname = "re2";
    hash = "sha256-0VCSOzrVouMRVZJumcqv0F+HQFXlFfVEFIhYq7Tfhrg=";
    meta.description = "OCaml bindings for RE2, Google's regular expression library";
    propagatedBuildInputs = [ core_kernel jane_rope regex_parser_intf ];
    prePatch = ''
      substituteInPlace src/re2_c/dune --replace-fail 'CXX=g++' 'CXX=c++'
    '';
  };

  re2_stable = janePackage {
    pname = "re2_stable";
    version = "0.14.0";
    hash = "sha256-gyet2Pzn7ZIqQ+UP2J51pRmwaESY2LSGTqCMZZwDTE4=";
    meta.description = "Re2_stable adds an incomplete but stable serialization of Re2";
    propagatedBuildInputs = [ core re2 ];
  };

  record_builder = janePackage {
    pname = "record_builder";
    hash = "sha256-NQ0Wizxi/wD8BCwt8hxZWnEpLBTn3XkaG+96ooOKIFE=";
    meta.description = "A library which provides traversal of records with an applicative";
    propagatedBuildInputs = [ base ppx_jane ];
  };

  redis-async = janePackage {
    pname = "redis-async";
    hash = "sha256-bwKPEnK2uJq5H65BDAL1Vk3qSr5kUwaCEiFsgaCdHw8=";
    meta.description = "Redis client for Async applications";
    propagatedBuildInputs = [ async bignum core core_kernel ppx_jane ];
  };

  regex_parser_intf = janePackage {
    pname = "regex_parser_intf";
    hash = "sha256-j6zWJf5c5qWphMqb9JpEAMGDDsrzV+NU2zrGmZHSAgk=";
    meta.description = "Interface shared by Re_parser and Re2.Parser";
    propagatedBuildInputs = [ base ];
  };

  resource_cache = janePackage {
    pname = "resource_cache";
    hash = "sha256-1WEjvdnl47rjCCMvGxqDKAb2ny6pJDlvDfZhKp+40Jg=";
    meta.description = "General resource cache";
    propagatedBuildInputs = [ async_rpc_kernel ];
  };

  rpc_parallel = janePackage {
    pname = "rpc_parallel";
    hash = "sha256-HWg1duoluycT3DYvVSUakYQ93A0Ci+1b8r7rmauw9L0=";
    meta.description = "Type-safe parallel library built on top of Async_rpc";
    propagatedBuildInputs = [
      async
      core
      core_kernel
      core_unix
      ppx_jane
      sexplib
      qtest
    ];
    # depends on "qtest_deprecated" which doesn't exist publicly.
    doCheck = false;
  };

  semantic_version = janePackage {
    pname = "semantic_version";
    hash = "sha256-2Z2C+1bfI6W7Pw7SRYw8EkaVVwQkkm+knCrJIfsJhPE=";
    meta.description = "Semantic versioning";
    propagatedBuildInputs = [ core ppx_jane re ];
  };

  sequencer_table = janePackage {
    pname = "sequencer_table";
    hash = "sha256-VBt6ogz3sVfPLrRCf17AtOdj2IQgUiHRMibBBERICgI=";
    meta.description = "A table of [Async.Sequencer]'s, indexed by key";
    propagatedBuildInputs = [ async_kernel core ppx_jane ];
  };

  sexp = janePackage {
    pname = "sexp";
    hash = "sha256-89SNb0MeJbetRRbA5qbBQPXIcLQ0QCeSf8p9v5yUTP0=";
    propagatedBuildInputs = [
      async
      core
      csvfields
      jsonaf
      re2
      sexp_diff
      sexp_macro
      sexp_pretty
      sexp_select
      shell
    ];
    meta.description = "S-expression swiss knife";
  };

  sexp_diff = janePackage {
    pname = "sexp_diff";
    hash = "sha256-0p1+jMa2b/GJu+JtN+XUuR04lFQchxMeu9ikfgErqMU=";
    propagatedBuildInputs = [ core_kernel ];
    meta.description = "Code for computing the diff of two sexps";
  };

  sexp_grammar = janePackage {
    pname = "sexp_grammar";
    hash = "sha256-yagp8bEZvc4joV81w56hAb17mUbnekuzECVcwLIvYoE=";
    meta.description = "Sexp grammar helpers";
    propagatedBuildInputs = [
      core
      ppx_bin_prot
      ppx_compare
      ppx_hash
      ppx_let
      ppx_sexp_conv
      ppx_sexp_message
      zarith
    ];
  };

  sexp_macro = janePackage {
    pname = "sexp_macro";
    hash = "sha256-KXJ+6uR38ywkr8uT8n2bWk10W7vW2ntMgxgF4ZvzzWU=";
    propagatedBuildInputs = [ async sexplib ];
    meta.description = "Sexp macros";
  };

  sexp_pretty = janePackage {
    pname = "sexp_pretty";
    hash = "sha256-DcgLlwp3AMC1QzFYPzi7aHA+VhnhbG6p/fLDTMx8ATc=";
    meta.description = "S-expression pretty-printer";
    propagatedBuildInputs = [ ppx_base re sexplib ];
  };

  sexp_select = janePackage {
    pname = "sexp_select";
    hash = "sha256-3AUFRtNe32TEB7lItcu7XlEv+3k+4QTitcTnT0kg28Y=";
    minimalOCamlVersion = "4.14";
    propagatedBuildInputs = [ base ppx_jane core_kernel ];
    meta.description = "A library to use CSS-style selectors to traverse sexp trees";
  };

  sexp_string_quickcheck = janePackage {
    pname = "sexp_string_quickcheck";
    hash = "sha256-yhSjkEwn4vmefnwC3bgE9PxItnAmXQj8+JkNdn9cm84=";
    minimalOCamlVersion = "4.14";
    propagatedBuildInputs = [ core parsexp ppx_jane ];
    meta.description = "Quickcheck helpers for strings parsing to sexps";
  };

  sexplib0 = (janePackage {
    pname = "sexplib0";
    hash = "sha256-Q53wEhRet/Ou9Kr0TZNTyXT5ASQpsVLPz5n/I+Fhy+g=";
    minimalOCamlVersion = "4.08.0";
    meta.description = "Library containing the definition of S-expressions and some base converters";
  }).overrideAttrs (o: {
    src =
      if isFlambda2
      then
        fetchFromGitHub
          {
            owner = "janestreet";
            repo = "sexplib0";
            rev = "450be52c1553c6708b73af50def3cb5732566c50";
            hash = "sha256-PXKNkuLNwbPV9yLoMKPP1BfOBaR9Sf8e73LNrCy5VmQ=";
          }
      else o.src;
  });

  sexplib = (janePackage {
    pname = "sexplib";
    hash = "sha256-DxTMAQbskZ87pMVQnxYc3opGGCzmUKGCZfszr/Z9TGA=";
    minimalOCamlVersion = "4.04.2";
    meta.description = "Library for serializing OCaml values to and from S-expressions";
    propagatedBuildInputs = [ num parsexp ];
  }).overrideAttrs (o: {
    src =
      if isFlambda2
      then
        fetchFromGitHub
          {
            owner = "janestreet";
            repo = "sexplib";
            rev = "a9fca79eb16dbad7c23d2d7adc4f20a3cdca8714";
            hash = "sha256-qnLZsbnxYen0UdJQUqlWLwucb++tC6QskURgv2QAmg0=";
          }
      else o.src;
  });

  shell = janePackage {
    pname = "shell";
    hash = "sha256-MJerTFLGrUaR3y3mnKVrH5EQHYBXZyuVL+n2wJZ9HoU=";
    meta.description = "Yet another implementation of fork&exec and related functionality";
    buildInputs = [ jst-config ];
    propagatedBuildInputs = [ textutils ];
    checkInputs = [ ounit ];
  };

  shexp = janePackage {
    pname = "shexp";
    hash = "sha256-tf9HqZ01gMWxfcpe3Pl3rdPTPgIEdb59iwzwThznqAc=";
    minimalOCamlVersion = "4.07";
    propagatedBuildInputs = [ posixat spawn ];
    meta.description = "Process library and s-expression based shell";
  };

  spawn = janePackage {
    pname = "spawn";
    version = "0.17.0";
    hash = "sha256-IBQWLbG5u2xXd9mmxNgLw472FEExPiOReYFLiKgnt3M=";
    meta.description = "Spawning sub-processes";
    checkInputs = [ ppx_expect ];
    doCheck = ! (lib.versionOlder "5.3" ocaml.version);
  };

  splay_tree = janePackage {
    pname = "splay_tree";
    hash = "sha256-gRHRqUKjFEgkL1h8zSbqJkf+gHxhh61AtAT+mkPcz+k=";
    meta.description = "A splay tree implementation";
    propagatedBuildInputs = [ core_kernel ];
  };

  splittable_random = janePackage {
    pname = "splittable_random";
    hash = "sha256-LlaCxL17GBZc33spn/JnunpaMQ47n+RXS8CShBlaRWA=";
    meta.description = "PRNG that can be split into independent streams";
    propagatedBuildInputs = [ base ppx_assert ppx_bench ppx_sexp_message ];
  };

  streamable = janePackage {
    pname = "streamable";
    hash = "sha256-FtrAX4nsacCO5HTVxwLgwwT8R2sASJ05qu4gT2ZVSDg=";
    minimalOCamlVersion = "4.14";
    meta.description = "A collection of types suitable for incremental serialization.";
    propagatedBuildInputs = [ async_kernel async_rpc_kernel base core core_kernel ppx_jane ppxlib ];
  };

  string_dict = janePackage {
    pname = "string_dict";
    hash = "sha256-E6ImZU5HeGH3I5o1O4Hl5nW9ZnoX7SVlp8gppkW2Zds=";
    minimalOCamlVersion = "4.14";
    meta.description = "Efficient static string dictionaries";
    propagatedBuildInputs = [ base ppx_compare ppx_hash ];
  };

  stdio = janePackage {
    pname = "stdio";
    hash = "sha256-N4VMUq6zWdYiJarVECSadxnoXJKh6AsIIaChmHFSbdA=";
    minimalOCamlVersion = "4.04.2";
    meta.description = "Standard IO library for OCaml";
    propagatedBuildInputs = [ base ];
  };

  stored_reversed = janePackage {
    pname = "stored_reversed";
    hash = "sha256-FPyQxXaGAzFWW6GiiqKQgU+6/lAZhEQwhNnXsmqKkzg=";
    propagatedBuildInputs = [ core ppx_jane ];
    meta.description = "A library for representing a list temporarily stored in reverse order.";
  };

  textutils = (janePackage {
    pname = "textutils";
    hash = "sha256-J58sqp9fkx3JyjnH6oJLCyEC0ZvnuDfqLVl+dt3tEgA=";
    meta.description = "Text output utilities";
    propagatedBuildInputs = [ core_unix textutils_kernel ];
  }).overrideAttrs (o: {
    src =
      if isFlambda2
      then
        fetchFromGitHub
          {
            owner = "janestreet";
            repo = "textutils";
            rev = "177a4e7533f8116d62366a33e3a918948f838878";
            hash = "sha256-NNgDQ4TruuJ59gBTHBLXXGe1jGdYIr0SegMWyqiMOUU=";
          }
      else o.src;
  });

  textutils_kernel = (janePackage {
    pname = "textutils_kernel";
    hash = "sha256-B5ExbKMRSw4RVJ908FVGob2soHFnJ6Ajsdn0q8lDhio=";
    meta.description = "Text output utilities";
    propagatedBuildInputs = [ core ppx_jane uutf ];
  }).overrideAttrs (o: {
    src =
      if isFlambda2
      then
        fetchFromGitHub
          {
            owner = "janestreet";
            repo = "textutils_kernel";
            rev = "b3a651f25a963e2ed93dd83b678815b9e46a90af";
            hash = "sha256-lDrYv1tB/lqfbhY/2YE4bPbynxDTUkwgKch1DedH9Vs=";
          }
      else o.src;
  });

  tilde_f = janePackage {
    pname = "tilde_f";
    hash = "sha256-tuddvOmhk0fikB4dHNdXamBx6xfo4DCvivs44QXp5RQ=";
    minimalOCamlVersion = "4.14";
    meta.description = "Provides a let-syntax for continuation-passing style.";
    propagatedBuildInputs = [ base ppx_jane ];
  };

  time_now = janePackage {
    pname = "time_now";
    hash = "sha256-bTPWE9+x+zmdLdzLc1naDlRErPZ8m4WXDJL2iLErdqk=";
    minimalOCamlVersion = "4.04.2";
    meta.description = "Reports the current time";
    buildInputs = [ jst-config ppx_optcomp ];
    propagatedBuildInputs = [ jane-street-headers base ppx_base ];
  };

  timezone = janePackage {
    pname = "timezone";
    hash = "sha256-/6OLWMrkyQSVTNJ24zRy6v4DObt9q99s75QRS/VVxXE=";
    meta.description = "Time-zone handling";
    propagatedBuildInputs = [ core_kernel ];
  };

  toplevel_backend = janePackage {
    pname = "toplevel_backend";
    hash = "sha256-rm/nZoKIKA6f37QqT1+qoztUAtvUE20BDCndakaQxRg=";
    meta.description = "Shared backend for setting up toplevels";
    propagatedBuildInputs = [ core ppx_here ppx_jane ppx_optcomp findlib ];
  };

  toplevel_expect_test = janePackage {
    pname = "toplevel_expect_test";
    hash = "sha256-MC2C5bhRgJ57szFyM7J7gvVGZpMML8iNm2bIvvJTR6Y=";
    meta.description = "Expectation tests for the OCaml toplevel";
    propagatedBuildInputs = [
      core
      ppx_here
      ppx_jane
      ppx_optcomp
      findlib
      core_unix
      toplevel_backend
      mlt_parser
    ];
  };

  topological_sort = janePackage {
    pname = "topological_sort";
    hash = "sha256-jLkJnh5lasrphI6BUKv7oVPrKyGqNm6VIGYthNs04iU=";
    meta.description = "Topological sort algorithm";
    propagatedBuildInputs = [ ppx_jane stdio ];
  };

  tracing = janePackage {
    pname = "tracing";
    hash = "sha256-gzATwxUC6bLbCbspZHbcDpzQf2GrGA7tlhdJB9mTD0g=";
    minimalOCamlVersion = "4.14";
    meta.description = "Tracing library";
    propagatedBuildInputs = [ async core core_kernel core_unix ppx_jane ];
  };

  typerep = (janePackage {
    pname = "typerep";
    hash = "sha256-hw03erwLx9IAbkBibyhZxofA5jIi12rFJOHNEVYpLSk=";
    version = "0.17.1";
    meta.description = "Typerep is a library for runtime types";
    propagatedBuildInputs = [ base ];
  }).overrideAttrs (o: {
    src =
      if isFlambda2
      then
        fetchFromGitHub
          {
            owner = "janestreet";
            repo = "typerep";
            rev = "c0ddd1226871d97a17ac4962d6f1f963bcc5d882";
            hash = "sha256-TxNK4j1O9ddv9prt+2cMm1kRQCyxEDMakruODOU1650=";
          }
      else o.src;
  });

  uopt = (janePackage {
    pname = "uopt";
    hash = "sha256-t0SFJVF0ScyFFwziBZOYCOsmhRd6J5H3s0Kk9NKorcM=";
    meta.description = ''
      Uopt_base provides an unboxed option type, for use in high-performance
      systems which avoid allocation. It has several downsides as compared to
      [option], and is not recommended for use in general-purpose software.
    '';
    propagatedBuildInputs = [ base ppx_jane ];
  }).overrideAttrs (o: {
    src =
      if isFlambda2
      then
        fetchFromGitHub
          {
            owner = "janestreet";
            repo = "uopt";
            rev = "27606a53f72d85159fff6b9d4277ab8778a5f1cd";
            hash = "sha256-6X4NBQ+OF6Fh74y9cmIN10iF/FXP3vp+D5ozAO8ml14=";
          }
      else o.src;
  });

  username_kernel = janePackage {
    pname = "username_kernel";
    hash = "sha256-1lxWSv7CbmucurNw8ws18N9DYqo4ik2KZBc5GtNmmeU=";
    minimalOCamlVersion = "4.14";
    meta.description = "An identifier for a user";
    propagatedBuildInputs = [ core ppx_jane ];
  };

  variantslib = janePackage {
    pname = "variantslib";
    hash = "sha256-v/p718POQlFsB7N7WmMCDnmQDB2sP1263pSQIuvlLt8=";
    minimalOCamlVersion = "4.04.2";
    meta.description = "Part of Jane Street's Core library";
    propagatedBuildInputs = [ base ];
  };

  vcaml = janePackage {
    pname = "vcaml";
    hash = "sha256-z3v0Uqb+jE19+EN/b6qQvAx+FaK5HmbdHnxEkYGSmS8=";
    meta.description = "OCaml bindings for the Neovim API";
    propagatedBuildInputs = [
      async
      base_trie
      core
      core_kernel
      core_unix
      expect_test_helpers_async
      jsonaf
      man_in_the_middle_debugger
      ppx_jane
      ppx_optcomp
      semantic_version
      textutils
      angstrom-async
      faraday
    ];
    doCheck = false;
  };

  versioned_polling_state_rpc = janePackage {
    pname = "versioned_polling_state_rpc";
    hash = "sha256-Ba+Pevc/cvvY9FnQ2oTUxTekxypVkEy4MfrpRKmJhZ0=";
    meta.description = "Helper functions for creating stable/versioned `Polling_state_rpc.t`s with babel.";
    propagatedBuildInputs = [
      async_rpc_kernel
      babel
      core
      polling_state_rpc
      ppx_jane
    ];
  };

  virtual_dom = janePackage {
    pname = "virtual_dom";
    hash = "sha256-5T+/N1fELa1cR9mhWLUgS3Fwr1OQXJ3J6T3YaHT9q7U=";
    meta.description = "OCaml bindings for the virtual-dom library";
    buildInputs = [ js_of_ocaml-ppx ];
    postPatch =
      if lib.versionAtLeast ocaml.version "5.2" then ''
        substituteInPlace ui_effect/ui_effect_intf.ml src/global_listeners.ml \
        --replace-fail "effect " "\#effect " \
        --replace-fail " effect" " \#effect"
      '' else "";
    propagatedBuildInputs = [
      base64
      core_kernel
      gen_js_api
      js_of_ocaml
      js_of_ocaml_patches
      lambdasoup
      tyxml
      uri
    ];
  };

  virtual_dom_toplayer = janePackage {
    pname = "virtual_dom_toplayer";
    hash = "sha256-trTSWzWsXkV4RtQvVCyXqJN5/wftaFuooaehNekP9H0=";
    meta.description = ''
      OCaml bindings for the floating positioning library for 'toplevel'
      virtual dom components
    '';
    propagatedBuildInputs = [
      core
      js_of_ocaml_patches
      ppx_css
      ppx_jane
      virtual_dom
      gen_js_api
      js_of_ocaml
      js_of_ocaml-ppx
    ];
  };

  zarith_stubs_js = janePackage {
    pname = "zarith_stubs_js";
    hash = "sha256-QNhs9rHZetwgKAOftgQQa6aU8cOux8JOe3dBRrLJVh0=";
    meta.description = "Javascripts stubs for the Zarith library";
    doCheck = false;
  };

  zstandard = janePackage {
    pname = "zstandard";
    hash = "sha256-EUI7fnN8ZaM1l0RBsgSAMWO+VXA8VoCv/lO5kcj+j4E=";
    meta.description = "OCaml bindings to Zstandard";
    buildInputs = [ ppx_jane ];
    propagatedBuildInputs = [ core_kernel ctypes zstd ];
  };

}
