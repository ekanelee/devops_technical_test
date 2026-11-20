output "ip_address" {
  description = "Global static IP of the load balancer."
  value       = google_compute_global_address.lb.address
}