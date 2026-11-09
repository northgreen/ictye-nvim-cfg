"""Exercise entry selection without starting a JVM or importing PyGhidra."""

import importlib.util
import unittest
from pathlib import Path
from types import SimpleNamespace
from unittest.mock import Mock

SOURCE = Path(__file__).resolve().parents[2] / "scripts" / "neoghidra_export.py"
SPEC = importlib.util.spec_from_file_location("neoghidra_export", SOURCE)
assert SPEC is not None and SPEC.loader is not None
EXPORTER = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(EXPORTER)


class FunctionIterator:
    def __init__(self, functions):
        self.functions = iter(functions)
        self.first = next(self.functions, None)

    def hasNext(self):
        return self.first is not None

    def next(self):
        result = self.first
        self.first = next(self.functions, None)
        return result


def function(address, convention="unknown"):
    result = Mock()
    result.getEntryPoint.return_value = address
    result.getCallingConventionName.return_value = convention
    return result


def program(entries, functions):
    manager = SimpleNamespace(
        getFunctionAt=lambda address: functions.get(address),
        getFunctions=lambda _: FunctionIterator(list(functions.values())),
    )
    return SimpleNamespace(
        getFunctionManager=lambda: manager,
        getSymbolTable=lambda: SimpleNamespace(
            getExternalEntryPointIterator=lambda: iter(entries)
        ),
        getMinAddress=lambda: "image_base",
    )


class EntryAddressTest(unittest.TestCase):
    def test_data_export_is_not_selected_as_code(self):
        sample = program(["data", "code"], {"code": function("code")})
        self.assertEqual(EXPORTER.entry_address(sample), "code")

    def test_process_entry_takes_priority_over_other_exported_code(self):
        sample = program(
            ["helper", "start"],
            {"helper": function("helper"), "start": function("start", "processEntry")},
        )
        self.assertEqual(EXPORTER.entry_address(sample), "start")

    def test_no_code_exports_uses_first_function(self):
        sample = program(["data"], {"local": function("local")})
        self.assertEqual(EXPORTER.entry_address(sample), "local")

    def test_no_functions_uses_image_base(self):
        self.assertEqual(EXPORTER.entry_address(program(["data"], {})), "image_base")


if __name__ == "__main__":
    unittest.main()
