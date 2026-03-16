resource "aws_keyspaces_keyspace" "dotohtwo" {
  name = var.keyspace_name

  tags = {
    Name = var.keyspace_name
  }
}
