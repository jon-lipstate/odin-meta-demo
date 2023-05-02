package meta
import "core:fmt"
import "core:strings"
import "core:strconv"
import "core:odin/parser"
import "core:odin/ast"

print_tree :: proc(root_node: ^ast.Node) {
	visitor := ast.Visitor {
		visit = proc(visitor: ^ast.Visitor, node: ^ast.Node) -> ^ast.Visitor {
			if node == nil do return visitor
			line_info := "\n"

			switch typed_node in node.derived {
			case ^ast.Package:
				fmt.println(typed_node)
			case ^ast.File:
				fmt.println(typed_node)
			case ^ast.Comment_Group:
				fmt.printf("Comment_Group ( ")
				for c in typed_node.list {fmt.printf("%s ", c.text)}
				fmt.printf(")%s", line_info)
			case ^ast.Bad_Expr:
				fmt.println(typed_node)
			case ^ast.Ident:
				fmt.printf("Ident (%s)%s", typed_node.name, line_info)
			case ^ast.Implicit:
				fmt.println(typed_node)
			case ^ast.Undef:
				fmt.println(typed_node)
			case ^ast.Basic_Lit:
				fmt.printf("Basic_Lit (%s(%s))%s", typed_node.tok.text, typed_node.tok.kind, line_info)
			case ^ast.Basic_Directive:
				fmt.println(typed_node)
			case ^ast.Ellipsis:
				fmt.println(typed_node)
			case ^ast.Proc_Lit:
				fmt.printf("Proc_Lit (inlining: %s)%s", typed_node.inlining, line_info)
			case ^ast.Comp_Lit:
				fmt.printf("Comp_Lit (n_elms:%d)%s", len(typed_node.elems), line_info)
			case ^ast.Tag_Expr:
				fmt.println(typed_node)
			case ^ast.Unary_Expr:
				fmt.println(typed_node)
			case ^ast.Binary_Expr:
				fmt.println(typed_node)
			case ^ast.Paren_Expr:
				fmt.println(typed_node)
			case ^ast.Selector_Expr:
				fmt.println(typed_node)
			case ^ast.Implicit_Selector_Expr:
				fmt.println(typed_node)
			case ^ast.Selector_Call_Expr:
				fmt.println(typed_node)
			case ^ast.Index_Expr:
				fmt.println(typed_node)
			case ^ast.Deref_Expr:
				fmt.println(typed_node)
			case ^ast.Slice_Expr:
				fmt.println(typed_node)
			case ^ast.Matrix_Index_Expr:
				fmt.println(typed_node)
			case ^ast.Call_Expr:
				fmt.println(typed_node)
			case ^ast.Field_Value:
				fmt.printf("Field_Value %s", line_info) // field: value
			case ^ast.Ternary_If_Expr:
				fmt.println(typed_node)
			case ^ast.Ternary_When_Expr:
				fmt.println(typed_node)
			case ^ast.Or_Else_Expr:
				fmt.println(typed_node)
			case ^ast.Or_Return_Expr:
				fmt.println(typed_node)
			case ^ast.Type_Assertion:
				fmt.println(typed_node)
			case ^ast.Type_Cast:
				fmt.println(typed_node)
			case ^ast.Auto_Cast:
				fmt.println(typed_node)
			case ^ast.Inline_Asm_Expr:
				fmt.println(typed_node)
			case ^ast.Proc_Group:
				fmt.println(typed_node)
			case ^ast.Typeid_Type:
				fmt.println(typed_node)
			case ^ast.Helper_Type:
				fmt.println(typed_node)
			case ^ast.Distinct_Type:
				fmt.println(typed_node)
			case ^ast.Poly_Type:
				fmt.println(typed_node)
			case ^ast.Proc_Type:
				fmt.printf("Proc_Type (%s)%s", typed_node.calling_convention, line_info)
			case ^ast.Pointer_Type:
				ptr_depth, interior_node := extract_ptr_depth(&typed_node.elem.derived)
				desc := "" // NOTE(Jon): ideally we dont visit child pointers, so the visitor is a bit redundant
				if type_of(interior_node) == ^ast.Ident {
					desc = interior_node.(^ast.Ident).name
				}
				ptrs := strings.repeat("^", ptr_depth, context.temp_allocator)
				fmt.printf("Pointer_Type (%s%s)%s", ptrs, desc, line_info)
			case ^ast.Multi_Pointer_Type:
				ident, ok := typed_node.elem.derived.(^ast.Ident)
				name: string = ""
				if ok {name = ident.name}
				fmt.printf("Multi_Pointer_Type ([^]%s) %s", name, line_info)
			case ^ast.Array_Type:
				arr_len := ""
				if typed_node.len != nil {arr_len = typed_node.len.derived.(^ast.Basic_Lit).tok.text}
				desc := ""
				#partial switch interior in typed_node.elem.derived {
				case ^ast.Ident:
					desc = interior.name
				case ^ast.Pointer_Type:
					ptr_depth, _ := extract_ptr_depth(&interior.derived)
					desc = strings.repeat("^", ptr_depth, context.temp_allocator)
				}
				fmt.printf("Array_Type ([%s]%s) %s", arr_len, desc, line_info)
			case ^ast.Dynamic_Array_Type:
				ident := typed_node.elem.derived.(^ast.Ident).name
				fmt.printf("Dynamic_Array_Type ([dynamic]%s) %s", ident, line_info)
			case ^ast.Struct_Type:
				fmt.printf(
					"Struct_Type%s%s(fields:%d) %s",
					typed_node.is_packed ? " #packed" : "",
					typed_node.is_raw_union ? " #raw_union" : "",
					typed_node.name_count,
					line_info,
				)
			case ^ast.Union_Type:
				fmt.println(typed_node)
			case ^ast.Enum_Type:
				fmt.println(typed_node)
			case ^ast.Bit_Set_Type:
				fmt.println(typed_node)
			case ^ast.Map_Type:
				fmt.println(typed_node)
			case ^ast.Relative_Type:
				fmt.println(typed_node)
			case ^ast.Matrix_Type:
				fmt.println(typed_node)
			case ^ast.Bad_Stmt:
				fmt.println(typed_node)
			case ^ast.Empty_Stmt:
				fmt.println(typed_node)
			case ^ast.Expr_Stmt:
				fmt.println(typed_node)
			case ^ast.Tag_Stmt:
				fmt.println(typed_node)
			case ^ast.Assign_Stmt:
				fmt.println(typed_node)
			case ^ast.Block_Stmt:
				fmt.printf("Block_Stmt (n_val:%d)%s", len(typed_node.stmts), line_info)
			case ^ast.If_Stmt:
				fmt.println(typed_node)
			case ^ast.When_Stmt:
				fmt.println(typed_node)
			case ^ast.Return_Stmt:
				fmt.printf("Return_Stmt (n_val:%d)%s", len(typed_node.results), line_info)
			case ^ast.Defer_Stmt:
				fmt.println(typed_node)
			case ^ast.For_Stmt:
				fmt.println(typed_node)
			case ^ast.Range_Stmt:
				fmt.println(typed_node)
			case ^ast.Inline_Range_Stmt:
				fmt.println(typed_node)
			case ^ast.Case_Clause:
				fmt.println(typed_node)
			case ^ast.Switch_Stmt:
				fmt.println(typed_node)
			case ^ast.Type_Switch_Stmt:
				fmt.println(typed_node)
			case ^ast.Branch_Stmt:
				fmt.println(typed_node)
			case ^ast.Using_Stmt:
				fmt.println("USING USING USING USING USING USING USING ")
				fmt.println(typed_node)
			case ^ast.Bad_Decl:
				fmt.println(typed_node)
			case ^ast.Value_Decl:
				fmt.printf("Value_Decl (n_attrs:%d) %s", len(typed_node.attributes), line_info)
			case ^ast.Package_Decl:
				fmt.println(typed_node)
			case ^ast.Import_Decl:
				fmt.println(typed_node)
			case ^ast.Foreign_Block_Decl:
				fmt.println(typed_node)
			case ^ast.Foreign_Import_Decl:
				fmt.println(typed_node)
			case ^ast.Attribute:
				fmt.printf("Attribute (n_elm:%d) %s", len(typed_node.elems), line_info)
			case ^ast.Field:
				tag := typed_node.tag
				tag_str: string = ""
				if len(tag.text) > 0 {
					tag_str = fmt.tprintf("(Tag:%s(%s))", tag.text, tag.kind)
				}
				fmt.printf("Field %s%s", tag_str, line_info)
			// fmt.println(typed_node.type)
			case ^ast.Field_List:
				fmt.printf("Field_List (n_elm:%d) %s", len(typed_node.list), line_info)
			}
			return visitor
		},
	}
	ast.walk(&visitor, root_node)
}
extract_ptr_depth :: proc(node: ^ast.Any_Node) -> (ptr_depth: int, interior_node: ^ast.Any_Node) {
	next: ^ast.Any_Node = node
	ptr_depth = 0 // TODO: this should really be 1, but breaks the field_type proc
	for {
		current, is_ptr := next.(^ast.Pointer_Type)
		if !is_ptr {break}
		ptr_depth += 1
		next = &current.elem.derived
	}
	interior_node = next
	return ptr_depth, interior_node
}
extract_arr_data :: proc(node: ^ast.Any_Node) -> (arr_type: Array_Type, arr_len_fixed: int, interior_node: ^ast.Any_Node) {
	arr_len_fixed = -1
	#partial switch typed_node in node {
	case ^ast.Array_Type:
		arr_type = .Slice
		if typed_node.len != nil {
			len_str := typed_node.len.derived.(^ast.Basic_Lit).tok.text
			len_int, ok := strconv.parse_int(len_str)
			arr_type = .Fixed
			arr_len_fixed = len_int
		}
		interior_node = &typed_node.elem.derived
	case ^ast.Multi_Pointer_Type:
		arr_type = .Multi_Pointer
		interior_node = &typed_node.elem.derived
	case ^ast.Dynamic_Array_Type:
		arr_type = .Dynamic
		interior_node = &typed_node.elem.derived
	case:
		panic("unhandled array extract")
	}
	return arr_type, arr_len_fixed, interior_node
}

