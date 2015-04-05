module unit_threaded.uda_utils;

import std.traits;
import std.typetuple;

/**
 * For the given module, return true if this module's member has
 * a UDA with a value that the predicate returns true to, false otherwise
 */
template HasAttribute(alias module_, string member, alias attribute) {
    mixin("import " ~ fullyQualifiedName!module_ ~ ";"); //so it's visible
    enum isAttribute(alias T) = is(TypeOf!T == attribute);
    alias attrs = Filter!(isAttribute, __traits(getAttributes, mixin(member)));

    static assert(attrs.length == 0 || attrs.length == 1,
                  text("Maximum number of attributes is 1 for ", attribute));

    static if(attrs.length == 0) {
        enum HasAttribute = false;
    } else {
        enum HasAttribute = true;
    }
}


/**
 * Utility to allow checking UDAs for types
 * regardless of whether the template parameter
 * is or has a type
 */
private template TypeOf(alias T) {
    static if(__traits(compiles, typeof(T))) {
        alias TypeOf = typeof(T);
    } else {
        alias TypeOf = T;
    }
}



unittest {

    import unit_threaded.attrs;
    import unit_threaded.tests.module_with_attrs;

    //check for value UDAs
    static assert(HasAttribute!(unit_threaded.tests.module_with_attrs, "testAttrs", HiddenTest));
    static assert(HasAttribute!(unit_threaded.tests.module_with_attrs, "testAttrs", ShouldFail));
    static assert(!HasAttribute!(unit_threaded.tests.module_with_attrs, "testAttrs", Name));

    //check for non-value UDAs
    static assert(HasAttribute!(unit_threaded.tests.module_with_attrs, "testAttrs", SingleThreaded));
    static assert(!HasAttribute!(unit_threaded.tests.module_with_attrs, "testAttrs", DontTest));
}
