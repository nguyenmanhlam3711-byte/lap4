# ============================================================
# Dockerfile cho FastAPI app — mỗi dòng có giải thích
# ============================================================
# 1) Image nền: Debian tối giản + Python 3.12 cài sẵn.
# Bản -slim nhẹ (~120MB), đủ dùng cho đa số app Python.
FROM python:3.12-slim

# 2) Biến môi trường:
# PYTHONDONTWRITEBYTECODE=1 : không sinh file .pyc (rác trong container)
# PYTHONUNBUFFERED=1 : in log ra ngay, không buffer
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# 3) Thư mục làm việc trong container — mọi lệnh sau chạy tại đây
WORKDIR /code

# 4) Copy RIÊNG requirements.txt trước để tận dụng layer cache:
# code đổi hằng ngày nhưng thư viện ít đổi → layer pip install
# được tái sử dụng → build lại nhanh hơn rất nhiều.
COPY requirements.txt .

# 5) Cài thư viện lúc BUILD image.
# --no-cache-dir: không giữ cache pip → image nhỏ hơn
RUN pip install --no-cache-dir -r requirements.txt

# 6) Bây giờ mới copy source code vào image
COPY ./app ./app

# 7) Khai báo container lắng nghe cổng 8000 (mang tính tài liệu)
EXPOSE 8000

# 8) Lệnh chạy khi container KHỞI ĐỘNG (dạng exec — mảng JSON,
# để app nhận SIGTERM và shutdown êm).
# --host 0.0.0.0 BẮT BUỘC: nếu không, app chỉ nghe localhost
# bên trong container, từ ngoài không truy cập được.
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
