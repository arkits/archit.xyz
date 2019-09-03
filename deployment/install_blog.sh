echo "Installing..."

echo "Deleting /"
sudo rm -rf /var/www/archit.xyz/html

echo "Unzipping"
unzip public.zip

echo "Moving"
mv public html
sudo mv html /var/www/archit.xyz/

echo "Cleanup"
rm -rf __MACOSX
rm public.zip

echo "Done!"