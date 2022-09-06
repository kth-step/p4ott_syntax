open HolKernel boolLib Parse bossLib;

open p4Theory p4_coreTheory p4_vssTheory;

val _ = new_theory "p4_vss_example";

Definition p4_vss_example_pblock_map_def:
  p4_vss_example_pblock_map =
    [("parser",
       pblock_regular pbl_type_parser [("b",d_none); ("p",d_out)] []
         [(varn_name "ck",tau_ext)]
         (stmt_seq
            (stmt_ass lval_null
               (e_call (funn_inst "Checksum16") [e_var (varn_name "ck")]))
            (stmt_trans (e_v (v_str "start"))))
         [("start",
           stmt_block []
             (stmt_seq
                (stmt_ass lval_null
                   (e_call (funn_ext "packet_in" "extract")
                      [e_var (varn_name "b");
                       e_acc (e_var (varn_name "p")) "ethernet"]))
                (stmt_trans
                   (e_select
                      (e_acc (e_acc (e_var (varn_name "p")) "ethernet")
                         "etherType") [(v_bit (w16 2048w),"parse_ipv4")]
                      "reject"))));
          ("parse_ipv4",
           stmt_block []
             (stmt_seq
                (stmt_ass lval_null
                   (e_call (funn_ext "packet_in" "extract")
                      [e_var (varn_name "b");
                       e_acc (e_var (varn_name "p")) "ip"]))
                (stmt_seq
                   (stmt_verify
                      (e_binop
                         (e_acc (e_acc (e_var (varn_name "p")) "ip")
                            "version") binop_eq (e_v (v_bit (w4 4w))))
                      (e_v (v_err "IPv4IncorrectVersion")))
                   (stmt_seq
                      (stmt_verify
                         (e_binop
                            (e_acc (e_acc (e_var (varn_name "p")) "ip") "ihl")
                            binop_eq (e_v (v_bit (w4 5w))))
                         (e_v (v_err "IPv4OptionsNotSupported")))
                      (stmt_seq
                         (stmt_ass lval_null
                            (e_call (funn_ext "Checksum16" "clear")
                               [e_var (varn_name "ck")]))
                         (stmt_seq
                            (stmt_ass lval_null
                               (e_call (funn_ext "Checksum16" "update")
                                  [e_var (varn_name "ck");
                                   e_acc (e_var (varn_name "p")) "ip"]))
                            (stmt_seq
                               (stmt_verify
                                  (e_binop
                                     (e_call (funn_ext "Checksum16" "get")
                                        [e_var (varn_name "ck")]) binop_eq
                                     (e_v (v_bit (w16 0w))))
                                  (e_v (v_err "IPv4ChecksumError")))
                               (stmt_trans (e_v (v_str "accept"))))))))))] []);
      ("pipe",
       pblock_regular pbl_type_control
         [("headers",d_inout); ("parseError",d_in); ("inCtrl",d_in);
          ("outCtrl",d_out)]
         [("Drop_action",
           stmt_seq
             (stmt_ass
                (lval_field (lval_varname (varn_name "outCtrl")) "outputPort")
                (e_var (varn_name "DROP_PORT"))) (stmt_ret (e_v v_bot)),[]);
          ("Set_nhop",
           stmt_seq
             (stmt_ass (lval_varname (varn_name "nextHop"))
                (e_var (varn_name "ipv4_dest")))
             (stmt_seq
                (stmt_ass
                   (lval_field
                      (lval_field (lval_varname (varn_name "headers")) "ip")
                      "ttl")
                   (e_binop
                      (e_acc (e_acc (e_var (varn_name "headers")) "ip") "ttl")
                      binop_sub (e_v (v_bit (w8 1w)))))
                (stmt_seq
                   (stmt_ass
                      (lval_field (lval_varname (varn_name "outCtrl"))
                         "outputPort") (e_var (varn_name "port")))
                   (stmt_ret (e_v v_bot)))),
           [("ipv4_dest",d_none); ("port",d_none)]);
          ("Send_to_cpu",
           stmt_seq
             (stmt_ass
                (lval_field (lval_varname (varn_name "outCtrl")) "outputPort")
                (e_var (varn_name "CPU_OUT_PORT"))) (stmt_ret (e_v v_bot)),[]);
          ("Set_dmac",
           stmt_seq
             (stmt_ass
                (lval_field
                   (lval_field (lval_varname (varn_name "headers"))
                      "ethernet") "dstAddr") (e_var (varn_name "dmac")))
             (stmt_ret (e_v v_bot)),[("dmac",d_none)]);
          ("Set_smac",
           stmt_seq
             (stmt_ass
                (lval_field
                   (lval_field (lval_varname (varn_name "headers"))
                      "ethernet") "srcAddr") (e_var (varn_name "smac")))
             (stmt_ret (e_v v_bot)),[("smac",d_none)])]
         [(varn_name "nextHop",tau_bit 32)]
         (stmt_block []
            (stmt_seq
               (stmt_cond
                  (e_binop (e_var (varn_name "parseError")) binop_neq
                     (e_v (v_err "NoError")))
                  (stmt_seq
                     (stmt_ass lval_null
                        (e_call (funn_name "Drop_action") []))
                     (stmt_ret (e_v v_bot))) stmt_empty)
               (stmt_seq
                  (stmt_seq
                     (stmt_app "ipv4_match"
                        [e_acc (e_acc (e_var (varn_name "headers")) "ip")
                           "dstAddr"])
                     (stmt_cond
                        (e_binop
                           (e_acc (e_var (varn_name "outCtrl")) "outputPort")
                           binop_eq (e_var (varn_name "DROP_PORT")))
                        (stmt_ret (e_v v_bot)) stmt_empty))
                  (stmt_seq
                     (stmt_seq
                        (stmt_app "check_ttl"
                           [e_acc (e_acc (e_var (varn_name "headers")) "ip")
                              "ttl"])
                        (stmt_cond
                           (e_binop
                              (e_acc (e_var (varn_name "outCtrl"))
                                 "outputPort") binop_eq
                              (e_var (varn_name "CPU_OUT_PORT")))
                           (stmt_ret (e_v v_bot)) stmt_empty))
                     (stmt_seq
                        (stmt_seq
                           (stmt_app "dmac" [e_var (varn_name "nextHop")])
                           (stmt_cond
                              (e_binop
                                 (e_acc (e_var (varn_name "outCtrl"))
                                    "outputPort") binop_eq
                                 (e_var (varn_name "CPU_OUT_PORT")))
                              (stmt_ret (e_v v_bot)) stmt_empty))
                        (stmt_app "smac"
                           [e_acc (e_var (varn_name "outCtrl")) "outputPort"]))))))
         []
         [("ipv4_match",[mk_lpm]); ("check_ttl",[mk_exact]);
          ("dmac",[mk_exact]); ("smac",[mk_exact])]);
      ("deparser",
       pblock_regular pbl_type_control [("p",d_inout); ("b",d_none)] []
         [(varn_name "ck",tau_ext)]
         (stmt_block []
            (stmt_seq
               (stmt_ass lval_null
                  (e_call (funn_inst "Checksum16") [e_var (varn_name "ck")]))
               (stmt_seq
                  (stmt_ass lval_null
                     (e_call (funn_ext "packet_out" "emit")
                        [e_var (varn_name "b");
                         e_acc (e_var (varn_name "p")) "ethernet"]))
                  (stmt_seq
                     (stmt_cond
                        (e_call (funn_ext "header" "isValid")
                           [e_acc (e_var (varn_name "p")) "ip"])
                        (stmt_seq
                           (stmt_ass lval_null
                              (e_call (funn_ext "Checksum16" "clear")
                                 [e_var (varn_name "ck")]))
                           (stmt_seq
                              (stmt_ass
                                 (lval_field
                                    (lval_field
                                       (lval_varname (varn_name "p")) "ip")
                                    "hdrChecksum") (e_v (v_bit (w16 0w))))
                              (stmt_seq
                                 (stmt_ass lval_null
                                    (e_call (funn_ext "Checksum16" "update")
                                       [e_var (varn_name "ck");
                                        e_acc (e_var (varn_name "p")) "ip"]))
                                 (stmt_ass
                                    (lval_field
                                       (lval_field
                                          (lval_varname (varn_name "p")) "ip")
                                       "hdrChecksum")
                                    (e_call (funn_ext "Checksum16" "get")
                                       [e_var (varn_name "ck")])))))
                        stmt_empty)
                     (stmt_ass lval_null
                        (e_call (funn_ext "packet_out" "emit")
                           [e_var (varn_name "b");
                            e_acc (e_var (varn_name "p")) "ip"])))))) [] [])]:pblock_map
