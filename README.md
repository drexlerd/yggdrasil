# Yggdrasil

`yggdrasil` packages the native dependency prefix used by the planning projects
in this repository family.

The Python distribution name is `pyyggdrasil`; the import package is
`yggdrasil`.

## Use From Python

Install the wheel and query the native prefix:

```python
import yggdrasil

print(yggdrasil.native_prefix())
```

Downstream CMake projects can use that path as `CMAKE_PREFIX_PATH`:

```bash
cmake -S . -B build \
  -DCMAKE_PREFIX_PATH="$(python -c 'import yggdrasil; print(yggdrasil.native_prefix())')"
```

Python packages that consume this native prefix should depend on:

```toml
dependencies = [
    "pyyggdrasil>=0.0.1",
]
```

## Build

Build a wheel from source:

```bash
uv build --wheel
```

The build creates `dependencies-build/` and `dependencies-install/`. To package
an existing native prefix without rebuilding dependencies:

```bash
YGGDRASIL_BUILD_NATIVE=OFF \
YGGDRASIL_NATIVE_PREFIX=/path/to/dependencies-install \
uv build --wheel
```

Runtime libraries are stripped in the wheel by default. Disable that for
debugging with:

```bash
YGGDRASIL_STRIP_WHEEL=OFF uv build --wheel
```
