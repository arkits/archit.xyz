echo "DEPLOYING BOIS!"

echo "Making..."
./make.sh

echo "Moving zip to ansible dir"
mv public.zip ansible/roles/deploy/files/public.zip

echo "Moving install_blog.sh to ansible dir"
cp install_blog.sh ansible/roles/deploy/files/install_blog.sh

echo "Deploying using ansible..."
cd ansible
ansible-playbook playbook.yml

# echo "Cleanup..."
# cd ..
# rm public.zip

echo "Done!"
