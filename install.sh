echo "Installing..."

echo "Deleting /blog"
sudo rm -rf /var/www/archit.xyz/html/blog/ 

echo "Unzipping"
unzip public.zip

echo "Moving"
mv public blog
sudo mv blog /var/www/archit.xyz/html/

echo "Cleanup"
rm -rf __MACOSX
rm public.zip
rm -rf blog
rm -rf public

echo "Done!"