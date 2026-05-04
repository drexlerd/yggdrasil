import pyyggdrasil


def test_native_prefix_layout():
    native_prefix = pyyggdrasil.native_prefix()

    assert pyyggdrasil.__version__ != ""
    assert (native_prefix / "include").is_dir()
    assert (native_prefix / "lib").is_dir()
    assert (native_prefix / "include" / "boost").is_dir()
    assert (native_prefix / "lib" / "cmake").is_dir()
