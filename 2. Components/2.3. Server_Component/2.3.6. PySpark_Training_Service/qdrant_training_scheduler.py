import schedule
import time
import subprocess

SPARK = "spark-submit"
SPARK_CONF = "/app/config/spark-defaults.conf"

EVENTS_JOB = "/app/jobs/job_events_to_qdrant.py"

def run_events_job():
    print("=== RUN EVENTS → QDRANT JOB ===")
    subprocess.run([
        SPARK,
        "--properties-file", SPARK_CONF,
        EVENTS_JOB
    ])
    print("=== EVENTS JOB DONE ===")

def main():
    print("=== QDRANT SCHEDULER STARTED ===")

    # Rulează o dată la pornire
    run_events_job()

    # Rulează jobul la fiecare 30 minute
    schedule.every(30).minutes.do(run_events_job)

    # Loop infinit — containerul rămâne UP
    while True:
        schedule.run_pending()
        time.sleep(1)

if __name__ == "__main__":
    main()
