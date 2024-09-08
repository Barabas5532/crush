# No config file support for verible, so we'll do it ourselves.
#
# Define all options as variables so that we can use comments inline.

# Target line length limit to stay under when formatting.
column_limit="80"
# Each indentation level adds this many spaces.
indentation_spaces="2"
# Penalty added to solution for each introduced line break.
line_break_penalty="2"
# For penalty minimization, this represents the baseline penalty value of
# exceeding the column limit. Additional penalty of 1 is incurred for
# each character over this limit
over_column_limit_penalty="100"
# Each wrap level adds this many spaces. This applies when the first
# element after an open-group section is wrapped. Otherwise, the
# indentation level is set to the column position of the open-group
# operator.
wrap_spaces="4"
# Format various assignments: {align,flush-left,preserve,infer}
assignment_statement_alignment="flush-left"
# Format case items: {align,flush-left,preserve,infer}
case_items_alignment="align"
# Format class member variables: {align,flush-left,preserve,infer}
class_member_variable_alignment="flush-left"
# Use compact binary expressions inside indexing / bit selection operators
compact_indexing_and_selections="true"
# Aligh distribution items: {align,flush-left,preserve,infer}
distribution_items_alignment="flush-left"
# Format assignments with enums: {align,flush-left,preserve,infer}
enum_assignment_statement_alignment="flush-left"
# If true, always expand coverpoints.
expand_coverpoints="false"
# Format formal parameters: {align,flush-left,preserve,infer}
formal_parameters_alignment="flush-left"
# Indent formal parameters: {indent,wrap}
formal_parameters_indentation="wrap"
# Format net/variable declarations: {align,flush-left,preserve,infer}
module_net_variable_alignment="flush-left"
# Format named actual parameters: {align,flush-left,preserve,infer}
named_parameter_alignment="flush-left"
# Indent named parameter assignments: {indent,wrap}
named_parameter_indentation="wrap"
# Format named port connections: {align,flush-left,preserve,infer}
named_port_alignment="flush-left"
# Indent named port connections: {indent,wrap}
named_port_indentation="wrap"
# Format port declarations: {align,flush-left,preserve,infer}
port_declarations_alignment="flush-left"
# Indent port declarations: {indent,wrap}
port_declarations_indentation="wrap"
# If true, packed dimensions in contexts with enabled alignment are aligned
# to the right.
port_declarations_right_align_packed_dimensions="false"
# If true, unpacked dimensions in contexts with enabled alignment are
# aligned to the right.
port_declarations_right_align_unpacked_dimensions="false"
# Format struct/union members: {align,flush-left,preserve,infer}
struct_union_members_alignment="flush-left"
# If true, let the formatter attempt to optimize line wrapping decisions
# where wrapping is needed, else leave them unformatted.  This is a
# short-term measure to reduce risk-of-harm.
try_wrap_long_lines="false"
# Split end and else keywords into separate lines
wrap_end_else_clauses="true"


verible-verilog-format \
    --column_limit=$column_limit \
    --indentation_spaces=$indentation_spaces \
    --line_break_penalty=$line_break_penalty \
    --over_column_limit_penalty=$over_column_limit_penalty \
    --wrap_spaces=$wrap_spaces \
    --assignment_statement_alignment=$assignment_statement_alignment \
    --case_items_alignment=$case_items_alignment \
    --class_member_variable_alignment=$class_member_variable_alignment \
    --compact_indexing_and_selections=$compact_indexing_and_selections \
    --distribution_items_alignment=$distribution_items_alignment \
    --enum_assignment_statement_alignment=$enum_assignment_statement_alignment \
    --expand_coverpoints=$expand_coverpoints \
    --formal_parameters_alignment=$formal_parameters_alignment \
    --formal_parameters_indentation=$formal_parameters_indentation \
    --module_net_variable_alignment=$module_net_variable_alignment \
    --named_parameter_alignment=$named_parameter_alignment \
    --named_parameter_indentation=$named_parameter_indentation \
    --named_port_alignment=$named_port_alignment \
    --named_port_indentation=$named_port_indentation \
    --port_declarations_alignment=$port_declarations_alignment \
    --port_declarations_indentation=$port_declarations_indentation \
    --port_declarations_right_align_packed_dimensions=$port_declarations_right_align_packed_dimensions \
    --port_declarations_right_align_unpacked_dimensions=$port_declarations_right_align_unpacked_dimensions \
    --struct_union_members_alignment=$struct_union_members_alignment \
    --try_wrap_long_lines=$try_wrap_long_lines \
    --wrap_end_else_clauses=$wrap_end_else_clauses \
    --inplace \
    -- \
    $(find rtl sim -name *.v) \
    $(find rtl sim -name *.vh) \
