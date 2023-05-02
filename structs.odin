package meta

@(Meta = {Group = "meta"})
a_struct :: struct {
	a: bool `f`,
	b: ^a_struct, // a comment
	c: []f32,
}
@(Meta = {Group = "meta"})
d_struct :: struct {
	l: f32,
	m: ^a_struct, // a comment
	n: []int,
}
/*
Value_Decl (n_attrs:1)
    Attribute (n_elm:1)
        Field_Value
            Ident (Meta)
            Comp_Lit (n_elms:1)
            Field_Value
                Ident (Group)
                Basic_Lit ("meta"(String))
    Ident (a_struct)
    Struct_Type(fields:3)
        Field_List (n_elm:3)
            Field (Tag:`f`(String))
                Ident (a)
                Ident (bool)
            Field
                Ident (b)
                Pointer_Type (^)
                Ident (a_struct)
            Field
                Comment_Group ( // a comment )
                Ident (c)
                Array_Type ([]f32)
                Ident (f32)
*/
