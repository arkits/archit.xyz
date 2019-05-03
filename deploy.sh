echo "DEPLOYING BOIS!"

echo "Making..."
./make.sh

echo "Moving zip to ansible dir"
mv public.zip ansible/roles/deploy/files/public.zip

echo "Deploying using ansible..."
cd ansible
ansible-playbook playbook.yml

# echo "Cleanup..."
# cd ..
# rm public.zip

echo "Done!"
