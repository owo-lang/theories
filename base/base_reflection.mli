open Basic_tactics

declare bterm
declare sequent_arg{'t}
declare term

declare if_bterm{'t; 'tt}
declare subterms{'bt}
declare make_bterm{'bt; 'bt1}
declare if_same_op{'bt1; 'bt2; 'tt; 'ff}
declare if_simple_bterm{'bt; 'tt; 'ff}
declare if_var_bterm{'bt; 'tt; 'ff}
declare subst{'bt; 't}

topval reduce_ifbterm : conv
topval reduce_if_var_bterm : conv
topval reduce_subterms : conv
topval reduce_make_bterm : conv
topval reduce_if_same_op : conv
topval reduce_if_simple_bterm : conv
topval reduce_subst : conv