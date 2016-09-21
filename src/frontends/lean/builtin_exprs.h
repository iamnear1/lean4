/*
Copyright (c) 2014 Microsoft Corporation. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

Author: Leonardo de Moura
*/
#pragma once
#include "frontends/lean/parse_table.h"
namespace lean {
expr mk_anonymous_constructor(expr const & e);
bool is_anonymous_constructor(expr const & e);
expr const & get_anonymous_constructor_arg(expr const & e);

bool is_projection_notation(expr const & e);
bool is_anonymous_projection_notation(expr const & e);
name const & get_projection_notation_field_name(expr const & e);
unsigned get_projection_notation_field_idx(expr const & e);

parse_table get_builtin_nud_table();
parse_table get_builtin_led_table();
void initialize_builtin_exprs();
void finalize_builtin_exprs();
}
