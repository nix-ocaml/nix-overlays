{ fetchFromGitHub, stdenv, osuper, oself }:

with oself;

{
  async = osuper.janeStreet.async.overrideAttrs (o: {
    src = fetchFromGitHub {
      owner = "janestreet";
      repo = "async";
      rev = "v0.13.0";
      sha256 = "002j9yxpw0ghi12a84163vaqa3n9h8j35f4i72nbxnilxwvy95sr";
    };
    propagatedBuildInputs = [ async_extra textutils ];
  });

  async_extra = osuper.janeStreet.async_extra.overrideAttrs (o: {
    src = fetchFromGitHub {
      owner = "janestreet";
      repo = "async_extra";
      rev = "v0.13.0";
      sha256 = "06q1farx7dwi4h490xi1azq7ym57ih2d23sq17g2jfvw889kf4n1";
    };
    propagatedBuildInputs = [ async_rpc_kernel async_unix ];
  });

  async_kernel = osuper.janeStreet.async_kernel.overrideAttrs (o: {
    src = fetchFromGitHub {
      owner = "janestreet";
      repo = "async_kernel";
      rev = "c1c186654cc3fe288c7ee83abb307b4eede48674";
      sha256 = "1zv5lqhifr6aylpgidic75z9f7g9rkxq5y6ay59jrhj70s6n8g6a";
    };
    propagatedBuildInputs = [ core_kernel ];
  });

  async_rpc_kernel = osuper.janeStreet.async_rpc_kernel.overrideAttrs (o: {
    src = fetchFromGitHub {
      owner = "janestreet";
      repo = "async_rpc_kernel";
      rev = "v0.13.0";
      sha256 = "1k3f2psyd1xcf7nkk0q1fq57yyhfqbzyynsz821n7mrnm37simac";
    };
    propagatedBuildInputs = [ async_kernel protocol_version_header ];
  });


  async_unix = osuper.janeStreet.async_unix.overrideAttrs (o: {
    src = fetchFromGitHub {
      owner = "janestreet";
      repo = "async_unix";
      rev = "v0.13.0";
      sha256 = "0n3jz3qjlphyhkqgnbjbwf2fqxaksws82dx1mk4m4wnw3275gdi5";
    };
    propagatedBuildInputs = [ async_kernel core ];
  });

  base = osuper.janeStreet.base.overrideAttrs (o: {
    src = fetchFromGitHub {
      owner = "janestreet";
      repo = "base";
      rev = "v0.13.0";
      sha256 = "16j59blmsp1pbmlqagd1zz8b9nkxb83ixnwg2a0nl7ycmb2ifb74";
    };
  });

  base_bigstring = osuper.janeStreet.base_bigstring.overrideAttrs (o: {
    src = fetchFromGitHub {
      owner = "janestreet";
      repo = "base_bigstring";
      rev = "v0.13.0";
      sha256 = "1i3zr8bn71l442vl5rrvjpwphx20frp2vaw1qc05d348j76sxfp7";
    };
    propagatedBuildInputs = [ ppx_jane ];
  });

  base_quickcheck = osuper.janeStreet.base_quickcheck.overrideAttrs (o: {
    src = fetchFromGitHub {
      owner = "janestreet";
      repo = "base_quickcheck";
      rev = "v0.13.0";
      sha256 = "0ik8llm01m2xap4gia0vpsh7yq311hph7a2kf5109ag4988s8p0w";
    };
    propagatedBuildInputs = [ ppx_base ppx_fields_conv ppx_let splittable_random ];
  });

  bin_prot = osuper.janeStreet.bin_prot.overrideAttrs (o: {
    src = fetchFromGitHub {
      owner = "janestreet";
      repo = "bin_prot";
      rev = "v0.13.0";
      sha256 = "1nnr21rljlfglmhiji27d7c1d6gg5fk4cc5rl3750m98w28mfdjw";
    };
    propagatedBuildInputs = [ ppx_compare ppx_custom_printf ppx_fields_conv ppx_variants_conv ];
  });

  core = osuper.janeStreet.core.overrideAttrs (o: {
    src = fetchFromGitHub {
      owner = "janestreet";
      repo = "core";
      rev = "v0.13.0";
      sha256 = "1i5z9myl6i7axd8dz4b71gdsz9la6k07ib9njr4bn12yn0y76b1m";
    };
    buildInputs = [ ocaml dune findlib jst-config ];
    propagatedBuildInputs = [ core_kernel spawn ];
  });

  core_kernel = osuper.janeStreet.core_kernel.overrideAttrs (o: {
    src = fetchFromGitHub {
      owner = "janestreet";
      repo = "core_kernel";
      rev = "v0.13.0";
      sha256 = "0plvzixfxkhxh8mc6hhsjadfy5cn8p5nff50vxiqd562w7jypazi";
    };
    buildInputs = [  ocaml dune findlib jst-config ];
    propagatedBuildInputs = [ base_bigstring sexplib ];
  });

  fieldslib = osuper.janeStreet.fieldslib.overrideAttrs (o: {
    src = fetchFromGitHub {
      owner = "janestreet";
      repo = "fieldslib";
      rev = "v0.13.0";
      sha256 = "0nsl0i9vjk73pr70ksxqa65rd5v84jzdaazryfdy6i4a5sfg7bxa";
    };
    propagatedBuildInputs = [ base ];
  });

  jane-street-headers = osuper.janeStreet.jane-street-headers.overrideAttrs (o: {
    src = fetchFromGitHub {
      owner = "janestreet";
      repo = "jane-street-headers";
      rev = "v0.13.0";
      sha256 = "1qjg2ari0xn40dlbk0h9xkwr37k97ldkxpkv792fbl6wc2jlv3x5";
    };
  });

  jst-config =  janePackage {
    pname = "jst-config";
    hash = "15lj6f83hz555xhjy9aayl3adqwgl1blcjnja693a1ybi3ca8w0y";
    meta.description = "Compile-time configuration for Jane Street libraries";
    buildInputs = [ ppx_assert ];
  };

  parsexp = osuper.janeStreet.parsexp.overrideAttrs (o: {
    src = fetchFromGitHub {
      owner = "janestreet";
      repo = "parsexp";
      rev = "v0.13.0";
      sha256 = "0fsxy5lpsvfadj8m2337j8iprs294dfikqxjcas7si74nskx6l38";
    };
    propagatedBuildInputs = [ base sexplib0 ];
  });

  ppx_assert = osuper.janeStreet.ppx_assert.overrideAttrs (o: {
    src = fetchFromGitHub {
      owner = "janestreet";
      repo = "ppx_assert";
      rev = "v0.13.0";
      sha256 = "08dada2xcp3w5mir90z56qrdyd317lygml4qlfssj897534bwiqr";
    };
    propagatedBuildInputs = [ ppx_cold ppx_compare ppx_here ppx_sexp_conv ];
  });

  ppx_cold = janePackage {
    pname = "ppx_cold";
    version = "0.13.0";
    hash = "0wnfwsgbzk4i5aqjlcaqp6lkvrq5345vazryvx2klbbrd4759h9f";
    propagatedBuildInputs = [ ppxlib ];
  };

  ppx_base = osuper.janeStreet.ppx_base.overrideAttrs (o: {
    src = fetchFromGitHub {
      owner = "janestreet";
      repo = "ppx_base";
      rev = "v0.13.0";
      sha256 = "0dkqc85x7bgbb6lgx9rghvj1q4dpdgy9qgjl88ywi4c8l9rgnnkz";
    };
    propagatedBuildInputs = [ ppx_cold ppx_enumerate ppx_hash ppx_js_style ];
  });

  ppx_bench = osuper.janeStreet.ppx_bench.overrideAttrs (o: {
    src = fetchFromGitHub {
      owner = "janestreet";
      repo = "ppx_bench";
      rev = "v0.13.0";
      sha256 = "0snmy05d3jgihmppixx3dzamkykijqa2v43vpd7q4z8dpnip620g";
    };
    propagatedBuildInputs = [ ppx_inline_test ];
  });

  ppx_bin_prot = osuper.janeStreet.ppx_bin_prot.overrideAttrs (o: {
    src = fetchFromGitHub {
      owner = "janestreet";
      repo = "ppx_bin_prot";
      rev = "v0.13.0";
      sha256 = "14nfjgqisdqqg8wg4qzvc859zil82y0qpr8fm4nhq05mgxp37iyc";
    };
    propagatedBuildInputs = [ bin_prot ppx_here ];
  });

  ppx_compare = osuper.janeStreet.ppx_compare.overrideAttrs (o: {
    src = fetchFromGitHub {
      owner = "janestreet";
      repo = "ppx_compare";
      rev = "v0.13.0";
      sha256 = "14pnqa47gsvq93z1b8wb5pyq8zw90aaw71j4pwlyid4s86px454j";
    };
    propagatedBuildInputs = [ ppxlib ];
  });

  ppx_custom_printf = osuper.janeStreet.ppx_custom_printf.overrideAttrs (o: {
    src = fetchFromGitHub {
      owner = "janestreet";
      repo = "ppx_custom_printf";
      rev = "v0.13.0";
      sha256 = "0kvfkdk4wg2z8x705bajvl1f8wiyy3aya203wdzc9425h73nqm5p";
    };
    propagatedBuildInputs = [ ppx_sexp_conv ];
  });

  ppx_enumerate = osuper.janeStreet.ppx_enumerate.overrideAttrs (o: {
    src = fetchFromGitHub {
      owner = "janestreet";
      repo = "ppx_enumerate";
      rev = "v0.13.0";
      sha256 = "0hsg6f2nra1mb35jdgym5rf7spm642bs6qqifbikm9hg8f7z3ql4";
    };
    propagatedBuildInputs = [ ppxlib ];
  });

  ppx_expect = osuper.janeStreet.ppx_expect.overrideAttrs (o: {
    src = fetchFromGitHub {
      owner = "janestreet";
      repo = "ppx_expect";
      rev = "v0.13.0";
      sha256 = "1hhcga960wjvhcx5pk7rcywl1p9n2ycvqa294n24m8dhzqia6i47";
    };
    propagatedBuildInputs = [ ppx_assert ppx_custom_printf ppx_fields_conv ppx_inline_test ppx_variants_conv re ];
  });

  ppx_fail = osuper.janeStreet.ppx_fail.overrideAttrs (o: {
    src = fetchFromGitHub {
      owner = "janestreet";
      repo = "ppx_fail";
      rev = "v0.13.0";
      sha256 = "165mikjg4a1lahq3n9q9y2h36jbln5g3l2hapx17irvf0l0c3vn5";
    };
    propagatedBuildInputs = [ ppx_here ];
  });

  ppx_fields_conv = osuper.janeStreet.ppx_fields_conv.overrideAttrs (o: {
    src = fetchFromGitHub {
      owner = "janestreet";
      repo = "ppx_fields_conv";
      rev = "v0.13.0";
      sha256 = "0biw0fgphj522bj9wgjk263i2w92vnpaabzr5zn0grihp4yqy8w4";
    };
    propagatedBuildInputs = [ fieldslib ppxlib ];
  });

  ppx_hash = osuper.janeStreet.ppx_hash.overrideAttrs (o: {
    src = fetchFromGitHub {
      owner = "janestreet";
      repo = "ppx_hash";
      rev = "v0.13.0";
      sha256 = "1f7mfyx4wgk67hchi57w3142m61ka3vgy1969cbkwr3akv6ifly2";
    };
    propagatedBuildInputs = [ ppx_compare ppx_sexp_conv ];
  });

  ppx_here = osuper.janeStreet.ppx_here.overrideAttrs (o: {
    src = fetchFromGitHub {
      owner = "janestreet";
      repo = "ppx_here";
      rev = "v0.13.0";
      sha256 = "1ahidrrjsyi0al06bhv5h6aqmdk7ryz8dybfhqjsn1zp9q056q35";
    };
    propagatedBuildInputs = [ ppxlib ];
  });

  ppx_inline_test = osuper.janeStreet.ppx_inline_test.overrideAttrs (o: {
    src = fetchFromGitHub {
      owner = "janestreet";
      repo = "ppx_inline_test";
      rev = "v0.13.0";
      sha256 = "135qzbhqy33lmigbq1rakr9i3y59y3pczh4laanqjyss9b9kfs60";
    };
    propagatedBuildInputs = [ ppxlib ];
  });

  ppx_jane = osuper.janeStreet.ppx_jane.overrideAttrs (o: {
    src = fetchFromGitHub {
      owner = "janestreet";
      repo = "ppx_jane";
      rev = "v0.13.0";
      sha256 = "1a86rvnry8lvjhsg2k73f5bgz7l2962k5i49yzmzn8w66kj0yz60";
    };
    propagatedBuildInputs = [ base_quickcheck ppx_bench ppx_bin_prot ppx_expect ppx_fail ppx_module_timer ppx_optcomp ppx_optional ppx_pipebang ppx_sexp_value ppx_stable ppx_typerep_conv ];
  });

  ppx_js_style = osuper.janeStreet.ppx_js_style.overrideAttrs (o: {
    src = fetchFromGitHub {
      owner = "janestreet";
      repo = "ppx_js_style";
      rev = "v0.13.0";
      sha256 = "1zlhcn0an5k9xjymk5z5m2vqi8zajy6nvcbl5sdn19pjl3zv645x";
    };
    propagatedBuildInputs = [ octavius ppxlib ];
  });

  ppx_let = osuper.janeStreet.ppx_let.overrideAttrs (o: {
    src = fetchFromGitHub {
      owner = "janestreet";
      repo = "ppx_let";
      rev = "v0.13.0";
      sha256 = "0qplsvbv10h7kwf6dhhgvi001gfphv1v66s83zjr5zbypyaarg5y";
    };
    propagatedBuildInputs = [ ppxlib ];
  });

  ppx_module_timer = osuper.janeStreet.ppx_module_timer.overrideAttrs (o: {
    src = fetchFromGitHub {
      owner = "janestreet";
      repo = "ppx_module_timer";
      rev = "v0.13.0";
      sha256 = "13kv5fzwf41wsaksj41hnvcpx8pnbmzcainlq6f5shj9671hpnhb";
    };
    propagatedBuildInputs = [ time_now ];
  });

  ppx_optcomp = osuper.janeStreet.ppx_optcomp.overrideAttrs (o: {
    version = "0.13.0";
    src = fetchFromGitHub {
      owner = "janestreet";
      repo = "ppx_optcomp";
      rev = "v0.13.0";
      sha256 = "13db395swqf7v87pgl9qiyj4igmvj57hpl8blx3kkrzj6ddh38a8";
    };
    propagatedBuildInputs = [ ppxlib ];
  });

  ppx_optional = osuper.janeStreet.ppx_optional.overrideAttrs (o: {
    src = fetchFromGitHub {
      owner = "janestreet";
      repo = "ppx_optional";
      rev = "v0.13.0";
      sha256 = "1nwb9jvmszxddj9wxgv9g02qhr10yymm2q1w1gjfqd97m2m1mx4n";
    };
    propagatedBuildInputs = [ ppxlib ];
  });

  ppx_pipebang = osuper.janeStreet.ppx_pipebang.overrideAttrs (o: {
    src = fetchFromGitHub {
      owner = "janestreet";
      repo = "ppx_pipebang";
      rev = "v0.13.0";
      sha256 = "0ybj0flsi95pf13ayzz1lcrqhqvkv1lm2dz6y8w49f12583496mc";
    };
    propagatedBuildInputs = [ ppxlib ];
  });

  ppx_sexp_conv = osuper.janeStreet.ppx_sexp_conv.overrideAttrs (o: {
    src = fetchFromGitHub {
      owner = "janestreet";
      repo = "ppx_sexp_conv";
      rev = "v0.13.0";
      sha256 = "0jkhwmkrfq3ss6bv6i3m871alcr4xpngs6ci6bmzv3yfl7s8bwdf";
    };
    propagatedBuildInputs = [ ppxlib ];
  });

  ppx_sexp_message = osuper.janeStreet.ppx_sexp_message.overrideAttrs (o: {
    src = fetchFromGitHub {
      owner = "janestreet";
      repo = "ppx_sexp_message";
      rev = "v0.13.0";
      sha256 = "03jhx3ajcv22iwxkg1jf1jjvd14gyrwi1yc6c5ryqi5ha0fywfw6";
    };
    propagatedBuildInputs = [ ppx_here ppx_sexp_conv ];
  });

  ppx_sexp_value = osuper.janeStreet.ppx_sexp_value.overrideAttrs (o: {
    src = fetchFromGitHub {
      owner = "janestreet";
      repo = "ppx_sexp_value";
      rev = "v0.13.0";
      sha256 = "18k5015awv9yjl44cvdmp3pn894cgsxmn5s7picxapm9675xqcg9";
    };
    propagatedBuildInputs = [ ppx_here ppx_sexp_conv ];
  });

  ppx_stable = osuper.janeStreet.ppx_stable.overrideAttrs (o: {
    src = fetchFromGitHub {
      owner = "janestreet";
      repo = "ppx_stable";
      rev = "v0.13.0";
      sha256 = "0h7ls1bs0bsd8c4na4aj0nawwhvfy50ybm7sza7yz3qli9jammjk";
    };
    propagatedBuildInputs = [ ppxlib ];
  });

  ppx_typerep_conv = osuper.janeStreet.ppx_typerep_conv.overrideAttrs (o: {
    src = fetchFromGitHub {
      owner = "janestreet";
      repo = "ppx_typerep_conv";
      rev = "v0.13.0";
      sha256 = "1jlmga9i79inr412l19n4vvmgafzp1bznqxwhy42x309wblbhxx9";
    };
    propagatedBuildInputs = [ ppxlib typerep ];
  });

  ppx_variants_conv = osuper.janeStreet.ppx_variants_conv.overrideAttrs (o: {
    src = fetchFromGitHub {
      owner = "janestreet";
      repo = "ppx_variants_conv";
      rev = "v0.13.0";
      sha256 = "1ssinizz11bws06qzjky486cj1zrflij1f7hi16d02j40qmyjz7b";
    };
    propagatedBuildInputs = [ variantslib ppxlib ];
  });

  protocol_version_header = osuper.janeStreet.protocol_version_header.overrideAttrs (o: {
    src = fetchFromGitHub {
      owner = "janestreet";
      repo = "protocol_version_header";
      rev = "v0.13.0";
      sha256 = "19wscd81jlj355f9din1sg21m3af456a0id2a37bx38r390wrghc";
    };
    propagatedBuildInputs = [ core_kernel ];
  });

  spawn = osuper.janeStreet.spawn.overrideAttrs (o: {
    src = fetchFromGitHub {
      owner = "janestreet";
      repo = "spawn";
      rev = "v0.13.0";
      sha256 = "1w003k1kw1lmyiqlk58gkxx8rac7dchiqlz6ah7aj7bh49b36ppf";
    };
    buildInputs = [ ocaml dune findlib ppx_expect ];
  });

  splittable_random = osuper.janeStreet.splittable_random.overrideAttrs (o: {
    src = fetchFromGitHub {
      owner = "janestreet";
      repo = "splittable_random";
      rev = "v0.13.0";
      sha256 = "1kgcd6k31vsd7638g8ip77bp1b7vzgkbvgvij4jm2igl09132r85";
    };
    propagatedBuildInputs = [ base ppx_assert ppx_bench ppx_sexp_message ];
  });

  stdio = osuper.janeStreet.stdio.overrideAttrs (o: {
    src = fetchFromGitHub {
      owner = "janestreet";
      repo = "stdio";
      rev = "v0.13.0";
      sha256 = "1hkj9vh8n8p3n5pvx7053xis1pfmqd8p7shjyp1n555xzimfxzgh";
    };
    propagatedBuildInputs = [ base ];
  });

  textutils = osuper.janeStreet.textutils.overrideAttrs (o: {
    src = fetchFromGitHub {
      owner = "janestreet";
      repo = "textutils";
      rev = "v0.13.0";
      sha256 = "1wnyqj9dzfgl0kddmdl4n9rkl16hwy432dd2i4ksvk2z5g9kkb0d";
    };
    propagatedBuildInputs = [ core ];
  });

  time_now = janePackage {
    pname = "time_now";
    hash = "1if234kz1ssmv22c0vh1cwhbivab6yy3xvy37ny1q4k5ibjc3v0n";
    buildInputs = [ jst-config ppx_optcomp ];
    propagatedBuildInputs = [ jane-street-headers base ppx_base ];
  };

  typerep = osuper.janeStreet.typerep.overrideAttrs (o: {
    src = fetchFromGitHub {
      owner = "janestreet";
      repo = "typerep";
      rev = "v0.13.0";
      sha256 = "116hlifww2cqq1i9vwpl7ziwkc1na7p9icqi9srpdxnvn8ibcsas";
    };
    propagatedBuildInputs = [ base ];
  });

  variantslib = osuper.janeStreet.variantslib.overrideAttrs (o: {
    src = fetchFromGitHub {
      owner = "janestreet";
      repo = "variantslib";
      rev = "v0.13.0";
      sha256 = "04nps65v1n0nv9n1c1kj5k9jyqsfsxb6h2w3vf6cibhjr5m7z8xc";
    };
    propagatedBuildInputs = [ base ];
  });
}


