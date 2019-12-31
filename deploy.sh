echo "~~~~ ~~~~ ~~~~ ~~~~ ~~~~"
echo "archit.xyz deployment"
echo "~~~~ ~~~~ ~~~~ ~~~~ ~~~~"

# Stop if there is an error
set -e

echo "  ==> Creating public..."
hugo

echo "  ==> Zipping..."
zip -r public.zip public/

echo "Moving zip to ansible dir"
mv public.zip deployment/ansible/roles/deploy/files/

echo "Moving install_blog.sh to ansible dir"
cp deployment/install_blog.sh deployment/ansible/roles/deploy/files/

echo "Deploying using ansible..."
cd deployment/ansible
ansible-playbook playbook.yml

echo "Done!"
