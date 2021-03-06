open Format

let generate dirname =
  let prefix = "bap" in
  let path basename = Filename.concat dirname basename in
  let ml_fd = open_out (path "bap_bindings.ml") in
  let c_fd = open_out (path "bap.c") in
  let h_fd = open_out (path "bap.h") in
  let stubs = (module Bindings.Make : Cstubs_inverted.BINDINGS) in
  begin
    Cstubs_inverted.write_ml
      (formatter_of_out_channel ml_fd) ~prefix stubs;

    fprintf (formatter_of_out_channel c_fd)
      "#include \"bap.h\"@\n%a"
      (Cstubs_inverted.write_c ~prefix) stubs;

    fprintf (formatter_of_out_channel h_fd)
      "#include <stdint.h>
       #include <stdlib.h>

      void bap_init(int argc, const char *argv[]);
%a"
    (Cstubs_inverted.write_c_header ~prefix) stubs;

  end;
  close_out h_fd;
  close_out c_fd;
  close_out ml_fd

let () = generate (Sys.argv.(1))
