project = "ecommerce"
env     = "dev"

db_config = {
  name     = "appdb_dev"
  user     = "admin_dev"
  password = "SuperPasswordDev123!"
  image    = "postgres:16-alpine"
}

api_config = {
  image         = "kennethreitz/httpbin:latest"
  internal_port = 80
}

host_ports = {
  nginx = 8080
}