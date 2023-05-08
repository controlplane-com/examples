ORG=$(grep ORG: ../parameters.yaml | awk -F ': ' '{print $2}')
GVC=$(grep GVC: ../parameters.yaml | awk -F ': ' '{print $2}')

if [ ! -f ../manifest.yaml ]; then
  echo "manifest.yaml has not been built. First run 'make build-manifest'"
  exit 1
fi

echo "Preparing to apply manifest.yaml to /org/$ORG/gvc/$GVC. Would you like to continue? (Y/N)"

read -r continue

if [ "$continue" = "Y" ] || [ "$continue" = "y" ]; then
  cpln apply -f "$1" --org $ORG --gvc $GVC
fi
