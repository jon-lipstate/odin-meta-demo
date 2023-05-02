package meta

import "core:os"
import "core:fmt"
import "core:strings"
import "core:strconv"
import "core:odin/parser"
import "core:odin/ast"
import g "./gen"

main :: proc() {
	for k, v in g.meta_map {
		fmt.printf("%v has %v fields\n", k, v)
	}
	if true do return

	file_paths := []string{"./structs.odin"}
	for file_path in file_paths {
		// Read the File:
		data, ok := os.read_entire_file(file_path);assert(ok)
		// Parse Into the AST:
		p := parser.Parser{}
		f := ast.File {
			src      = string(data),
			fullpath = file_path,
		}
		ok = parser.parse_file(&p, &f);assert(ok)
		// Util to understand Structure:
		// print_tree(f.decls[0])

		//Traverse AST, extract into needed data:
		structs := extract_structs(&f)

		// Produce new Odin File:
		write_member_defs("./gen/generated.odin", structs)
		fmt.println("END")
	}
}

Field :: struct {
	name:  string,
	type:  Data_Type,
	index: int,
	tag:   string,
}
Struct :: struct {
	group:  string,
	name:   string,
	fields: []Field,
}

extract_structs :: proc(f: ^ast.File) -> [dynamic]Struct {
	structs := make([dynamic]Struct)
	for decl in f.decls {
		val, vok := decl.derived_stmt.(^ast.Value_Decl)
		if !vok {continue} 	// import "core:..."
		// doesnt have any attributes, skip:
		if len(val.attributes) == 0 {continue}

		group, has_meta := extract_attrs(val)
		if !has_meta {continue}
		name_node := val.names[0].derived.(^ast.Ident)
		//We're only tagging structs - ergo attr flag above prunes everything else out
		the_struct, sok := val.values[0].derived.(^ast.Struct_Type);assert(sok, "Only structs can be meta-tagged")
		current := Struct {
			name   = name_node.name,
			fields = make([]Field, len(the_struct.fields.list)),
		}
		for field, i in &the_struct.fields.list {
			dt := Data_Type{}
			extract_field_type(&field.type.derived, &dt)
			current.fields[i].type = dt
			id := field.names[0].derived.(^ast.Ident)
			current.fields[i].name = id.name
			current.fields[i].tag = field.tag.text
			current.fields[i].index = i
		}
		current.group = group

		append(&structs, current)
	}
	return structs
}

extract_attrs :: proc(val: ^ast.Value_Decl) -> (group: string, has_meta: bool) {
	for attr in val.attributes {
		// Technically should iterate through FVs:
		fv, ok := attr.elems[0].derived.(^ast.Field_Value)
		ident, iok := fv.field.derived.(^ast.Ident);assert(iok)
		if ident.name != "Meta" {continue}
		has_meta = true
		//
		cmp_lit, cok := fv.value.derived.(^ast.Comp_Lit);assert(cok)
		fv, ok = cmp_lit.elems[0].derived.(^ast.Field_Value);assert(ok)
		ident, iok = fv.field.derived.(^ast.Ident);assert(iok)
		assert(ident.name == "Group")
		grp_lit, gok := fv.value.derived.(^ast.Basic_Lit);assert(gok)
		group = grp_lit.tok.text[1:len(grp_lit.tok.text) - 1]
		break
	}
	return
}

write_member_defs :: proc(path: string, structs: [dynamic]Struct) {
	using strings
	os.remove(path) // delete old file to ensure clean-write
	file, errno := os.open(path, os.O_CREATE);assert(errno == os.ERROR_NONE)
	defer os.close(file)
	sb := strings.builder_make();defer delete(sb.buf)
	write_string(&sb, "package meta_gen\n")
	write_string(&sb, "// WARNING: Auto-Generated File\n")
	// Write an Enum of the Structs
	write_string(&sb, "meta_enum :: enum {\n")
	for s in structs {
		write_string(&sb, "\t")
		write_string(&sb, s.name)
		write_string(&sb, ",\n")
	}
	write_string(&sb, "}\n\n")

	// Write a map[enum]Offsets
	// Note: Technically could interleave in one loop, but this is clearer:
	write_string(&sb, "meta_map := map[meta_enum]int {\n")
	for s in structs {
		write_string(&sb, "\t.")
		write_string(&sb, s.name)
		write_string(&sb, " = ")
		write_string(&sb, fmt.tprintf("%v", len(s.fields)))
		write_string(&sb, ",\n")
	}
	write_string(&sb, "}\n\n")

	// flush
	os.write_string(file, to_string(sb))
}
