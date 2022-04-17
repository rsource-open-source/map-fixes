mkdir tmp
cd tmp
git clone https://github.com/rojo-rbx/rbx-dom.git
cd rbx-dom
cargo build -p rbx_util --release
mv target\release\rbx_util.exe ..\.github\bin

# end
# start git

git add .\.github\bin\rbx_util.exe
git commit -m "rbx_util"
git push origin main # or master
