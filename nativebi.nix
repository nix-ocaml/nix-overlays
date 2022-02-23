let pkgs = import ./boot.nix { };
in
with pkgs.pkgsCross.aarch64-multiplatform.ocaml-ng.ocamlPackages_4_13;
[
  apron
  astring
  atd
  bap
  batteries
  benchmark
  bigarray-overlap
  biniou
  biniou
  bitv
  bos
  bz2
  calendar
  camlpdf
  camlzip
  camomile
  camomile
  carton
  coin
  cpdf
  csv
  ctypes
  digestif
  dolog
  dum
  elina
  eliom
  erm_xml
  ocaml_expat
  ocaml_extlib
  farfadet
  fmt
  fontconfig
  fpath
  frontc
  functory
  getopt
  gg
  gmetadom
  hacl-star
  hmap
  inifiles
  inotify
  iso8601
  javalib
  jsonm
  lablgl
  lablgtk
  llvm
  logs
  lua-ml
  mirage-crypto
  mirage-crypto-ec
  mirage-crypto-pk
  mirage-crypto-rng-async
  mirage-crypto-rng-mirage
  mirage-crypto-rng
  mlgmpidl
  mtime
  ocaml_mysql
  nocrypto
  notty
  num
  ocaml_libvirt
  ocamlnet
  ocb-stubblr
  ocp-ocamlres
  ocplib-simplex
  ocsigen-start
  ocsigen-toolkit
  ocurl
  omd
  otfm
  ounit
  piqi-ocaml
  piqi
  ppx_cstubs
  ppx_tools
  ptime
  pycaml
  pyml
  react
  reactivedata
  rope
  rresult
  sawja
  sedlex
  sodium
  sosa
  stdcompat
  torch
  tsdl
  twt
  uchar
  uucd
  uucp
  uunf
  uuseg
  uutf
  uuuu
  vg
  webbrowser
  xml-light
  xmlm
  z3
]

# bolt
# cil
# config-file
# ocaml_cryptgps
# dypgen
# enumerate
# erm_xmpp
# lablgtk-extras
# labltk
# macaque
# magick
# mlgmp
# ocaml_cairo
# ocamlnat
# ocamlsdl
# ocsigen_deriving
# ocaml_data_notation
# sqlite3EZ
# ulex
