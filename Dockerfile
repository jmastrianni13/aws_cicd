FROM python:3.12-slim

WORKDIR /app

COPY requirements.txt .
RUN python -m pip install -r requirements.txt

COPY src/serve.py /app/src/serve.py

EXPOSE 8000

CMD ["sanic", "src.serve:app", "--fast", "-H=0.0.0.0", "-p=8000", "--debug"]

