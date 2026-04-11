import json

from weaklink_platform.host_ops import parse_minikube_docker_env


def test_parse_minikube_docker_env_accepts_flat_mapping() -> None:
    payload = json.dumps({"DOCKER_HOST": "tcp://127.0.0.1:2376", "DOCKER_TLS_VERIFY": "1"})
    assert parse_minikube_docker_env(payload) == {
        "DOCKER_HOST": "tcp://127.0.0.1:2376",
        "DOCKER_TLS_VERIFY": "1",
    }


def test_parse_minikube_docker_env_accepts_nested_list_payload() -> None:
    payload = json.dumps(
        {
            "environment": [
                {"name": "DOCKER_HOST", "value": "tcp://127.0.0.1:2376"},
                {"name": "DOCKER_CERT_PATH", "value": "/tmp/certs"},
            ]
        }
    )
    assert parse_minikube_docker_env(payload) == {
        "DOCKER_HOST": "tcp://127.0.0.1:2376",
        "DOCKER_CERT_PATH": "/tmp/certs",
    }


def test_parse_minikube_docker_env_accepts_export_lines() -> None:
    payload = """
    export DOCKER_TLS_VERIFY="1"
    export DOCKER_HOST="tcp://127.0.0.1:2376"
    export NO_PROXY="192.168.49.2"
    """
    assert parse_minikube_docker_env(payload) == {
        "DOCKER_TLS_VERIFY": "1",
        "DOCKER_HOST": "tcp://127.0.0.1:2376",
        "NO_PROXY": "192.168.49.2",
    }


def test_parse_minikube_docker_env_accepts_plain_assignments() -> None:
    payload = """
    DOCKER_TLS_VERIFY=1
    DOCKER_HOST=tcp://127.0.0.1:2376
    """
    assert parse_minikube_docker_env(payload) == {
        "DOCKER_TLS_VERIFY": "1",
        "DOCKER_HOST": "tcp://127.0.0.1:2376",
    }
