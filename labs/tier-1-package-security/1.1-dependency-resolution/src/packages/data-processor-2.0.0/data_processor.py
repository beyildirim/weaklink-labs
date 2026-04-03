"""Data processing library - depends on internal-utils."""

__version__ = "2.0.0"

from internal_utils import sanitize_input, format_response


def process_record(record):
    """Process a single data record."""
    cleaned = sanitize_input(str(record))
    return format_response({"processed": cleaned})
