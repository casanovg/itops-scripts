#
# Key for sshfs on
# - HTA-BusinessMate (10.6.17.30)
# - HTA-Enterprise (10.6.17.50)
# - HTA-NAS (10.6.17.70)
# - Passphrase: No passphrase 
#
ssh-keygen -t rsa
#ssh-copy-id -i ~/.ssh/id_rsa.pub netbackup@10.6.17.30
ssh-copy-id -i ~/.ssh/id_rsa.pub netbackup@10.6.17.40
ssh-copy-id -i ~/.ssh/id_rsa.pub netbackup@10.6.17.50
#ssh-copy-id -i ~/.ssh/id_rsa.pub netbackup@10.6.17.70
