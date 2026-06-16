import schedule
import time
import subprocess
import os

SPARK = "spark-submit"
SPARK_CONF = "/app/config/spark-defaults.conf"

TRAINING_JOB = "/app/training_job_to_posgres.py.py"
TEST_JOB = "/app/jobs/test_job.py"


def run_training():
    print("=== RUN TRAINING JOB ===")
    subprocess.run([
        SPARK,
        "--properties-file", SPARK_CONF,
        TRAINING_JOB
    ])
    print("=== TRAINING JOB DONE ===")


def run_test():
    print("=== RUN TEST JOB ===")
    subprocess.run([
        SPARK,
        "--properties-file", SPARK_CONF,
        TEST_JOB
    ])
    print("=== TEST JOB DONE ===")


def main():
    print("=== TRAINING SERVICE SCHEDULER STARTED ===")

    # 1️⃣ Rulează training o singură dată la pornire
    run_training()

    # 2️⃣ Rulează training săptămânal (duminică la 03:00)
    schedule.every().sunday.at("03:00").do(run_training)

    # 3️⃣ Rulează test job continuu (polling la 30 sec)
    schedule.every(30).seconds.do(run_test)

    # 4️⃣ Loop infinit — containerul rămâne UP
    while True:
        schedule.run_pending()
        time.sleep(1)


if __name__ == "__main__":
    main()
