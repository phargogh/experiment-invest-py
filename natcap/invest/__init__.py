try:
    # pygeoprocessing/version.py written for setuptools distributions.
    from version import version
    __version__ = version
except ImportError:
    # setuptools_scm fetches the version from .hg_archive, or from
    # hg, as needed.
    from setuptools_scm import get_version
    __version__ = get_version()
    version = __version__  # sets a separate VERSION attribute than __version__
