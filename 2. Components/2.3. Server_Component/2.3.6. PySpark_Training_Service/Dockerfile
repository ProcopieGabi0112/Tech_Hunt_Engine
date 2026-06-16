FROM apache/spark:3.5.1

USER root

RUN apt-get update && apt-get install -y python3 python3-pip && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# === INSTALL PYTHON DEPENDENCIES ===
COPY requirements.txt /app/requirements.txt
RUN pip3 install --no-cache-dir -r /app/requirements.txt

# === COPY ALL JDBC DRIVERS (Oracle + Postgres) ===
COPY jars/*.jar /opt/spark/jars/

# === COPY APP CODE ===
COPY . /app

# === COPY SPARK CONFIG ===
COPY config/spark-defaults.conf /opt/spark/conf/spark_defaults.conf

CMD ["bash"]