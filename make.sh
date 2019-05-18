echo "Making..."
hugo

echo "Zipping..."
zip -r public.zip public/

echo "Done!"