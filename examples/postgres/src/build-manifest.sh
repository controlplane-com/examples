if [ -f ./tmp/replaced-manifest.yaml ]; then
  rm -drf ./tmp
fi

mkdir ./tmp
touch ./tmp/replaced-manifest.yaml
cat manifest-template.yaml >> ./tmp/replaced-manifest.yaml
awk -F ': ' '{print "'\''s%$"$1"%"$2"%g'\''"}' ../parameters.yaml | xargs -I EXP sed -i -e EXP ./tmp/replaced-manifest.yaml

cat ./tmp/replaced-manifest.yaml

rm -drf ./tmp