provider "google" {
  project = "tennis-court-agent"
  region  = "asia-northeast1"
}

resource "google_cloud_scheduler_job" "job" {
}

