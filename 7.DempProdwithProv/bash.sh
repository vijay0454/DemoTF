#! /bin/bash

sudo apt-getupdate
sudo apt-get install -y apache2
sudo systemctl start apache2
sudo systemctl enable apache2
echo "<h1> hello world : deployed via TF </h>" | sudo tee /var/www/html/html.index