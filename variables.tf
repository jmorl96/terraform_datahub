variable "project" {
  type = string
  nullable = false
}

variable "vpc_name" {
  type = string
  nullable = false
}

variable "subnet_name" {
  type = string
  nullable = false
}

variable "cluster_name" {
  type = string
  nullable = false
}

variable "region" {
  type = string
  nullable = false
}
variable "zone" {
  type = string
  nullable = false
}

variable "mysqlRootPassword" {
  type = string
  nullable = false  
}

variable "neo4jPassword" {
  type = string
  nullable = false
}