# AWS Backup (optional starter)
resource "aws_backup_vault" "this" {
  name = "${local.name_prefix}-backup-vault"
}

# Add plans/selections as you extend DR testing
