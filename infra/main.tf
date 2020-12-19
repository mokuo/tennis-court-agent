provider "google" {
  project = "tennis-court-agent"
  region  = "asia-northeast1"
}

resource "google_cloud_scheduler_job" "wakeup_job_21" {
  name        = "wakeup-tennis-court-agent21"
  description = "スリープしている tennis-court-agent を起こす"
  schedule    = "55 20 * * *" # 21時前
  time_zone   = "Asia/Tokyo"

  retry_config {
    retry_count = 1
  }

  http_target {
    http_method = "POST"
    uri         = "https://tennis-court-agent.herokuapp.com/api/wakeup" # 環境変数にしたい
  }
}

resource "google_cloud_scheduler_job" "wakeup_job_7" {
  name        = "wakeup-tennis-court-agent7"
  description = "スリープしている tennis-court-agent を起こす"
  schedule    = "55 6 * * *" # 7時前
  time_zone   = "Asia/Tokyo"

  retry_config {
    retry_count = 1
  }

  http_target {
    http_method = "POST"
    uri         = "https://tennis-court-agent.herokuapp.com/api/wakeup" # 環境変数にしたい
  }
}

