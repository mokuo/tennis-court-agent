provider "google" {
  project = "tennis-court-agent"
  region  = "asia-northeast1"
}

resource "google_cloud_scheduler_job" "job" {
  name             = "wakeup-tennis-court-agent"
  description      = "スリープしている tennis-court-agent を起こす"
  schedule         = "55 20 * * *"
  time_zone        = "Asia/Tokyo"

  retry_config {
    retry_count = 1
  }

  http_target {
    http_method = "POST"
    uri         = "https://tennis-court-agent.herokuapp.com/api/wakeup" # 環境変数にしたい
  }
}

