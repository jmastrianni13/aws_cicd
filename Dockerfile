FROM python:3.12-slim

WORKDIR /app

COPY requirements.txt .
RUN python -m pip install -r requirements.txt

COPY src/serve.py /app/src/serve.py
COPY tests/__init__.py /tests/__init__.py
COPY tests/test_serve.py /tests/test_serve.py

RUN pytest

EXPOSE 5000

CMD ["sanic", "src.serve:app", "--fast", "-p=5000", "--debug"]

