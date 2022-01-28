name = "test-rds-connect"
aws-region = "us-east-2"
#These are the subnets in which the targets may be located
subnet-ids = [
  "subnet-0edd307d50018a340",
  "subnet-0343ec786b6ce827f",
  "subnet-0b645e730950b2ccd"
]
targets = {
  test-rds = {
    FQDN = "test-db.crjdpuq65iea.us-east-2.rds.amazonaws.com"
    internal-port = 5432
    external-port = 5432
  }
}
public-subnet-cidr = "172.31.53.0/24"
private-subnets = {
  "subnet-0" = {
    CIDR              = "172.31.50.0/24",
    availability-zone = "us-east-2a"
  }
  "subnet-1" = {
    CIDR              = "172.31.51.0/24",
    availability-zone = "us-east-2b"
  }
  "subnet-2" = {
    CIDR              = "172.31.52.0/24",
    availability-zone = "us-east-2c"
  }
}
polling-cron-expression = "*/5 * * * ? *"
vpc-id = "vpc-0086679a620a05e2b"