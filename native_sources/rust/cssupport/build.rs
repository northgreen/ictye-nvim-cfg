use std::process::Command;
use std::env;

fn main(){
    let csdir = "./bridge";
    let outdir = env::var("OUT_DIR").unwrap();

    let status = Command::new("dotnet")
        .arg("publish")
        .arg("-p:NativeLib=Shared")
        .arg("-r").arg("win-x64")
        .arg("-c").arg("Release")
        .arg("-o").arg(outdir.clone()+"/dll")
        .status()
        .expect("failed to execute process");
    if!status.success(){
        panic!("failed to build bridge");
    }

    println!("cargo:rustc-link-search=native={}", outdir.clone()+"/dll");
    println!("cargo:rustc-link-lib=dylib=bridge");
    println!("cargo:rerun-if-changed={}", csdir);
}

