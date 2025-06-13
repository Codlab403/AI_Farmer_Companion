"""Pytest configuration that stubs out the optional google.generativeai dependency.
This avoids installing the real package when running unit tests and CI.
"""
import sys
import types

# Skip if already provided (e.g., devs installed the SDK)
if "google.generativeai" not in sys.modules:
    genai_stub = types.ModuleType("google.generativeai")

    class _FakeModel:
        def __init__(self, *_, **__):
            pass
        def generate_content(self, *_, **__):
            # Return minimal object mimicking generativeai response
            return types.SimpleNamespace(text="{\"diagnosis\":\"stub\"}")

    genai_stub.GenerativeModel = _FakeModel
    def _configure(api_key=None):
        genai_stub.API_KEY = api_key
    genai_stub.configure = _configure
    genai_stub.API_KEY = "stub"

    google_pkg = types.ModuleType("google")
    google_pkg.generativeai = genai_stub

    sys.modules["google"] = google_pkg
    sys.modules["google.generativeai"] = genai_stub

# Stub minimal supabase client so backend import works without real package
if "supabase" not in sys.modules:
    supabase_stub = types.ModuleType("supabase")
    def _create_client(url, key):
        class _Dummy:
            def __getattr__(self, item):
                raise AttributeError(item)
        return _Dummy()
    supabase_stub.create_client = _create_client
    supabase_stub.Client = object
    sys.modules["supabase"] = supabase_stub

# Stub minimal requests library (only json-get used in security)
if "requests" not in sys.modules:
    requests_stub = types.ModuleType("requests")
    def _fake_get(*args, **kwargs):
        return types.SimpleNamespace(json=lambda: {"keys": []}, status_code=200)
    requests_stub.get = _fake_get
    sys.modules["requests"] = requests_stub

# Stub python-jose used in security
if "jose" not in sys.modules:
    jose_stub = types.ModuleType("jose")
    jwt_mod = types.ModuleType("jwt")
    def _decode(*args, **kwargs):
        return {"sub": "test-user"}
    jwt_mod.decode = _decode
    jose_stub.jwt = jwt_mod
    jose_stub.JWTError = Exception
    sys.modules["jose"] = jose_stub
    sys.modules["jose.jwt"] = jwt_mod

# Stub minimal PIL Image
if "PIL" not in sys.modules:
    pil_stub = types.ModuleType("PIL")
    img_mod = types.ModuleType("Image")
    class _FakeImage:
        @staticmethod
        def open(*_, **__):
            return None
    img_mod.open = _FakeImage.open
    pil_stub.Image = img_mod
    sys.modules["PIL"] = pil_stub
    sys.modules["PIL.Image"] = img_mod
