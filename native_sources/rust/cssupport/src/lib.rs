use std::ffi::c_int;
use mlua::prelude::{LuaFunction, LuaResult, LuaTable};

#[link(name = "bridge",kind = "dylib")]
unsafe extern  "C" {
    fn Foo (int: c_int) -> c_int;
}

#[mlua::lua_module]
fn cssupport(lua: &mlua::Lua) ->LuaResult<LuaTable>{
    let exports = lua.create_table()?;
    let globals = lua.globals();
    let vim:LuaTable = globals.get("vim")?;
    let notify:LuaFunction = vim.get("notify")?;

    let foo = unsafe { Foo(1) };
    notify.call(("hello world".to_owned() + foo.to_string().as_str(), "info"))?;
    Ok(exports)
}
