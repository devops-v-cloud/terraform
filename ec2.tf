resource "aws_instance" "ec2" {
  ami = "ami-04b70fa74e45c3917"
  instance_type = "t2.micro"
  key_name = aws_key_pair.ssh_key.key_name
  vpc_security_group_ids = [ aws_security_group.sg.id ]
  subnet_id = aws_subnet.sub1.id

  connection {
    type = "ssh"
    user = "ubuntu"
    private_key = file("~/.ssh/id_rsa")
    host = self.public_ip
  }

  provisioner "file" {
    source = "app.py"
    destination = "/home/ubuntu/app.py"
  }

  provisioner "remote-exec" {
    inline = [ 
        "echo 'Hello Remote exec'",
        "sudo apt update -y",
        "sudo apt install -y python3-pip",
        "sudo apt install -y python3-flask",
        "cd /home/ubuntu",
        "sudo python3 app.py &"
     ]
  }
}