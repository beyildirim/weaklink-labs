from weaklink_platform.labs import find_lab, parse_estimated_minutes, phase_entries


def test_find_lab_reads_expected_metadata() -> None:
    lab = find_lab("0.1")
    assert lab is not None
    assert lab.title == "How Version Control Works"
    assert lab.tier == 0


def test_phase_entries_support_multiple_phase_shapes() -> None:
    lab = find_lab("7.5")
    assert lab is not None
    phases = phase_entries(lab.metadata)
    labels = [label for _, label, _ in phases]
    assert labels == ["UNDERSTAND", "INVESTIGATE", "DETECT", "RESPOND"]


def test_parse_estimated_minutes_supports_hours_and_minutes() -> None:
    assert parse_estimated_minutes("25m") == 25
    assert parse_estimated_minutes("1h30m") == 90
