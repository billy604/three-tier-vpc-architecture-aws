resource "aws_db_subnet_group" "main" {
  name       = "three-tier-db-subnet-group"
  subnet_ids = aws_subnet.private_db[*].id

  tags = {
    Name = "three-tier-db-subnet-group"
  }
}

resource "aws_db_instance" "main" {
  identifier     = "three-tier-db"
  engine         = "postgres"
  engine_version = "16.4"
  instance_class = "db.t3.micro"

  allocated_storage = 20
  storage_encrypted = true

  db_name  = "appdb"
  username = var.db_username
  password = var.db_password

  db_subnet_group_name  = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.db.id]

  multi_az               = false #a real production database would set this true for automatic failover to a standby 
                                    #in a second AZ. I'm leaving it false here specifically to keep costs low (because I'm broke) 
                                    #for a portfolio project —
                                   
  skip_final_snapshot    = true   #normally, deleting an RDS database forces you to take one last backup snapshot first 
                                    #(a safety net). 
                                    
  publicly_accessible    = false
  backup_retention_period = 0     #turns off RDS's automated daily backups entirely. 
                                    #This is a deliberate cost-saving choice for a portfolio project that gets torn down regularly 
                                    #— a real production database would set this to 7, 14, or 30+ days instead.
}