output "redis_connection_uri" {
  description = "Connection string for accessing redis"
  value       = "redis://:${urlencode("${module.redis.password}")}@redis-master.redis:6379/0"
  sensitive   = true
}
