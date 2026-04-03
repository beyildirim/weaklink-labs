"""Safe utility functions for string operations."""


def greet(name):
    """Return a greeting string."""
    return f"Hello, {name}!"


def reverse_string(text):
    """Return the reversed string."""
    return text[::-1]


def count_words(text):
    """Count the number of words in a string."""
    return len(text.split())
