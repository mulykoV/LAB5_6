# Використовуємо базовий образ з Python
FROM python:3.9-slim

# Встановлюємо оновлення та потрібні пакети
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    curl unzip && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Встановлюємо бібліотеку junit-xml
RUN pip install --no-cache-dir junit-xml

# Копіюємо всі файли проекту
WORKDIR /app
COPY . .

# Переконатися, що директорія для звітів існує
RUN mkdir -p /app/test-reports

# Команда за замовчуванням для запуску тестів
CMD ["python", "-m", "unittest", "discover", "-s", "tests"]
