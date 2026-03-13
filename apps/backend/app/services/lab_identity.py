import re
import hashlib


def canonical_username(username: str) -> str:
    normalized = username.strip().lower()
    if len(normalized) < 2 or len(normalized) > 48:
        raise ValueError("username must be between 2 and 48 characters")
    if not re.fullmatch(r"[a-z0-9._@-]+", normalized):
        raise ValueError("username may contain only letters, numbers, dot, underscore, dash, and @")
    return normalized


def build_session_id(username: str) -> str:
    slug = re.sub(r"[^a-z0-9]+", "-", username).strip("-")
    slug = (slug[:24] or "user").strip("-") or "user"
    digest = hashlib.sha1(username.encode("utf-8")).hexdigest()[:8]
    return f"{slug}-{digest}"


def pod_name(session_id: str) -> str:
    return f"lab-{session_id}"


def service_name(session_id: str) -> str:
    return f"lab-{session_id}"


def workspace_subpath(session_id: str) -> str:
    return f"users/{session_id}"
