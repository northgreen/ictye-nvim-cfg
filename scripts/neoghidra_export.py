"""Export NeoGhidra's view data from a PyGhidra headless post-script."""

import json
import sys
import traceback
from importlib import import_module


def entry_address(program):
    """Exported entry points include data; prefer the process-entry function."""
    manager = program.getFunctionManager()
    fallback = None
    for address in program.getSymbolTable().getExternalEntryPointIterator():
        function = manager.getFunctionAt(address)
        if function is None:
            continue
        if str(function.getCallingConventionName()) == "processEntry":
            return address
        if fallback is None:
            fallback = address
    if fallback is not None:
        return fallback
    functions = manager.getFunctions(True)
    return (
        functions.next().getEntryPoint()
        if functions.hasNext()
        else program.getMinAddress()
    )


def disassembly(program, address):
    """Keep the entry-point preview bounded; operands require individual indices."""
    CommentType = import_module("ghidra.program.model.listing").CommentType

    listing = program.getListing()
    instructions = []
    instruction = listing.getInstructionAt(address)
    for _ in range(100):
        if instruction is None:
            break
        address = instruction.getAddress()
        instructions.append(
            {
                "address": str(address),
                "bytes": " ".join(
                    f"{int(byte) & 0xFF:02x}" for byte in instruction.getBytes()
                ),
                "mnemonic": str(instruction.getMnemonicString()),
                "operands": ", ".join(
                    str(instruction.getDefaultOperandRepresentation(index))
                    for index in range(instruction.getNumOperands())
                ),
                "comment": str(listing.getComment(CommentType.EOL, address) or ""),
            }
        )
        instruction = instruction.getNext()
    return instructions


def decompile_entry(program, function, monitor):
    """Release the native decompiler process even when decompilation fails."""
    DecompInterface = import_module("ghidra.app.decompiler").DecompInterface

    decompiler = DecompInterface()
    try:
        if not decompiler.openProgram(program):
            raise RuntimeError(str(decompiler.getLastMessage()))
        result = decompiler.decompileFunction(function, 30, monitor)
        if not result.decompileCompleted():
            raise RuntimeError(str(result.getErrorMessage()))
        return {
            "name": str(function.getName()),
            "entry_point": str(function.getEntryPoint()),
            "signature": str(function.getSignature()),
            "code": str(result.getDecompiledFunction().getC()),
        }
    finally:
        decompiler.dispose()


def export_program(program, monitor):
    """Convert Java values explicitly so the payload is native JSON data."""
    entry = entry_address(program)
    manager = program.getFunctionManager()
    result = {
        "program_name": str(program.getName()),
        "entry_point": str(entry),
        "image_base": str(program.getImageBase()),
        "language": str(program.getLanguageID()),
        "functions": [
            {
                "name": str(function.getName()),
                "entry_point": str(function.getEntryPoint()),
                "signature": str(function.getSignature()),
                "body_range": str(function.getBody()),
            }
            for function in manager.getFunctions(True)
        ],
        "symbols": [
            {
                "name": str(symbol.getName()),
                "address": str(symbol.getAddress()),
                "type": str(symbol.getSymbolType()),
                "source": str(symbol.getSource()),
            }
            for symbol in program.getSymbolTable().getAllSymbols(False)
            if not symbol.isExternal()
        ],
        "disassembly": disassembly(program, entry),
    }
    function = manager.getFunctionContaining(entry)
    # Omit absent data: JSON null becomes truthy vim.NIL in the plugin's Lua view.
    if function is not None:
        result["entry_function"] = decompile_entry(program, function, monitor)
    return result


def main():
    try:
        result = export_program(globals()["currentProgram"], globals()["monitor"])
    except Exception as error:  # noqa: BLE001 -- JVM/script failures must reach Neovim as error JSON.
        result = {
            "error": True,
            "message": str(error),
            "traceback": traceback.format_exc(),
        }
    sys.stdout.write("__NEOGHIDRA_JSON_START__\n")
    sys.stdout.write(json.dumps(result, ensure_ascii=True))
    sys.stdout.write("\n__NEOGHIDRA_JSON_END__\n")
    sys.stdout.flush()


if __name__ == "__main__":
    main()