End

Definition p4_vss_example_ext_map_def:
  p4_vss_example_ext_map =
    [("header",NONE,
       [("isValid",stmt_seq stmt_ext (stmt_ret (e_var varn_ext_ret)),
         [("this",d_in)],header_is_valid)]);
      ("packet_in",NONE,
       [("extract",stmt_seq stmt_ext (stmt_ret (e_v v_bot)),
         [("this",d_in); ("hdr",d_out)],packet_in_extract)]);
      ("packet_out",NONE,
       [("emit",stmt_seq stmt_ext (stmt_ret (e_v v_bot)),
         [("this",d_in); ("data",d_in)],packet_out_emit)])] ++
     [("Checksum16",
       SOME
         (stmt_seq stmt_ext (stmt_ret (e_v v_bot)),[("this",d_out)],
          Checksum16_construct),
       [("clear",stmt_seq stmt_ext (stmt_ret (e_v v_bot)),[("this",d_in)],
         Checksum16_clear);
        ("update",stmt_seq stmt_ext (stmt_ret (e_v v_bot)),
         [("this",d_in); ("data",d_in)],Checksum16_update);
        ("get",stmt_seq stmt_ext (stmt_ret (e_var varn_ext_ret)),
         [("this",d_in)],Checksum16_get)])]:vss_ascope ext_map
End

Definition p4_vss_example_func_map_def:
  p4_vss_example_func_map = [("NoAction",stmt_ret (e_v v_bot),[])]:func_map
End

val _ = export_theory ();
