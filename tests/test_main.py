"""
Test cho app/main.py.
TestClient giả lập HTTP request đến app NGAY TRONG bộ nhớ —
không cần khởi động server thật, chạy rất nhanh.
"""
from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)

def test_read_root():
    """Trang chủ phải trả 200 và có message."""
    response = client.get("/")
    assert response.status_code == 200
    assert "message" in response.json()

def test_health_check():
    """Health check phải trả status ok."""
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json() == {"status": "ok"}

def test_add():
    """Cộng 2 + 3 phải bằng 5."""
    response = client.get("/add", params={"a": 2, "b": 3})
    assert response.status_code == 200
    assert response.json()["result"] == 5

def test_add_invalid_input():
    """Truyền chữ thay vì số → FastAPI phải trả 422 (validation error)."""
    response = client.get("/add", params={"a": "xyz", "b": 3})
    assert response.status_code == 422

def test_divide():
    """Chia 10 / 4 = 2.5"""
    response = client.get("/divide", params={"a": 10, "b": 4})
    assert response.status_code == 200
    assert response.json()["result"] == 2.5

def test_divide_by_zero():
    """Chia cho 0 phải trả lỗi 400 — test cả trường hợp LỖI, không chỉ happy path"""
    response = client.get("/divide", params={"a": 10, "b": 0})
    assert response.status_code == 400
