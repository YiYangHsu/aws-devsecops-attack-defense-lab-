FROM python:3.12-slim

RUN useradd --create-home --shell /usr/sbin/nologin appuser

WORKDIR /app

COPY --chown=appuser:appuser app.py .

USER appuser

EXPOSE 8080

CMD ["python", "app.py"]

