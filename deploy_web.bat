call flutter build web
cp -R build/web/. docs/
git commit -m "SCRIPT: web deploy" -- ./docs
git push