extract_field_type :: proc(node: ^ast.Any_Node, data_type: ^Data_Type) {
	interior_node: ^ast.Any_Node
	ptr_depth := 0
	#partial switch typed_node in node {
	case ^ast.Struct_Type:
		fmt.println(typed_node.fields.list[0])
		unimplemented("STRUCT WAS FIELD")
	case ^ast.Ident:
		data_type.kind = typed_node.name
	case ^ast.Array_Type, ^ast.Multi_Pointer_Type, ^ast.Dynamic_Array_Type:
		data_type.arr_type, data_type.arr_len_fixed, interior_node = extract_arr_data(typed_node)
	case ^ast.Pointer_Type:
		ptr_depth, interior_node = extract_ptr_depth(&typed_node.derived)
	}
	if interior_node != nil {
		#partial switch typed_node in interior_node {
		case ^ast.Ident:
			data_type.ptr_depth = ptr_depth
		case ^ast.Array_Type, ^ast.Multi_Pointer_Type, ^ast.Dynamic_Array_Type:
			data_type.arr_ptr_depth = ptr_depth
		}
		extract_field_type(interior_node, data_type)
	}
}
Data_Type :: struct {
	kind:          string, // eg bool, int
	arr_type:      Array_Type,
	arr_len_fixed: int,
	ptr_depth:     int, // eg foo: ^^bar == 2
	arr_ptr_depth: int, // eg foo: ^^^[]^bar == 3
}
Array_Type :: enum {
	Not,
	Slice,
	Fixed,
	Multi_Pointer,
	Dynamic,
}
