use std::fs::File;
use std::io::Write;
use std::process::{Command, Output};
use std::env;

fn main(){
    let csdir = "./bridge";
    let outdir = env::var("OUT_DIR").unwrap();

    let lad = env::var("LOCALAPPDATA").unwrap();
    let nvim_profile_dir = lad.clone() + "\\nvim\\";
    let build_dep = nvim_profile_dir.clone() + "\\native_sources\\build_dep\\";

    println!("cargo:warning={}",nvim_profile_dir);
    println!("cargo:rustc-link-search=native={}", build_dep);
    println!("cargo:rustc-link-lib=dylib=bridge");
    println!("cargo:rerun-if-changed={}", build_dep);
}

