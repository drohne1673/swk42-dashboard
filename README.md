This is a built and working Dashing dashboard, based on http://shopify.github.com/dashing.

On a linux based OS you can install it with:
sudo apt-get update
sudo apt-get install -y build-essential subversion
sudo apt-get install -y ruby1.9.1-dev
sudo apt-get install -y nodejs
sudo apt-get install -y imagemagick libmagickwand-dev
gem install dashing
gem install bundler
bundle

and run it with

dashing start