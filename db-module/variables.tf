
variable "snapshot_identifier_id" {
  type        = string
  description = "The ID of the data base snapshot to be used for provisioning databse. LEAVE EMPTY TO NOT USE EXISTING SNAPSHOT (data base will need additional configuring for the webapp to work)"
}

variable "database_password" {
  type        = string
  description = "The password used to connect to the database. MUST BE FILLED IF NO DATABASE SNAPSHOT INPUT"
}





